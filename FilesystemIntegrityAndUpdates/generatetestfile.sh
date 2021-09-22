#!/bin/bash

# generate 10MB testfile containing printable characters only
< /dev/urandom tr -dc '[:graph:]' | head -c 10M > $1
