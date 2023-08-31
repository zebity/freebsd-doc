#!/usr/local/bin/perl
#
# @what - perl script to clean up page header/footers & and link to SGI IRIX Man Pages for Web Man
#          page has 3 section: <html> preamble, <pre> content <html> post close
#          script does:
#             (1) tranparent premable
#             (2) empty line spaceing, header/footer fix, add links for <pre> section
#             (3) transparent close 
#
# @author - John Hartley - Graphica Software / Dokmai Pty Ltd
#
# (C)opyright 2023 - All rights reserved
#

use strict;
use warnings;

my $SPACE = 3;

my $PRE = 0;
my $HEADERS = 0;
my $FOOTERS = 0;
my $EMPTY = 0;
my $LAST = "";
my $BC = 0;
my $LINKS = 0;

my $IN = *STDIN;



while (<$IN>) {

	if ($PRE == 1) {

		if (/[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>.*/) {
			if ($HEADERS == 0) {
				print;
				$BC = 0;
			}
			$HEADERS++;
		} elsif (/^[[:space:]]*$/) {
			$BC++;
			$EMPTY++;
			if ($BC < $SPACE) {
				print;
			}
		} elsif (/[[:space:]]*<span [-a-zA-Z0-9=":;]*>Page<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[1-9][0-9]*<\/span>.*/) {
			$LAST = $_;
			$FOOTERS++;
		} elsif (/<\/pre>/) {
			$PRE = 0;
			print $LAST;
			print "<!-- HEADERS: $HEADERS FOOTERS: $FOOTERS EMPTY: $EMPTY LINKS: $LINKS -->\n";
			print;
		} elsif (/[a-z][a-z_]*[(][1-9][a-zA-Z]*[)][^<]/) {
			$LINKS += s/([a-z][a-z_]*)([(][1-9][a-zA-Z]*[)])/<a href="http:\/\/IRIX\/man\/$1">$1$2<\/a>/g;
			print;
			$BC = 0;
		} elsif (/<span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span>[(][1-9][a-zA-Z]*[)]/) {
			#
			# example
			# <span style="text-decoration:underline;font-weight:bold;">rsh</span><span style="text-decoration:underline;">_</span><span style="text-decoration:underline;font-weight:bold;">bsd</span>(1C))
			#
			$LINKS = s/<span [-a-zA-Z0-9=":;]*>([a-z][a-z]*)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>([a-z][a-z]*)<\/span>([(][1-9][a-zA-Z]*[)])/<a href="http:\/\/IRIX\/man\/$1_$2">$1_$2$3<\/a>/g;
			$BC = 0;
			# print "DBG>> MATCHED: XX_XX(nX)";
			print;
		} elsif (/<span [-a-zA-Z0-9=":;]*>[a-z][a-z]*<\/span>[(][1-9][a-zA-Z]*[)]/) {
			$LINKS += s/(<span [-a-zA-Z0-9=":;]*>)([a-z][a-z]*)<\/span>([(][1-9][a-zA-Z]*[)])/<a href="http:\/\/IRIX\/man\/$2">$2$3<\/a>/g;
			# s/\(<span [-a-zA-Z0-9=":;]*>\)\([a-z][a-z]*\)<\/span>\(([1-9][a-zA-Z]*)\)/<a href="http:\/\/IRIX\/man\/\2">\2\3 DBG@1='\1'<\/a>/g
			$BC = 0;
			# print "DBG>> MATCHED: XX(nX)";
			print;
		} else {
			$BC = 0;
			print;
		}
	} else {
		if (/<pre[-a-zA-Z0-9=":; ]*>/) {
			$PRE = 1;
			$BC = 0;
		}
		print;
	}
}
