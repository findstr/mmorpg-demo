#!/bin/bash
iconv -f utf-16 -t utf8 "$1.txt" | ./lua toxml.lua "$1"
