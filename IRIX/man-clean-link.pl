#!/usr/local/bin/perl
#
# @what - perl script to clean up page header/footers & and link to SGI IRIX Man Pages for Web Man
#          page has 3 section: <html> preamble, <pre> content, <html> close
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
# use Switch;

my $SPACE = 3;

my $PRE = 0;
my $IS = "IRIX";
my $HEADERS = 0;
my $FOOTERS = 0;
my $EMPTY = 0;
my $LAST = "";
my $BC = 0;
my $LINKS = 0;
my $TITLE = "";
my $HEADER = 1;
my $FOOTER = 1;
my $DISCARD = 0;
my $HOME = "http://help.graphica.com.au/man/irix-6.5.30/";
my @ROUTE = ( "man?", "section=", "page=" );

my @BUFFER = ();
my $I = 0;

my $IN = *STDIN;

my $ARG = shift;

while ($ARG) {
	if ($ARG eq "-d") {
		$DISCARD = 1;
	} elsif ($ARG eq "-t") {
		$TITLE = shift;
	} elsif ($ARG eq "-s") {
		$SPACE = shift;
	} elsif ($ARG eq "-h") {
		$HEADER = shift;
	} elsif ($ARG eq "-f") {
		$FOOTER = shift;
	} elsif ($ARG eq "-u") {
		$HOME = shift;
	} elsif ($ARG eq "-r") {
		@ROUTE = shift;
	} else {
		print STDERR "Usage: $ARGV[0] [-d == DISCARD] [-t TITLE] [-s SPACE] [-h HEADER=(0|1|2)] [-f FOOTER=(0|1|2) ] [-u URL-HOME] [-r ROUTE=('base', 'section', 'page')]";
	}
	$ARG = shift;
}

