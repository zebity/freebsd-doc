#!/bin/sh
#
# what - drive loop to walk through man pages and invoke either
#          - cat2html scripts
#          - groff/man2html processor
#          - copy compressed html to web document
#          and optionally build alias links
#
# @author - John Hartley - Graphica Software/Dokmai Pty Ltd
#
# (C)opyright 2023 - All right reserved
#

DIR="/usr/local/www/bsddoc/man/IRIX-6.5.30/"
CACHE="./irix-6.5.30"

ENV_PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

gz_on=0
z_on=0
Z_on=0
man_on=0
ADDLINKS=

USAGE="Usage ${0} -d MANDIR -c CACHE [-z == process .z] [-Z == process .Z] [-g == process .gz] [-m == process man roff] -o == (f[reebsd]|i[rix]|b[sd]|u[nix]) [-l == (off|only|on)]"
VALOPTS="c:d:gl:mo:zZ"

while getopts ${VALOPTS} a
do
        case $a in
        c)      CACHE=${OPTARG}; shift ;;
        d)      DIR=${OPTARG}; shift ;;
        g)      gz_on=1
		;;
        l)      ADDLINKS="-l ${OPTARG}"; shift ;;
        o)      OS="-o ${OPTARG}"; shift ;;
        m)      man_on=1
		;;
        z)      z_on=1
		;;
        Z)      Z_on=1
		;;
        :)      echo "${USAGE}" 1>&2
                exit 2;;
        \?)     echo "${USAGE}" 1>&2
                exit 2;;
        esac
        shift
done

BASENAME=/usr/bin/basename
CUT=/usr/bin/cut
CACHE_PAGE="./cache-man-page.sh"
SH=/bin/sh
ENV=/usr/bin/env

# DBG
echo "Info - ${0} OS='${OS}' gz=${gz_on} z=${z_on} Z=${Z_on} man=${man_on}."

let total = gz_on + z_on + Z_on + man_on; > /dev/null

if [ ${total} -eq 0 ]; then
	echo ${USAGE}
	exit 0
fi

for PATH in `find ${DIR} -type f -print | egrep '^.*\.([1-9][a-zA-Z]*|z|Z|gz)$'`
do

	FILE=`${BASENAME} ${PATH}`
	PATHDIR=${PATH%${FILE}}
	PAGE=${FILE%.*}
	SUFFIX=${FILE##*.}
	NPAGE=${PAGE%.*}

	#
	# DBG
	# echo "DBG>> FILE='${FILE}' PAGE='${PAGE}' NPAGE='${NPAGE}' SUFFIX='${SUFFIX}' CAT='${CATSECTION}' MAN='${MANSECTION}'."

	case ${SUFFIX} in
		z)	if [ "${z_on}" -eq 1 ]; then
				${ENV} "PATH=${ENV_PATH}" ${SH} ${CACHE_PAGE} -d ${CACHE} -m ${PATH} ${OS} ${ADDLINKS}
			fi
			;; 
		Z)	if [ "${Z_on}" -eq 1 ]; then
				${ENV} "PATH=${ENV_PATH}" ${SH} ${CACHE_PAGE} -d ${CACHE} -m ${PATH} ${OS} ${ADDLINKS}
			fi
			;; 
		gz)	if [ "${gz_on}" -eq 1 ]; then
				${ENV} "PATH=${ENV_PATH}" ${SH} ${CACHE_PAGE} -d ${CACHE} -m ${PATH} ${OS} ${ADDLINKS}
			fi
			;;
		*)	if [ "${man_on}" -eq 1 ]; then
				${ENV} "PATH=${ENV_PATH}" ${SH} ${CACHE_PAGE} -d ${CACHE} -m ${PATH} ${OS} ${ADDLINKS}
			fi
			;;
	esac
done
