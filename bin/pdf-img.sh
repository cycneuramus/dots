#!/bin/bash
convert -compress jpeg -quality 1 "$@" "${1%.*}.pdf"
