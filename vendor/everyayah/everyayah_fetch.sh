#!/bin/sh
while IFS="" read -r url || [ -n "$p" ]
do
  url_folder=${url%/*}
  url_name=${url_folder##*/}
  echo " > $url_name ..."
  curl -o "downloaded/$url_name.zip" "$url"
  unzip  "downloaded/$url_name.zip" -d "downloaded/$url_name"
  rm -f "downloaded/$url_name.zip"
done < everyayah_list.txt

