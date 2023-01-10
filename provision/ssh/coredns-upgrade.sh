#!/bin/bash
helm upgrade dns coredns/coredns --values coredns.values.deploy.yaml
