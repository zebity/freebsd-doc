#!/bin/sh
#
# @what - Add irix man page to html cache
#           for a .z file
#             do z -> html render to tmp file
#             if convert ok
#                get target name from html title tag
#                based on section / page add: .html & link
#                see if the are links to this page
#                of so add link to link to html page 
#
#          irix-cache-page.sh -z ZFILE -d CACHE
#
#          to build full cache of cat.Zz renders:
#            find <DIR-WITH-Zz> -type f -name '*.[zZ]' -exec -z {} -d <CACH> \;a
#
# @note - need to put in alias links as per source dir
#
# @author - John Hartley - Graphica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

USAGE="Usage - ${0} -d cache-dir -z path-to.zZ"
VALOPTS="d:z:"
EXPARG=2
DIR=
PATH=
PAGE=
FILE=
URL=
HTML=html
INDEX=index
MAN=man
PATHDIR=
TITLE=
SECTION=
KEY=
ALIAS=
TMP="lmth2tac.$$."

BASENAME="/usr/bin/basename"
CAT2HTML="./irix-catman2html.sh"
GREP="/usr/bin/grep"
MKDIR="/bin/mkdir"
MV="/bin/mv"
LN="/bin/ln"
RM="/bin/rm"

# echo "DBG>> ${0} - \$#='$#'"


if [ $# -ne 4 ]; then
	echo "${USAGE}" 1>&2
	exit 1
fi

while getopts ${VALOPTS} a
do
	case $a in
	d)	DIR=${OPTARG}; shift ;;
	z)	PATH=${OPTARG}; shift ;;
	:)	echo "${USAGE}" 1>&2
		exit 2;;
	\?)	echo "${USAGE}" 1>&2
		exit 2;;
	esac
	shift 
done

if [ ! -d ${DIR} ]; then
	mkdir -p ${DIR}/${HTML}
	mkdir -p ${DIR}/${INDEX}
fi

if [ -f ${PATH} ]; then
	FILE=`${BASENAME} ${PATH}`
	PATHDIR=${PATH%${FILE}}
	PAGE=${FILE%[.][zZ]}
else
	echo "Error - ${0} - cannot find: '$PATH'" 1>&2
	exit 1
fi

# DBG
# echo "DBG>> ${0} - FILE='${FILE}' PATHDIR='${PATHDIR}' PAGE='${PAGE}'"

${TMP}=${TMP}${PAGE}.html

${CAT2HTML} -d ${PATHDIR} -p ${PAGE} -c ${PAGE} > ${TMP}
if [ $? -eq 0 ]; then
	TITLE=`${GREP} '<title>.*</title>' ${TMP}`
	if [ ${TITLE} == "" ]; then
		${RM} ${TMP}
		echo "Error - ${0} - Processsing: '${FILE}' - No <Title></Title> tag found in: '${TMP}'." 1>&2
		exit 1;
	fi
	TITLE=${TITLE#<title>}
	TITLE=${TITLE%</title>}
	# DBG
	# echo "DBG>> ${0} - TITLE='${TITLE}'."
	KEY=${TITLE%%[(]*[)]}
	SECTION=${TITLE#${KEY}}
	SECTION=${SECTION#[(]}
	SECTION=${SECTION%[)]}

	# DBG
	# echo "DBG>> ${0} TITLE='${TITLE}' KEY='${KEY}' SECTION='${SECTION}'"

	HTML_DIR=${DIR}/${HTML}/${MAN}/${SECTION}
	LINK_DIR=${DIR}/${INDEX}/${MAN}/${SECTION}

	if [ ! -d ${HTML_DIR} ]; then
		${MKDIR} -p ${HTML_DIR}
	fi
	if [ ! -d ${LINK_DIR} ]; then
		${MKDIR} -p ${LINK_DIR}
	fi

	${MV} ${TMP} ${HTML_DIR}/${KEY}.html
	( cd ${LINK_DIR} && ${LN} -sf ../../../${HTML}/${MAN}/${SECTION}/${KEY}.html ${KEY} )
	#
	# DBG
	echo "Info - ${0} - Added: '${HTML_DIR}/${KEY}.html'."
fi 

if [ -e ${TMP} ]; then
	${RM} ${TMP}
fi
