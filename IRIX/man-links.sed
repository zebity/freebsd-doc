#
# @what - sed script to add URL's to SGI IRIX Man Pages for Web Man
#
# @author - John Hartley - Graphica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#
/[a-z][a-z_]*[(][1-9][a-zA-Z]*[)][^<]/ {
s/\([a-z][a-z_]*\)\([(][1-9][a-zA-Z]*[)]\)/<a href="http:\/\/IRIX\/man\/\1">\1\2<\/a>/g
}
/<span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span><span [-a-zA-Z0-9=":;]*>_<\/span.*><span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span>([1-9][a-zA-Z]*)/ {
s/<span [-a-zA-Z0-9=":;]*>\([a-z][a-z]*\)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span.*><span [-a-zA-Z0-9=":;]*>\([a-z][a-z]*\)<\/span>\(([1-9][a-zA-Z]*)\)/<a href="http:\/\/IRIX\/man\/\1_\2">\1_\2\3<\/a>/g
}
/<span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span>([1-9][a-zA-Z]*)/ {
s/\(<span [-a-zA-Z0-9=":;]*>\)\([a-z][a-z]*\)<\/span>\(([1-9][a-zA-Z]*)\)/<a href="http:\/\/IRIX\/man\/\2">\2\3<\/a>/g
# s/\(<span [-a-zA-Z0-9=":;]*>\)\([a-z][a-z]*\)<\/span>\(([1-9][a-zA-Z]*)\)/<a href="http:\/\/IRIX\/man\/\2">\2\3 DBG@1='\1'<\/a>/g
}
/^[:space:]<span [-a-zA-Z0-9=":;]*>Page<\/span>[:space:]<span [-a-zA-Z0-9=":;]*>[0-9]*<\/span>/,/^[:space:]<span [-a-zA-Z0-9=":;]*>[a-z][a-z_]*[(][1-9][a-zA-Z]*[)]<\/span>[:space:]<span [-a-zA-Z0-9=":;]*>[a-z][a-z_]*[(][1-9][a-zA-Z]*[)]<\/span>/ {
d
# -3
# +3
}
