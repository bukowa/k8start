package main

import (
	"io"
	"log"
	"math/rand"
	"net"
)

var AddrProxyMap = map[string][]string{
	":80": {
		"192.168.0.201:31000",
		"192.168.0.202:31000",
		"192.168.0.203:31000",
		"192.168.0.204:31000",
	},
	":443": {
		"192.168.0.201:32000",
		"192.168.0.202:32000",
		"192.168.0.203:32000",
		"192.168.0.204:32000",
	},
}

func passthrough(stop chan<- struct{}, dst io.Writer, src io.Reader) {
	io.Copy(dst, src)
	log.Println("passthrough is stopping...")
	stop <- struct{}{}
}

func random(slice []string) string {
	return slice[rand.Intn(len(slice))]
}

func main() {
	//httpClient := &http.Client{Transport: &http.Transport{
	//	TLSHandshakeTimeout: time.Second * 10,
	//	DisableKeepAlives:   false,
	//	MaxIdleConns:        size,
	//	MaxIdleConnsPerHost: size,
	//	MaxConnsPerHost:     size,
	//	IdleConnTimeout:     time.Second * 2,
	//}}
	for k, v := range AddrProxyMap {
		go runProxy(k, v)
	}
	<-make(chan struct{}, 1)
}

func runProxy(addr string, proxies []string) {

	listen, err := net.Listen("tcp", addr)
	if err != nil {
		panic(err)
	}
	log.Printf("Listening on %s for %v", addr, proxies)
	for {
		conn, err := listen.Accept()
		if err != nil {
			log.Printf("error while accepting connection %s", err)
			continue
		}
		log.Printf("accepted connection from %s", conn.RemoteAddr())
		go func(conn net.Conn) {
			defer conn.Close()
			proxy := random(proxies)
			conn2, err := net.Dial("tcp", proxy)
			if err != nil {
				log.Printf("error while connecting to %s", proxy)
				return
			}
			log.Printf("proxying from %s to %s", conn.RemoteAddr(), conn2.RemoteAddr())
			defer conn2.Close()
			stop := make(chan struct{}, 2)
			go passthrough(stop, conn2, conn)
			go passthrough(stop, conn, conn2)
			<-stop
			<-stop
		}(conn)
	}
}
