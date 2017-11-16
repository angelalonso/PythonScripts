#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 WIKIFILE MARKDOWNFILE" >&2
  exit 1
fi
if ! [ -e "$1" ]; then
  echo "$1 not found" >&2
  exit 1
fi

WKFILE=$1
# both are needed to move changes around (VERY DIRTY AND UNELEGANT, I KNOW)
TMPFILE1=${WKFILE}.auxa
TMPFILE2=${WKFILE}.auxb
OUTPUT=$2

titles() {
sed 's/====<br>$/\'$'\n/g' ${TMPFILE1} | tee ${TMPFILE2}
sed 's/===<br>$/\'$'\n/g' ${TMPFILE2} | tee ${TMPFILE1}
sed 's/==<br>$/\'$'\n/g' ${TMPFILE1} | tee ${TMPFILE2}
sed 's/=<br>$/\'$'\n/g' ${TMPFILE2} | tee ${TMPFILE1}

sed 's/^====/\'$'\n####/g' ${TMPFILE1} | tee ${TMPFILE2}
sed 's/^===/\'$'\n###/g' ${TMPFILE2} | tee ${TMPFILE1}
sed 's/^==/\'$'\n##/g' ${TMPFILE1} | tee ${TMPFILE2}
sed 's/^=/\'$'\n#/g' ${TMPFILE2} | tee ${TMPFILE1}
rm ${TMPFILE2}
}

newlines() {
sed 's/$/<br>/g' ${TMPFILE1} | tee ${TMPFILE2}
mv ${TMPFILE2} ${TMPFILE1}
}

cp ${WKFILE} ${TMPFILE1}
# PLEASE RESPECT THE ORDER, having <br> on a header is wrong
newlines
titles


cp ${TMPFILE1} ${OUTPUT}
rm ${TMPFILE1}
