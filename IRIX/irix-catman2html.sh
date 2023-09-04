#!/bin/sh
#
# @what - irix-catman2html - a mess of scripts and bits and pieces to take an old SGI IRIX preprossed man page
#           and render is as html. This needs to: zcat the man page, process the nroff bold/underline directives,
#           run it through ANSI terminal to html processor, do some css tidy up to remove hard to read white on black
#           formatting (change to underline/bold), find and create links to referenced pages and
#           remove extra blanks lines and page number to render as a single continuoue HTML page
#
# @author - John Hartley - Grephica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

# irix-catman2html -d dir -p page

ZCAT="/usr/bin/zcat"
UL="/usr/bin/ul"
AHA="/usr/local/bin/aha"
XSLTPROC="/usr/local/bin/xsltproc"
PERL="/usr/local/bin/perl"
RM="/bin/rm"

VALOPTS="c:d:p:u:"
USAGE="Usage - ${0} -d dir -p page [-u URL-HOME] [-c HINT]"

EXPARG=2
DIR=
PAGE=
URL=
HINT=

# echo "DBG>> ${0} - \$#='$#'"


if [ $# -le 3 ]; then
	echo "${USAGE}" 1>&2
	exit 1
fi

while getopts ${VALOPTS} a
do
	case $a in
	c)	HINT="-c ${OPTARG}"; shift ;;
	d)	DIR=${OPTARG}; shift ;;
	p)	PAGE=${OPTARG}; shift ;;
	u)	URL="-u ${OPTARG}"; shift ;;
	:)	echo "${USAGE}" 1>&2
		exit 2;;
	\?)	echo "${USAGE}" 1>&2
		exit 2;;
	esac
	shift 
done

SUFFIX=z
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

TMP=/tmp/NAMTACXIRI.${PAGE}.$$

${ZCAT} ${FILE} | ${UL} | ${AHA} > ${TMP} && ${XSLTPROC} -o - style-ansi2.xslt ${TMP} | ${PERL} man-clean-link.pl ${URL} ${HINT}

RES=$?
if [ ${RES} -eq 0 ];then
	${RM} ${TMP}
else
	${RM} ${TMP}
	exit ${RES}
fi

