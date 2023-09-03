
 @what - some little tools to help render SGI IRIX "cat" manual files via HTML
           The SGI IRIX cat man files are "pre-processed" (i.e. nroff/awf formatted for ANSI terminal).
           This is how majority of IRIX manual pages are provided, with only a subset available as standard ROFF files.

           To view with broswer you need to do something like:
             $ zcat sh.z | ul | aha > sh.ul.aha.html
             $ xsltproc -o - style-ansi2.xslt sh.ul.aha.html | perl man-clean-link.pl > sh.ul.aha.xslt.perl.html

           where:
             zcat - standard unix commmand to uncompress and cat file
             ul - unix utility program that handles takes NROFF generated underline
                    and generates ANSI underline formating: "_ + BS + Character"
             aha - ANSI HTML Adaptor a program to take ANSI terminal code inputs
                    and generate HTML rendition
             xsltproc - XML Style Sheet Transformation engine to clean up "underline/bold css style" 
             style-ansi2.xslt  - the xslt code to tidy up underline
             man-clean-link.pl perl script to cleanup headers/footers and add hyperlinks
             sed (not used, as perl as better regex)- standard unit stream editor to put HTML links in

             irix-catman2html.sh - shell script to run pipeline: Usage ./irix-catman2html -d DIR -p PAGE [-u URL-HOME] 

 @Notes: directory includes example rendition of IRIX sh man page
           sh.term - original IRIX page (uncompressed)
           sh.ul.aha.xslt.perl.html - the result of putting through pipeline

 @author - John Hartley - Graphica Software / Dokmai Pty Ltd

 (c) Copyright 2023 - All rights reserved

 
