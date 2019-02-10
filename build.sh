#!/bin/bash

# Replace with dockerfile
rm -r dist/
elm make src/Main.elm --output=dist/elm.js
cp src/ports dist/ports -r
cp src/index.html dist/
