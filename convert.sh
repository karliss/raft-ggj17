#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

for file in *.wav
  do ffmpeg -i "${file}" "${file/%wav/ogg}"
done
