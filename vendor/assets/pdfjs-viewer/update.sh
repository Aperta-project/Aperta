#!/bin/bash

if [[ $# < 1 ]]; then
  echo USAGE $0 SOURCE_PATH 1>&2
  exit 1
fi

source="$1"

if [[ ! -f "$source/pdf.js" ]]; then
  echo "$source/pdf.js" not found 1>&2
  exit 1
fi

echo "%I-Copying javascript files"
cp "$source/pdf.js" pdf.js
cp "$source/pdf.worker.js" pdf.worker.js

echo "%I-Patching pdf.js with aperta.pdf.patch"
patch -s pdf.js aperta.pdf.patch

echo "%I-Copying viewer.css"
cp "$source/viewer.css" viewer.css

if [[ ! -d "./pdfjsviewer" ]]; then
  echo "%I-Creating directory: pdfjsviewer"
  mkdir pdfjsviewer
fi

echo "%I-Coyping asset directories (cmaps, images, locale)"
cp -R "$source/cmaps" "$source/images" "$source/locale" ./pdfjsviewer/
