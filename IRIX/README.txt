
 @what - some little tools to help render SGI IRIX "cat" manual files via HTML
           The SGI IRIX cat man files are "pre-processed" man pages (so nroff formatted for ANSI terminal.
           This is how majority of IRIX manual pages are provided, with only a subset available as standard NROFF files.

           To view with broswer you need to do something like:
             $ cat sh.term | ul | aha > sh.ul.aha.html
             $ xsltproc -o - style-ansi2.xslt sh.ul.aha.html | perl man-clean-link.pl > sh.ul.aha.xslt.perl.html

           where:
             cat - standard unix commmand
             ul - unix utility program that handles takes NROFF generated underline
                    and generates ANSI underline formating: "_ + BS + Character"
             aha - ANSI HTML Adaptor a program to take ANSI terminal code inputs
                    and generate HTML renditon
             xsltproc - XML Style Sheet Transformation engineto to clean up "underline/bold style" 
             sed - standard unit stream editor to put HTML links in
             style-ansi2.xslt  - the xml code to tidy up underline
             man-clean-link.pl perl script to cleanup headers/footers and add hyperlinks

             irix-catman2html.sh - shell script to run pipeline: Usage ./irix-catman2html -d DIR -p PAGE

 @Notes: directory includes example rendition of IRIX sh man page
           sh.term - original IRIX page
           sh.ul.aha.xslt.perl.html - the result of putting through pipeline

 @author - John Hartley - Graphica Software / Dokmai Pty Ltd

 (c) Copyright 2023 - All rights reserved

 
