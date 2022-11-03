#!/bin/sh
GOOS=linux GOARCH=arm go build -o tcp .
python -m http.server