while (<$IN>) {

	if ($PRE == 1) {

		if ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>/ ) {
			# IRIX Header
			# <span style="font-weight:bold;">ttdbserverd(8)</span>                                                  <span style="font-weight:bold;">ttdbserverd(8)</span>
			if ($TITLE eq "") {
				my $TMP = $_;
				my $J = 0;
				if ($TMP =~ /[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)])<\/span>/) {
					$TITLE = $1;
					$J++;
					print "<title>$TITLE</title>\n";
				} else {
					$TITLE = $BUFFER[0];
				}
				for (; $J < $I; $J++) {
					print $BUFFER[$J];
				}
			}
			if ($HEADER != 0 && ($HEADERS == 0 || $HEADER == 2)) {
				$BC = 0;
				print;
			}
			$HEADERS++;
		} elsif ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>UNIX<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>System<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>V<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>/ ) { 
			# UNIX System V Headers
			#     <span style="font-weight:bold;">mwm(1X)</span>                   <span style="font-weight:bold;">UNIX</span> <span style="font-weight:bold;">System</span> <span style="font-weight:bold;">V</span>                   <span style="font-weight:bold;">mwm(1X)</span>
			$IS = "SystemV";
			if ($TITLE eq "") {
				my $TMP = $_;
				my $J = 0;
				if ($TMP =~ /[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)])<\/span>/) { 
					$TITLE = $1;
					$J++;
					print "<title>$TITLE</title>\n";
				} else {
					$TITLE = $BUFFER[0];
				}
				for (; $J < $I; $J++) {
					print $BUFFER[$J];
				}
			}
			if ($HEADER != 0 && ($HEADERS == 0 || $HEADER == 2)) {
				$BC = 0;
				print;
			}
			$HEADERS++;
		} elsif ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>UNIX<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>System<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>V<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[(][A-Z][a-zA-z]*<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[0-9]*<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[0-9]*<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[)]<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>/ ) { 
			# UNIX System V Headers (Variation)
			#      <span style="font-weight:bold;">SSHD(8)</span>         <span style="font-weight:bold;">UNIX</span> <span style="font-weight:bold;">System</span> <span style="font-weight:bold;">V</span> <span style="font-weight:bold;">(October</span> <span style="font-weight:bold;">28</span> <span style="font-weight:bold;">2010</span> <span style="font-weight:bold;">)</span>          <span style="font-weight:bold;">SSHD(8)</span>
			$IS = "SystemV";
			if ($TITLE eq "") {
				my $TMP = $_;
				my $J = 0;
				if ($TMP =~ /[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)])<\/span>/) {
					#
					# if all upper case then change to lower case (leave mixed/lower as is)
					# 
					my $P = $1;
					if ($P =~ /([A-Z][_\.A-Z]*)([(][1-9][a-zA-Z]*[)])/ ) {
						$TITLE = (lc $1) . $2; 
					} else {
						$TITLE = $P;
					}
					$J++;
					print "<title>$TITLE</title>\n";
				} else {
					$TITLE = $BUFFER[0];
				}
				for (; $J < $I; $J++) {
					print $BUFFER[$J];
				}
			}
			if ($HEADER != 0 && ($HEADERS == 0 || $HEADER == 2)) {
				$BC = 0;
				print;
			}
			$HEADERS++;
		} elsif ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>OpenGL<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>Reference<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[a-zA-Z][_a-zA-z]*[(][1-9][a-zA-Z]*[)]<\/span>/ ) {
			# OpenGL Headerr
			# <span style="font-weight:bold;">glBegin(3G)</span>                    <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Reference</span>                    <span style="font-weight:bold;">glBegin(3G)</span>
			$IS = "OpenGL";
			if ($TITLE eq "") {
				my $TMP = $_;
				my $J = 0;
				if ($TMP =~ /[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][_\.a-zA-z]*[(][1-9][a-zA-Z]*[)])<\/span>/) { 
					$TITLE = $1;
					$J++;
					print "<title>$TITLE</title>\n";
				} else {
					$TITLE = $BUFFER[0];
				}
				for (; $J < $I; $J++) {
					print $BUFFER[$J];
				}
			}
			if ($HEADER != 0 && ($HEADERS == 0 || $HEADER == 2)) {
				$BC = 0;
				print;
			}
			$HEADERS++;
		} elsif ( /^[[:space:]]*$/ ) {
			$BC++;
			$EMPTY++;
			if ($BC < $SPACE) {
				if ($TITLE eq "") {
					$BUFFER[$I] = $_;
					$I++;
				} else {
					print;
				}
			}
		} elsif ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>Page<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[1-9][0-9]*<\/span>.*/ ) {
			# IRIX Footer
			# OpenGL Footer
			$LAST = $_;
			$FOOTERS++;
			if ($FOOTER > 1) {
				print;
			}
		} elsif ( /[[:space:]]*Page [1-9][0-9]*[[:space:]]*[(]printed [1-9][0-9]*\/[1-3]*[0-9]\/[1-9][0-9][)]/ ) {
			# Motif pages footer
			#     Page 45                                         (printed 4/30/98)
			$LAST = $_;
			$FOOTERS++;
			if ($FOOTER > 1) {
				print;
			}
		} elsif ( /[[:space:]]*<span [-a-zA-Z0-9=":;]*>Page<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[1-9][0-9]*<\/span>.*/ ) {
			# OpenGL Footer
			#                                                                        <span style="font-weight:bold;">Page</span> <span style="font-weight:bold;">2</span>
			$LAST = $_;
			$FOOTERS++;
			if ($FOOTER > 1) {
				print;
			}
		} elsif ( /<\/pre>/ ) {
			$PRE = 0;
			if ($FOOTER == 1) {
				print $LAST;
			}
			print "<!-- Rendered by irix-cat2html.sh: HEADERS: $HEADERS FOOTERS: $FOOTERS EMPTY: $EMPTY LINKS: $LINKS -->\n";
			print;
		} elsif ( /[a-zA-Z][a-zA-Z_\.]*[(][1-9][a-zA-Z]*[)][^<]/ ) {
			$LINKS += s/([a-zA-Z][a-zA-Z_\.]*)[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$2&$ROUTE[2]$1">$1($2)<\/a>/g;
			$BC = 0;
			print;
		} elsif ( /<span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z]*<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z]*<\/span>[(][1-9][a-zA-Z]*[)]/ ) {
			#
			# example
			# <span style="text-decoration:underline;font-weight:bold;">rsh</span><span style="text-decoration:underline;">_</span><span style="text-decoration:underline;font-weight:bold;">bsd</span>(1C))
			#
			$LINKS += s/<span [-a-zA-Z0-9=":;]*>([a-zA-Z][a-zA-Z\.]*)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$3&$ROUTE[2]$1_$2">$1_$2($3)<\/a>/g;
			$BC = 0;
			# print "DBG>> MATCHED: XX_XX(nX)";
			print;
		} elsif ( /<span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z\.]*<\/span>[(][1-9][a-zA-Z]*[)]/ ) {
			$LINKS += s/(<span [-a-zA-Z0-9=":;]*>)([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$3&$ROUTE[2]$2">$2($3)<\/a>/g;
			# s/(<span [-a-zA-Z0-9=":;]*>)([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/ !DBG! @1='$1' @2='$2' @3='$3' !! /g
			$BC = 0;
			# print "DBG>> MATCHED: XX(nX)";
			print;
		} else {
			if ($TITLE eq "") {
				$BUFFER[$I] = $_;
				$I++;
			} else {
				if ($DISCARD == 0) {
					print;
				}
			}		
			$BC = 0;
		}
	} else {
		if ( /<title>[a-zA-Z][-a-zA-Z0-9_]*([(][1-9][a-zA-Z][)])*<\/title>/ ) {
			if ($TITLE ne "") {
				print "<title>$TITLE</title>\n"
			} else {
				$BUFFER[$I] = $_;
				$I++;
			}
		} elsif ( /<pre[-a-zA-Z0-9=":; ]*>/ ) {
			$PRE = 1;
			if ($TITLE eq "") {
				$BUFFER[$I] = $_;
				$I++;
			} else {
				print;
			}		
			$BC = 0;
		} else {
			if ($DISCARD == 0) { 
				if ($I > 0 && $TITLE eq "") {
					$BUFFER[$I] = $_;
					$I++;
				} else {
					print;
				}
			}
		}
	}
}

if ($TITLE eq "") {
	print STDERR "Error - Reached EoF and no Header detected, likley new page type!";
	exit 1;
}
