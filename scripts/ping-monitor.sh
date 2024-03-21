#!/usr/bin/env bash

HELP=$(cat<<-EOF
$(basename $0)
Monitor internet ping!

Options:
 -j     Render output in "waybar-custom" compatible JSON format
 -h     show this help
 -t     high ping threshold (default: 50ms)
EOF
)

THRESHOLD=50

while getopts "hjt:" arg; do
  case $arg in
    h)
      echo "$HELP"
      exit 0
      ;;
    j)
      JSON_OUTPUT=true
      ;;
    t)
      THRESHOLD=$OPTARG
  esac
done

grep="grep --line-buffered"

ping 1.1.1.1 -i 3 | $grep time= | $grep -Po '\d+.\d*(?= ms)' | while read ping
do
  if [ -z $JSON_OUTPUT ] ; then
    echo $ping
  else
    class=high
    mid_threshold=$((THRESHOLD/2))
    if [[ $ping < $mid_threshold ]]; then
      class=low
    elif [[ $ping < $THRESHOLD ]]; then
      class=medium
    fi

    echo "{\"text\": \"$ping\", \"tooltip\": \"Ping: $ping\", \"class\": \"$class\" }"
  fi
done
