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
#          IRIX has 3 diffirent man formats:
#            zZ - catman files - pre-rendered and compress for ANSI terminal
#            gzip - sgi supplied HTML pages
#            man.XX - nroff pages which can be rendered using groff & man2html 
#
#          to build full cache of cat.Zz renders, you can use find:
#            find <DIR-WITH-Zz> -type f -name '*.[zZ]' -exec -z {} -d <CACHE> \;
#          or
#            create-irix-man-cache.sh -z -Z -g -Z
#              where: zZ == cat2man g == gzip html -m == man - build via groff / man2html
#
# @note - need to put in alias links as per source dir
#
# @author - John Hartley - Graphica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

USAGE="Usage - ${0} -d cache-dir -z path-to.(zZ|gz|sec)"
VALOPTS="c:d:m:p:s:t:z:"

EXPARG=2
DIR=
PATH=
PAGE=
FILE=
CATSEC=
MANSEC=
TYPE=
URL="/irix-6.5.30/man/\${section}\${subsection}/\${title}"
ENV_PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
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
EGREP="/usr/bin/egrep"
MKDIR="/bin/mkdir"
MV="/bin/mv"
LN="/bin/ln"
RM="/bin/rm"
CUT="/usr/bin/cut"
GZCAT="/usr/bin/gzcat"
MAN="/usr/bin/man"
MAN2HTML="/usr/local/bin/man2html"
SED="/usr/bin/sed"
ENV="/usr/bin/env"
SH="/bin/sh"

# DBG
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

FILE=`${BASENAME} ${PATH}`
PATHDIR=${PATH%${FILE}}
PAGE=${FILE%.*}
TYPE=${FILE##*.}
MASK=${PATHDIR%/cat*/*}
CATSEC=${PATHDIR#${MASK}}
CATSEC=`echo ${CATSEC} | ${CUT} -f2 -d/`
MASK=${PATHDIR%/man*/*}
MANSEC=${PATHDIR#${MASK}}
MANSEC=`echo ${MANSEC} | ${CUT} -f2 -d/`

if [ ! -d "${DIR}" ]; then
	${MKDIR} -p "${DIR}/${HTML}"
	${MKDIR} -p "${DIR}/${INDEX}"
fi

if [ -f "${PATH}" ]; then
	FILE=`${BASENAME} ${PATH}`
	PATHDIR=${PATH%${FILE}}
else
	echo "Error - ${0} - cannot find: '$PATH'" 1>&2
	exit 1
fi

# DBG
# echo "DBG>> ${0} - FILE='${FILE}' PATHDIR='${PATHDIR}' PAGE='${PAGE}' TYPE='${TYPE}' HINT='${PAGE}' CAT='${CATSEC}' MAN='${MANSEC}'."

TMP="${TMP}${PAGE}.html"

case "${TYPE}" in
	Z)	;&
	z)	${CAT2HTML} -d ${PATHDIR} -s ${CATSEC} -p ${PAGE} -c ${PAGE} > ${TMP}
		;;
	gz)	${GZCAT} ${PATH} > ${TMP}
		;;
	*)	if [ "${MANSEC}" != "" ]; then
			SEC=${MANSEC#man}
			# SEC=${SEC%]}
			#
			# DBG
			# echo "DBG>> ${0} - SEC='${SEC}' TYPE='${TYPE}'." 
			${ENV} PATH=${ENV_PATH} ${SH} ${MAN} ${PATH} | ${MAN2HTML} -cgiurl ${URL} -title "${PAGE}(${TYPE})" > ${TMP}
		fi
		;;
esac

if [ $? -eq 0 ]; then
	TITLE=`${EGREP} '<(title|TITLE)>.*</(title|TITLE)>' ${TMP}`
	if [ "${TITLE}" == "" ]; then
		${RM} ${TMP}
		echo "Error - ${0} - Processsing: '${FILE}' - No <Title></Title> tag found in: '${TMP}'." 1>&2
		exit 1;
	else
		TSTSTR=`echo ${TITLE} | ${SED} -e 's/.*>\\(.*\)<\\/.*/\\1/g'`
		# echo "DBG>> ${0} - TSTSTR='${TSTSTR}'."
		TITLE=`echo ${TSTSTR} | ${SED} -e 's/\\([A-Za-z][-_\\.a-zA-Z1-9]*\\).*\\([(][1-9a-zA-Z][a-zA-Z1-9]*[)]\\).*/\\1\\2/g'`
		if [ "${TITLE}" == "" ]; then
			echo "Error - ${0} - Processsing: '${FILE}' - No <Title></Title> tag found in: '${TMP}'." 1>&2
			exit 1;
		fi
	fi
	# TITLE=${TITLE#<title>}
	# TITLE=${TITLE%</title>}
	# DBG
	# /
	# echo "DBG>> ${0} - TITLE='${TITLE}'."
	# exit 0
	KEY=${TITLE%%[(]*[)]}
	SECTION=${TITLE#${KEY}}
	SECTION=${SECTION#[(]}
	SECTION=${SECTION%[)]}

	# DBG
	# echo "DBG>> ${0} TITLE='${TITLE}' KEY='${KEY}' SECTION='${SECTION}'"

	HTML_DIR="${DIR}/${HTML}/${MAN}/${SECTION}"
	LINK_DIR="${DIR}/${INDEX}/${MAN}/${SECTION}"

	if [ ! -d "${HTML_DIR}" ]; then
		${MKDIR} -p ${HTML_DIR}
	fi
	if [ ! -d "${LINK_DIR}" ]; then
		${MKDIR} -p ${LINK_DIR}
	fi

	${MV} ${TMP} ${HTML_DIR}/${KEY}.html
	( cd ${LINK_DIR} && ${LN} -sf ../../../${HTML}/${MAN}/${SECTION}/${KEY}.html ${KEY} )
	#
	# DBG
	echo "Info - ${0} - Added: '${HTML_DIR}/${KEY}.html'."
fi 

if [ -e "${TMP}" ]; then
	${RM} ${TMP}
fi
