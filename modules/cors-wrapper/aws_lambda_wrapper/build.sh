#!/bin/sh
npm install axios
find . -type f -name "*" | zip -r9 -@ bootstrap.zip
