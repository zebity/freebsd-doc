
 @what - some little tools to help render SGI IRIX "cat" manual files via HTML
           The SGI IRIX cat man files are "pre-process man pages (so formatted for ANSI terminal.
           This is how majority of IRIX manual pages are provided, with only a subset available as NROFF files.
           To to view with broswer you need to: 
           cat man-page | ul | aha | xsltproc -o - style-ansi2.xslt | sed -f man-links.sed 
           where:
             cat - standard unix commmand
             ul - unix utility program that handles takes NROFF generated underline
                    and generates ANSI underline formating: "_ + BS + Character"
             aha - ANSI HTML Adaptor a program to take ANSI terminal code inputs
                    and generate HTML renditon
             xsltproc - XML Style Sheet Transformation engineto to clean up "underline/bold style" 
             sed - standard unit stream editor to put HTML links in
             style-ansi2.xslt  - the xml code to tidy up underline
             man-links.sed sed script to add hyperlinks

 @Notes: directory includes example rendition of IRIX sh man page
           sh.term - original IRIX page
           sh.ul.aha.xslt.sed.html - the result of putting through pipeline

 @author - John Hartley - Graphica Software / Dokmai Pty Ltd

 (c) Copyright 2023 - All rights reserved

 
           

