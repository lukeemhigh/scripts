#!/bin/bash

RELATIVE_PATH=$(cd "$(dirname $0)" && echo $PWD)

echo "$RELATIVE_PATH"
