#!/bin/sh
#
# @what - create a status home adding page
#
# @notes - section/page sort is not producing expected result ...
#
# @author - John Hartley - Graphica Software/Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

CACHE="./irix-6.5.30/index/man"

ENV_PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

OS=IRIX
VERSION="6.5.30"
ALPHA=1
SECTION=0
INDEX="a"
LINE=0
MANMASK=""
SEC=
PAGE=
SORTBY="Page/Section"
ITEM=4
# SEDFLIP="\2 \1"
BYALPHA="-f" 
# BYSECTION="-f" 
BYSECTION="-k5,4"
SORT_FLAGS=${BYALPHA}
GROUP=
GAT=
HOME="/irix-6.5.30/";
# ROUTE = ( "man?", "section=", "page=", "&" );
ROUTE1="man/"
ROUTE2=""
ROUTE3=""
ROUTE4="/"
ORSORTBY="Section/Page"
ALTINDEX="index-alt.html"

USAGE="Usage ${0} -c CACHE -o OS -v VERSION [-i(ndex by) == a(lpha) or s(ection)]."
VALOPTS="c:i:o:v:"

while getopts ${VALOPTS} a
do
        case $a in
        c)      CACHE=${OPTARG}; shift ;;
        i)      INDEX=${OPTARG}; shift ;;
        o)      OS=${OPTARG}; shift ;;
        v)      VERSION=${OPTARG}; shift ;;
        :)      echo "${USAGE}" 1>&2
                exit 2;;
        \?)     echo "${USAGE}" 1>&2
                exit 2;;
        esac
        shift
done

if [ "${INDEX}" = "s" ]; then
	ALPHA=0
	SECTION=1
	SORT_FLAGS=${BYSECTION}
	ORSORTBY=${SORTBY}
	SORTBY="Section/Page"
	ALTINDEX="index.html"
	# SEDFLIP="\1 \2"
fi
 
# DBG
# echo "DBG>> ${0} - CACHE='${CACHE}' OS='${OS}' VERSION='${VERSION}'."

BASENAME=/usr/bin/basename
CUT=/usr/bin/cut
SH=/bin/sh
ENV=/usr/bin/env
SORT=/usr/bin/sort
SED=/usr/bin/sed

if [ ! -d ${CACHE} ]; then
	echo "Error - ${0}: page cache not found: '${CACHE}'."
	exit 2
else
	MANMASK=${CACHE%/man}
	if [ "${MANMASK}" = "" ]; then
		echo "Error - ${0}: expectiing cache dir path: '*/man'."
		exit 2
	fi
fi

echo "<!DOCTYPE html>"
echo "<htm lang=\"en\">"
echo "<head>"
echo "<meta charset\"UTF-8\">"
echo "<title>${OS} ${VERSION} Man Page - Index sorted by ${SORTBY}</title>"
echo "</header>"
echo "<body>"
echo "<table>"
echo "<tr><td><h1>Man Pages for: ${OS} ${VERSION} - Sorted by: ${SORTBY}</h1></td></tr>"
echo "<tr><td><h2>Alternate Index - Sorted by: <a href=\"${HOME}${ALTINDEX}\">${ORSORTBY}</a></h2></td></tr>"
echo "<tr><td>${OS} Web Render <a href=\"https://github.com/zebity/freebsd-doc/tree/main/IRIX\">code</a> by: Graphica Software/Dokmai Pty Ltd (c) 2023</td></tr>"
echo "<tr><td>Copyright (c) of pages with vendors: SGI, HP, SUN (and as attributed in page)</td></tr>"
echo "<tr><td>See: <a href=\"https://just.graphica.com.au/tips/\">Just Enough Architecture - Technical Tips</a> for vintage SGI/IRIX blog/tips.</td></tr>"
echo "</table>"
echo "<br>"
echo "<hr //>"
echo "<table>" 

PAIR=0
COL=0
ROW="<tr>"

# find ./irix-6.5.30/index/man  -print | sed -e '/^.*\/index\/man$/d' -e '/^.*\/index\/man\/[1-9a-zA-Z][a-zA-Z1-9]*$/d' > index-stripped.txt
# cat index-stripped.txt  | sed  -e '/^.*\/index\/man\/[^/]*\/.*$/s/^.*\/index\/man\/\([^/]*\)\/\(.*\)/\2 \1/g' | sort -f
#

# for NEXT in `find ${CACHE} -print | ${SED} -e '/^.*\/index\/man$/d' -e '/^.*\/index\/man\/[1-9a-zA-Z][a-zA-Z1-9]*$/d' -e '/^.*\/index\/man\/[^/]*\/.*$/s/^.*\/index\/man\/\([^/]*\)\/\(.*\)/\2 \1/g'`

for NEXT in `find ${CACHE} -print | ${SED} -e '/^.*\/index\/man$/d' -e '/^.*\/index\/man\/[1-9a-zA-Z][a-zA-Z1-9]*$/d' -e '/^.*\/index\/man\/[^/]*\/.*$/s/^.*\/index\/man\/\([^/]*\)\/\(.*\)/\2 \1/g' | ${SORT} ${SORT_FLAGS}`
do
	let LINE=LINE+1 > /dev/null
	let PAIR=PAIR+1 > /dev/null
	# FILE=`${BASENAME} ${PATH}`
	# PATHDIR=${PATH%${FILE}}
	# PAGE=${FILE%.*}
	# SUFFIX=${FILE##*.}

	if [ $PAIR -eq 1 ]; then
		PAGE=${NEXT}
	else
		SEC=${NEXT}

		if [ ${ALPHA} -eq 1 ]; then
			UCPAGE=`echo ${PAGE} | tr '[:lower:]' '[:upper:]'`
			GAT=`echo ${UCPAGE} | cut -c 1-1`
			# GAT=${UCPAGE%%?*}
			# DBG
			# echo "DBG>> ${0} - ALPHA=${ALPHA} PAGE='${PAGE}' UCPAGE='${UCPAGE}' GAT='${GAT}'."
		elif [ ${SECTION} -eq 1 ]; then
			GAT=${SEC}
		fi

		if [ "${GAT}" != "${GROUP}" ]; then
			ROW=${ROW}"</tr>"
			echo ${ROW}
			echo "<tr><td>${GAT}</td></tr>"
			ROW="<tr>"
			GROUP=${GAT}
			COL=0
		elif [ ${COL} -eq ${ITEM} ]; then
			ROW=${ROW}"</tr>"
			echo ${ROW}
			ROW="<tr>"
			COL=0
		fi

		ROW=${ROW}"<td><a href=\"${HOME}${ROUTE1}${ROUTE2}${SEC}${ROUTE4}${ROUTE3}${PAGE}\">${PAGE}(${SEC})</a></td>"
		PAIR=0
		let COL=COL+1 > /dev/null
		
	fi
	# DBG
	# echo "DBG>> ${0} - LINE=${LINE} PAIR=${PAIR} GAT='${GAT}' GROUP='${GROUP}' PAGE='${PAGE}' SEC='${SEC}' ROW='${ROW}'."
	# if [ ${LINE} -eq 32 ]; then
 	#	exit 0
	# fi
done
echo "${ROW}"
echo "</tr>"
echo "</table>"
echo "</body>"
echo "</html>"
