#!/bin/sh
#
# @what - irix-catman2html - a mess of sripts and bits and pieces to take an old SGI IRIX preprossed man page
#           and render is as html. So we need to zcat the man pagei, process the nroff bold/underline directives,
#           run it through ANSI terminal to html processor, do some css tidy up to remove hard to read white on black
#           formatting (change to underline/bold), find and create links to referenced pages and
#           remove extra blanks lines and page number and render as single continuoue HTML page
#
# @author - John Hartley - Grephica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

# irix-catman2html -d dir -p page

USAGE="Usage - ${0} -d dir -p page"
VALOPTS="d:p:"
EXPARG=2
DIR=
PAGE=

echo "DBG>> ${0} - \$#='$#'"


if [ $# -ne 4 ]; then
	echo "${USAGE}" 1>&2
	exit 1
fi

while getopts ${VALOPTS} a
do
	case $a in
	d)	DIR=${OPTARG}; shift ;;
	p)	PAGE=${OPTARG}; shift ;;
	:)	echo "${USAGE}" 1>&2
		exit 2;;
	\?)	echo "${USAGE}" 1>&2
		exit 2;;
	esac
	shift 
done

SUFFIX=z
CAT=zcat
FILE=

if [ -f "${DIR}/${PAGE}.z" ]; then
	FILE="${DIR}/${PAGE}.z"
elif [ -f "${DIR}/${PAGE}.Z" ]; then
	SUFFIX=Z
	FILE="${DIR}/${PAGE}.Z"
elif [ -f "${DIR}/${PAGE}.gz" ]; then
	SUFFIX=gz
	FILE="${DIR}/${PAGE}.gz"
	CAT=gzcat
else
	echo "Error - Uable to locate page at: '${DIR}/${PAGE}.(z|Z|gz)'" 1>&2
	exit 1
fi

${CAT} ${FILE} | ul | aha > /tmp/NAMTACXIRI.${PAG}.$$ && xsltproc -o - style-ansi2.xslt /tmp/NAMTACXIRI.${PAG}.$$ | perl man-clean-link.pl

