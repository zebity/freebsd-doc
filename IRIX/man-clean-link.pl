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

my $LINENO = 0;
my $PRE = 0;
my $IS = "IRIX";
my $HEADERS = 0;
my $FOOTERS = 0;
my $EMPTY = 0;
my $LAST = "";
my $BC = 0;
my $LINKS = 0;
my $CHECK = 0;
my $TITLE = "";
my $HEADER = 1;
my $FOOTER = 1;
my $HEADER_SEARCH = 1;
my $FOOTER_SEARCH = 1;
my $DISCARD = 0;
my $HINT = "V";
my $CASE = "";
my $FILE = "";
my $HOME = "http://help.graphica.com.au/irix-6.5.30/";
# my @ROUTE = ( "man?", "section=", "page=", "&" );
my @ROUTE = ( "man/", "", "", "/" );
my @HDRRES = ();

my @BUFFER = ();
my $I = 0;
my $J = 0;
my $SZ = 0;

sub IS_HEADER {
	#
	# Styled IRIX Header / Generic Header - Match Cases
        # 
	# <span style="font-weight:bold;">ttdbserverd(8)</span>                                                  <span style="font-weight:bold;">ttdbserverd(8)</span>
	# <span style="font-weight:bold;">ASSERT(D3)</span>                                                          <span style="font-weight:bold;">ASSERT(D3)</span>
	# OpenGL Header
	# <span style="font-weight:bold;">glBegin(3G)</span>                    <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Reference</span>                    <span style="font-weight:bold;">glBegin(3G)</span>
	#      <span style="font-weight:bold;">BUILDPPD(1M)</span>    <span style="font-weight:bold;">K-Spool</span> <span style="font-weight:bold;">by</span> <span style="font-weight:bold;">Xinet</span> <span style="font-weight:bold;">(10/14/99</span> <span style="font-weight:bold;">10.1)</span>     <span style="font-weight:bold;">BUILDPPD(1M)</span>
	# Maths Lib Header
	# <span style="font-weight:bold;">DLAED1(3F)</span>                                                          <span style="font-weight:bold;">DLAED1(3F)</span>
	# UNIX System V Headers
	#     <span style="font-weight:bold;">mwm(1X)</span>                   <span style="font-weight:bold;">UNIX</span> <span style="font-weight:bold;">System</span> <span style="font-weight:bold;">V</span>                   <span style="font-weight:bold;">mwm(1X)</span>
	# Printing Tools
	# <span style="font-weight:bold;">ACCEPT(1M)</span>                      <span style="font-weight:bold;">Printing</span> <span style="font-weight:bold;">Tools</span>                      <span style="font-weight:bold;">ACCEPT(1M)</span> 
	# OpenGL Header
	# <span style="font-weight:bold;">glBegin(3G)</span>                    <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Reference</span>                    <span style="font-weight:bold;">glBegin(3G)</span>
	# ManD
	# <span style="font-weight:bold;">ASSERT(D3)</span>                                                          <span style="font-weight:bold;">ASSERT(D3)</span>

	my @RES = (0, "", "");
	my @PS = ();
	my @PARTSA = ();
	my @PARTSB = ();
	my $TMP = $_;
	my @MATCHES = $TMP =~ /<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>/g ;

	if ((0+@MATCHES) == 2 && ($MATCHES[0] eq $MATCHES[1])) { 

		@PS = $MATCHES[0] =~ /([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])/g ; 
		$RES[0] = 1;
		if ($TITLE ne "") {
			$RES[1] = $TITLE;
		} elsif ($CASE eq "LC") {
			$RES[1] = lc($PS[0]) . $PS[1];
		} elsif ($CASE eq "UC") {
			$RES[1] = uc($PS[0]) . $PS[1];
		} else {
			$RES[1] = $MATCHES[0];	
		}
		$RES[2] = "IRIX/Generic";
		# DBG
		# print STDERR "DBG>> IRIX / Generic Header check: M[0]='$MATCHES[0]' M[1]='$MATCHES[1]'.";
	}	
	if ($RES[0] != 1) {
		#
		# Plain 2 x name(section) case 
		# a.out Header
		# A.OUT(3)A.OUT(3)

		$TMP = $_;
		@MATCHES = $TMP =~ /[a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)]/g ;

		if ((0+@MATCHES) == 2 && $MATCHES[0] eq $MATCHES[1]) {
			@PS = $MATCHES[0] =~ /([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])/g ; 
			$RES[0] = 1;
			if ($TITLE ne "") {
				$RES[1] = $TITLE;
			} elsif ($CASE eq "LC") {
				$RES[1] = lc($PS[0]) . $PS[1];
			} elsif ($CASE eq "UC") {
				$RES[1] = uc($PS[0]) . $PS[1];
			} else {
				$RES[1] = $MATCHES[0];	
			}
			$RES[2] = "Plain";
			# DBG
			# print STDERR "DBG>> Generic / Plain Header check: M[0]='$MATCHES[0]' M[1]='$MATCHES[1]'.";
		}
	}
	if ($RES[0] != 1) {
		#
		# Single name(section) header - compare with $TITLE or $FILE
		#
	        #                                      <span style="font-weight:bold;">SoPointLightDragger(3IV)</span>

		$TMP = $_;
		@PS = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>[[:space:]]*$/ ;

		if ((0+@PS) == 2 && (lc($PS[0] . $PS[1]) eq lc($TITLE) || lc($PS[0]) eq lc($FILE))) {

			$RES[0] = 1;
			if ($TITLE ne "") {
				$RES[1] = $TITLE;
			} elsif ($CASE eq "LC") {
				$RES[1] = lc($PS[0]) . $PS[1];
			} elsif ($CASE eq "UC") {
				$RES[1] = uc($PS[0]) . $PS[1];
			} else {
				$RES[1] = $PS[0] . $PS[1];	
			}
			$RES[2] = "Single";
			# DBG
			# print STDERR "DBG>> Generic / Plain Header check: M[0]='$MATCHES[0]' M[1]='$MATCHES[1]'.";
		}
	}
	if ($RES[0] != 1) {
		#
		# Single name(section) header - with label
		#
		# <span style="font-weight:bold;">glCopyConvolutionFilter1DEXT(3G)</span>                              <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Reference</span>
		# <span style="font-weight:bold;">pfDoubleSCS(3pf)</span>              <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Performer</span> <span style="font-weight:bold;">3.2.2</span> <span style="font-weight:bold;">libpf</span> <span style="font-weight:bold;">C++</span> <span style="font-weight:bold;">Reference</span> <span style="font-weight:bold;">Pages</span>
		# <span style="font-weight:bold;">glcMeasureCountedString(3G)</span>                          <span style="font-weight:bold;">OpenGL</span> <span style="font-weight:bold;">Character</span> <span style="font-weight:bold;">Renderer</span>

		$TMP = $_;
		@PS = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>OpenGL<\/span>.*(Reference|Renderer).*<\/span>.*$/ ;
		# @PS = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>[[:space:]]*.*OpenGL.*(Reference|Renderer).*$/ ;
		# DBG
		# $SZ = (0+@PS); 
		# print STDERR "DBG>> IS_HEADER SZ=$SZ PS='@PS' TITLE='$TITLE' FILE='$FILE'.";
		if ((0+@PS) == 3) {

			$RES[0] = 1;
			if ($TITLE ne "") {
				$RES[1] = $TITLE;
			} elsif ($CASE eq "LC") {
				$RES[1] = lc($PS[0]) . $PS[1];
			} elsif ($CASE eq "UC") {
				$RES[1] = uc($PS[0]) . $PS[1];
			} else {
				$RES[1] = $PS[0] . $PS[1];	
			}
			$RES[2] = "Single/Labeled";
			# DBG
			# print STDERR "DBG>> Generic / Plain Header check: M[0]='$MATCHES[0]' M[1]='$MATCHES[1]'.";
		}
	}
	if ($RES[0] != 1) {
		#
		# What!! Header
		#
		#      <span style="font-weight:bold;">SSH-PKCS11-HELPE</span>R(8) <span style="font-weight:bold;">System</span> <span style="font-weight:bold;">V</span> <span style="font-weight:bold;">(February</span> <span style="font-weight:bold;">10</span> <span style="font-weight:bold;">20</span>10<span style="font-weight:bold;">H</span>)<span style="font-weight:bold;">PKCS11-HELPER(8)</span>
		#      <span style="font-weight:bold;">glutChangeToMenuEntry(3GLUT)GLUT</span> <span style="font-weight:bold;">(3.6</span>)<span style="font-weight:bold;">lutChangeToMenuEntry(3GLUT)</span>
		#      <span style="font-weight:bold;">glutExtensionSupported(3GLUT</span>)<span style="font-weight:bold;">LUT</span> <span style="font-weight:bold;">(3 </span>6)<span style="font-weight:bold;">utExtensionSupported(3GLUT)</span>
		#      <span style="font-weight:bold;">XtRegisterGrabAction</span>(<span style="font-weight:bold;">3</span>Xt)<span style="font-weight:bold;">sion</span> <span style="font-weight:bold;">11</span> <span style="font-weight:bold;">(Releas</span>e<span style="font-weight:bold;">t</span>6.6)<span style="font-weight:bold;">sterGrabAction(3Xt)</span>
		#      <span style="font-weight:bold;">XtGetSubresources(3X</span>t<span style="font-weight:bold;">)Version</span> <span style="font-weight:bold;">11</span> <span style="font-weight:bold;">(Release</span> <span style="font-weight:bold;">6</span>.6)<span style="font-weight:bold;">etSubresources(3Xt)</span>
		#      <span style="font-weight:bold;">XtGetSelectionParame</span>t<span style="font-weight:bold;">e</span>rs(3Xt) <span style="font-weight:bold;">11</span> <span style="font-weight:bold;">(Re</span>lease<span style="font-weight:bold;">S</span>6.6)<span style="font-weight:bold;">tionParameters(3Xt)</span>
		#      <span style="font-weight:bold;">XmClipboardInquireLength(3</span>X)<span style="font-weight:bold;">IX</span> <span style="font-weight:bold;">SystemX</span>V<span style="font-weight:bold;">ClipboardInquireLength(3X)</span>
		#
		# 3 Variants:
		#  1 - NAME(SECTION)    NAME(SECTION)
		#  2 - NAMEA(SECTION)   NAMEB(SECTION) - Treat as case 3
                #  3 - NAME(SECTION)
		#

		my $WHAT = 0;
		my $TEST = 0;
		my $TRY = "";
		do {
			$TMP = $_;
			if ($TEST == 0) { 
				#SSH...</span>R(8) <span...>
				@MATCHES = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*)<\/span>([-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])[[:space:]]*<span [-a-zA-Z0-9=":;]*>System.*V<\/span>.*$/g ;
				if ((0+@MATCHES) == 2) {
					$TRY = $MATCHES[0] . $MATCHES[1];
				}
			} elsif ($TEST == 1) {
				# General (cs|Dt|ftn|flt|glut|Sg|Xt|Xm)name(sec)
                                $TMP =~ s/<span [-a-zA-Z0-9=":;]*>//g ;
                                $TMP =~ s/<\/span>//g ; 
                                @MATCHES = $TMP =~ /^[[:space:]]*(cs|Dt|ftn|flt|glut|Xt|Xm)([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)]).*$/g ;
				if ((0+@MATCHES) == 2 ) {
					$TRY = $MATCHES[0] . $MATCHES[1];
				}
				$SZ = (0+@MATCHES);
				# DBG
				# print STDERR "DBG>> IS_HEADER - What (Xt|Xm): TMP='$TMP' SZ='$SZ' MATCHES='@MATCHES'.";
			} elsif ($TEST == 2) {
				# XtRegister
				$TMP =~ s/<span [-a-zA-Z0-9=":;]*>//g ;
				$TMP =~ s/<\span>//g ; 
				@MATCHES = $TMP =~ /^[[:space:]]*(Xt|Xm)([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)]).*$/g ;
				if ((0+@MATCHES) == 4 ) {
					$TRY = $MATCHES[0] . $MATCHES[1] . $MATCHES[2] . $MATCHES[3];
				}
			} elsif ($TEST == 3) {
				# XtGetSub...R
				@MATCHES = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*)<\/span>([a-zA-Z1-9]*)<span [-a-zA-Z0-9=":;]*>([)])[A-Za-z]*<\span>[[:space:]]<span [-a-zA-Z0-9=":;]*>.*<\/span>[[:space:]]*$/g ;
				if ((0+@MATCHES) == 3 ) {
					$TRY = $MATCHES[0] . $MATCHES[1] . $MATCHES[2];
				}
			} elsif ($TEST == 4) {
				# XmC... (3</span>X)
				@MATCHES = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z])<\/span>([a-zA-Z1-9]*[)])<span [-a-zA-Z0-9=":;]*>.*System.*V.*<\/span><span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>[[:space:]]*$/g ;
				if ((0+@MATCHES) == 3) {
					$TRY = $MATCHES[0] + $MATCHES[1];
				}
			} elsif ($TEST == 5) {
				#(3GLUT)GLUT
				@MATCHES = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])[a-zA-Z]*<\/span>.*$/g ;
				if ((0+@MATCHES) == 1) {
					$TRY = $MATCHES[0];
				}
			} elsif ($TEST == 6) {
				# (3GLUT</span>)
				@MATCHES = $TMP =~ /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>([a-zA-Z][-_\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*)<\/span>([)])<span [-a-zA-Z0-9=":;]*>.*<\/span>[[:space:]]*$/g ;
				if ((0+@MATCHES) == 2) {
					$TRY = $MATCHES[0];
				}
			}
			$SZ = (0+@MATCHES);
			# DBG
			# print STDERR "DBG>> IS_HEADER - What: SZ=$SZ MATCHES='@MATCHES'.";
			if ($TRY ne "") {
				@PS = $TRY =~ /([a-zA-Z][-_\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])/ ;
			}
			if (($TRY ne "" && (0+@PS) == 2) && (lc($TRY) eq lc($TITLE) || lc($PS[0]) eq lc($FILE))) {

				$WHAT = 1;
				$RES[0] = 1;
				if ($TITLE ne "") {
					$RES[1] = $TITLE;
				} elsif ($CASE eq "LC") {
					$RES[1] = lc($PS[0]) . $PS[1];
				} elsif ($CASE eq "UC") {
					$RES[1] = uc($PS[0]) . $PS[1];
				} else {
					$RES[1] = $PS[0] . $PS[1];	
				}
				$RES[2] = "What/Labeled";
				# DBG
				# print STDERR "DBG>> What Header check: PS[0]='$PS[0]' PS[1]='$PS[1]'.";
			} else {
				$TEST++;
				if ($TEST > 6) {
					$WHAT = 1;
				}
			}
		} while ($WHAT != 1);
	}
	if ($RES[0] != 1) { 
		#
		# IRIX Decorated underscore
		# <span style="font-weight:bold;">cl</span><span style="text-decoration:underline;">_</span><span style="font-weight:bold;">init(1M)</span>                                                        <span style="font-weight:bold;">cl</span><span style="text-decoration:underline;">_</span><span style="font-weight:bold;">init(1M)</span>

		$TMP = $_;
		@MATCHES = $TMP =~ /<span [-a-zA-Z0-9=":;]*>[a-zA-Z]*<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>[-\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)]<\/span>/g ;

		if ((0+@MATCHES) == 2) {

			@PARTSA = $MATCHES[0] =~ /<span [-a-zA-Z0-9=":;]*>([a-zA-Z]*)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>([-\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>/ ;
			@PARTSB = $MATCHES[1] =~ /<span [-a-zA-Z0-9=":;]*>([a-zA-Z]*)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>([-\.a-zA-Z0-9]*[(][1-9a-zA-Z][a-zA-Z1-9]*[)])<\/span>/ ;

			#
			# Double check it is a header ie 2 x nam1_mam2(section)
			#
			if ($PARTSA[0] eq $PARTSB[0] && $PARTSA[1] eq $PARTSB[1]) {
				$RES[0] = 1;

				my @PPS = $PARTSA[1] =~ /([-\.a-zA-Z0-9]*)([(][1-9a-zA-Z][a-zA-Z1-9]*[)])/ ; 
				if ($TITLE ne "") {
					$RES[1] = $TITLE;
				} elsif ($CASE eq "LC") {
					$RES[1] = lc($PS[0] . "_" . $PPS[0]) . $PPS[1];
				} elsif ($CASE eq "UC") {
					$RES[1] = uc($PS[0] . "_" . $PPS[0]) . $PPS[1];
				} else {
					$RES[1] = $PS[0] . $PS[1];	
				}
				$RES[2] = "IRIX/Decorated";	
				# DBG
				# print STDERR "DBG>> IRIX / Decorated Header check: P[0]='$PARTSA[0]' P[1]='$PARTSA[1]'.";
			}
		}
	}
	return @RES ;
}

sub IS_FOOTER {
	my $RES = 0;
	#
	# IRIX Footer
	# OpenGL Footer
	if ( /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>Page<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[1-9][0-9]*<\/span>[[:space:]]*$/ ) {
		$LAST = $_;
		$FOOTERS++;
		$RES = 1;
	} elsif ( /^[[:space:]]*Page [1-9][0-9]*[[:space:]]*[(]printed [1-9][0-9]*\/[1-3]*[0-9]\/[0-9]*[)][[:space:]]*$/ ) {
		# Motif pages footer
		#     Page 45                                         (printed 4/30/98)
		$LAST = $_;
		$FOOTERS++;
		$RES = 1;
	} elsif ( /^[[:space:]]*<span [-a-zA-Z0-9=":;]*>Page<\/span>[[:space:]]*<span [-a-zA-Z0-9=":;]*>[1-9][0-9]*<\/span>[[:space:]]*/ ) {
			# OpenGL Footer
			#                                                                        <span style="font-weight:bold;">Page</span> <span style="font-weight:bold;">2</span>
		$LAST = $_;
		$FOOTERS++;
		$RES = 1;
	} elsif ( ($IS eq "Plain" || $IS eq "Single") && /^[[:space:]]*Page[[:space:]]*[1-9][0-9]*[[:space:]]*$/ ) {
		# Generic minimal Footer
		# Page 1
		$LAST = $_;
		$FOOTERS++;
		$RES = 1;
	}
	# DBG
	# if ($RES == 1) {
	#	print STDERR "DBG>> IS_FOOTER LINE='$_$'.";
	#}
	return $RES;
}

sub BUFFER_OR_PRINT_LINE {
	if ($TITLE eq "") {
		$BC = 0;
		$BUFFER[$I] = $_;
		$I++;
	} else {
		print;
	}
}

sub PRINT_BUFFER {
	for (; $J < $I; $J++) {
		print $BUFFER[$J];
	}
	$I = 0;
}

my $IN = *STDIN;

my $ARG = shift;

while ($ARG) {
	if ($ARG eq "-c") {
		$HINT = shift;
	} elsif ($ARG eq "-d") {
		$DISCARD = 1;
	} elsif ($ARG eq "-f") {
		$FOOTER = shift;
	} elsif ($ARG eq "-h") {
		$HEADER = shift;
	} elsif ($ARG eq "-r") {
		@ROUTE = shift;
	} elsif ($ARG eq "-s") {
		$SPACE = shift;
	} elsif ($ARG eq "-t") {
		$TITLE = shift;
	} elsif ($ARG eq "-u") {
		$HOME = shift;
	} else {
		print STDERR "Usage: $ARGV[0] [-c CASE-HINT] [-d == DISCARD] [-f FOOTER=(0|1|2) ] [-h HEADER=(0|1|2)] [-r ROUTE=('base', 'section', 'page')] [-s SPACE] [-t TITLE] [-u URL-HOME]";
	}
	$ARG = shift;
}


if ($HINT ne "V") {
	$FILE = $HINT;
	if ( $HINT eq lc($HINT) ) {
		$CASE = "LC";
	} elsif ( $HINT eq uc($HINT) ) {
		$CASE = "UC";
	} else {
		$CASE="V";
	}
	# DBG
	# print STDERR "DBG>> Setting HINT='$HINT' FILE='$FILE' CASE='$CASE'";
}

while (<$IN>) {

	$LINENO++;

	if ($PRE == 1) {

		@HDRRES = IS_HEADER();
		if ($HDRRES[0] == 1) {
			if ($TITLE eq "") {
			  $J++;
			  $TITLE = $HDRRES[1];
			  $IS = $HDRRES[2];
			  print "<title>$TITLE</title>\n";
			  PRINT_BUFFER();
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
				BUFFER_OR_PRINT_LINE();
			}
		} elsif (IS_FOOTER() == 1) {
			$LAST = $_;
			if ($FOOTER > 1 && $DISCARD == 0) {
				BUFFER_OR_PRINT_LINE();
				$BC = 0;
			}
		} elsif ( /<\/pre>/ ) {
			$PRE = 0;
			if ($TITLE eq "") {
				$J = 0;
				if ($FILE eq "") {
					$FILE = "UNTITLED." . $$ . "(U1)";
				} else {
					$FILE = $FILE . "(U1)";
				}
				$TITLE = $FILE;
				$J++;
				print "<title>$TITLE</title>\n";
				PRINT_BUFFER();
			}
			if ($FOOTER == 1) {
				print $LAST;
			}
			print "<!-- Rendered by irix-cat2html.sh: IS: '$IS' HEADERS: $HEADERS FOOTERS: $FOOTERS EMPTY: $EMPTY LINKS: $LINKS -->\n";
			print;
		} elsif ( /[a-zA-Z][a-zA-Z_\.]*[(][1-9][a-zA-Z]*[)][^<]/ ) {
			$LINKS += s/([a-zA-Z][a-zA-Z_\.]*)[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$2$ROUTE[3]$ROUTE[2]$1">$1($2)<\/a>/g;
			$BC = 0;
			BUFFER_OR_PRINT_LINE();
		} elsif ( /<span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z]*<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z]*<\/span>[(][1-9][a-zA-Z]*[)]/ ) {
			#
			# example
			# <span style="text-decoration:underline;font-weight:bold;">rsh</span><span style="text-decoration:underline;">_</span><span style="text-decoration:underline;font-weight:bold;">bsd</span>(1C))
			#
			$LINKS += s/<span [-a-zA-Z0-9=":;]*>([a-zA-Z][a-zA-Z\.]*)<\/span><span [-a-zA-Z0-9=":;]*>_<\/span><span [-a-zA-Z0-9=":;]*>([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$3$ROUTE[3]$ROUTE[2]$1_$2">$1_$2($3)<\/a>/g;
			$BC = 0;
			# print "DBG>> MATCHED: XX_XX(nX)";
			BUFFER_OR_PRINT_LINE();
		} elsif ( /<span [-a-zA-Z0-9=":;]*>[a-zA-Z][a-zA-Z\.]*<\/span>[(][1-9][a-zA-Z]*[)]/ ) {
			$LINKS += s/(<span [-a-zA-Z0-9=":;]*>)([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/<a href="$HOME$ROUTE[0]$ROUTE[1]$3$ROUTE[3]$ROUTE[2]$2">$2($3)<\/a>/g;
			# s/(<span [-a-zA-Z0-9=":;]*>)([a-zA-Z][a-zA-Z\.]*)<\/span>[(]([1-9][a-zA-Z]*)[)]/ !DBG! @1='$1' @2='$2' @3='$3' !! /g
			$BC = 0;
			# print "DBG>> MATCHED: XX(nX)";
			BUFFER_OR_PRINT_LINE();
		} else {
			if ($DISCARD == 0) {
				BUFFER_OR_PRINT_LINE();
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
			BUFFER_OR_PRINT_LINE();
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
