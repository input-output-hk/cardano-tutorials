#!/bin/sh
pandoc -f markdown -t latex -o README.pdf README.md
pandoc -f markdown -t latex -o AWS.pdf AWS.md
pandoc -f markdown -t latex -o build.pdf build.md
pandoc -f markdown -t latex -o ekg.pdf ekg.md
pandoc -f markdown -t latex -o prometheus.pdf prometheus.md
