## OpenCA::TRIStateCGI.pm 
##
## Copyright (C) 1998-1999 Massimiliano Pala (madwolf@openca.org)
## All rights reserved.
##
## This library is free for commercial and non-commercial use as long as
## the following conditions are aheared to.  The following conditions
## apply to all code found in this distribution, be it the RC4, RSA,
## lhash, DES, etc., code; not just the SSL code.  The documentation
## included with this distribution is covered by the same copyright terms
## 
## Copyright remains Massimiliano Pala's, and as such any Copyright notices
## in the code are not to be removed.
## If this package is used in a product, Massimiliano Pala should be given
## attribution as the author of the parts of the library used.
## This can be in the form of a textual message at program startup or
## in documentation (online or textual) provided with the package.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 1. Redistributions of source code must retain the copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. All advertising materials mentioning features or use of this software
##    must display the following acknowledgement:
##    "This product includes OpenCA software written by Massimiliano Pala
##     (madwolf@openca.org) and the OpenCA Group (www.openca.org)"
## 4. If you include any Windows specific code (or a derivative thereof) from 
##    some directory (application code) you must include an acknowledgement:
##    "This product includes OpenCA software (www.openca.org)"
## 
## THIS SOFTWARE IS PROVIDED BY OPENCA DEVELOPERS ``AS IS'' AND
## ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
## FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
## OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
## LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
## OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.
## 
## The licence and distribution terms for any publically available version or
## derivative of this code cannot be changed.  i.e. this code cannot simply be
## copied and put under another distribution licence
## [including the GNU Public Licence.]
##

## Porpouse :
## ==========
##
## Build a class to use with tri-state CGI (based on CGI library)
##
## Project Status:
## ===============
##
##      Started		: 8 December 1998
##      Last Modified	: 29 April 1999

use strict;

package OpenCA::TRIStateCGI;

use CGI;

@OpenCA::TRIStateCGI::ISA = ( @OpenCA::TRIStateCGI::ISA, "CGI" );
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

$OpenCA::TRIStateCGI::VERSION = '1.3.0a';


# Preloaded methods go here.

## General Functions
sub status {
	my $self = shift;
	my @keys = @_;

     	my $ret = $self->param('status');
     	if ( $ret =~ /(client\-filled\-form|client\-confirmed\-form)/ ) {
		return $ret;
	} else {
        	return "start";
	};
}

## New AutoChecking Input Object

sub newInput {

	my $self = shift;
	my @keys = @_;

	my ( $ret, $error, $m );

	## Get all the Checking and Input Data
	my($type,$maxlen,$minlen,$regx) = 
		$self->rearrange(["INTYPE","MAXLEN","MINLEN","REGX"],@keys);
     
	## Get the actual Value
	## my($value) = $self->rearrange([VALUE],@keys);

	## Check if there is an Error
	$error = $self->newInputCheck(@_) if ( $self->status ne "start" ); 

	## Generate the Input Type
	$ret = $self->$type(@_);
     
	## Clean Out NON HTML TAGS
	$m = "(INTYPE|MAXLEN|MINLEN|REGX)=\".*\"";
	$ret =~ s/$m//g;
     
	## Concatenate the Error to the Input Object if present
	$ret .= $error;
     
	return $ret;
}

sub newInputCheck {

	my $self = shift;
	my @keys = @_;

	my ( $ret, $m, $p, $l );

	my($type,$maxlen,$minlen,$regx,$name) = 
		$self->rearrange(["INTYPE","MAXLEN","MINLEN","REGX","NAME"],
									@keys);

	$p = $self->param("$name");

	if( $maxlen != "" ) {
		$l = length($p);
		if ( $l > $maxlen ) {
			$ret = "Error (max. $maxlen)";
			$ret = "<BR><FONT COLOR=RED>$ret</FONT><BR>";
			return $ret;
		}
	};

	if( $minlen != "" ) {
		$l = length($p);
		if ( $l < $minlen ) {
			$ret = "Error (min. $minlen)";
			$ret = "<BR><FONT COLOR=RED>$ret</FONT><BR>";
			return $ret;
		}
	};

	if ( length($regx) < 2 ) {
		return $ret;
	};
 
	$m = $regx; 
     
	$m = "[a-zA-Z\ ¡-ÿ]+" if ( "$regx" eq "LETTERS" );
	## $m = "[a-zA-Z\ \,\.\_\:\'\`\\\/\(\)\!\;]+" if ( "$regx" eq "TEXT" );
	$m = "[ -\@a-zA-Z]+" if ( "$regx" eq "TEXT" );
	$m = "[0-9]+" if ( "$regx" eq "NUMERIC" );
	$m = "[ -\@a-zA-Z]+" if ( "$regx" eq "MIXED" );
	$m = "[0-9\-\/]+" if ( "$regx" eq "DATE" );
	$m = "[0-9\-\+\\\(\)]+" if ( "$regx" eq "TEL" );
	$m = "[0-9a-zA-Z\-\_\.]+\@[a-zA-Z0-9\_\.\-]+" if ( "$regx" eq "EMAIL" );
	$m = "[a-zA-Z¡-ÿ -\@]+" if ( "$regx" eq "LATIN1_LETTERS" );
	$m = "[ -\@a-zA-Z¡-ÿ]+" if ( "$regx" eq "LATIN1" );

	$p =~ s/$m//g;

	if ( length($p) == 0 ) {
		$ret = "<BR>(OK)<BR>";
	} else {
		$ret .= "Use only chars" if ( $regx eq "TEXT" );
		$ret .= "Use only LATIN1 chars" if ($regx eq "LATIN1_LETTERS");
		$ret .= "Use only LATIN1 chars/numbers" if ( $regx eq "LATIN1");
		$ret .= "Use only numbers" if ( $regx eq "NUMERIC" );
		$ret .= "Use only chars./numbers" if ( $regx eq "MIXED" );
		$ret .= "Use xx\/xx\/xxxx format." if ( $regx eq "DATE" );
		$ret .= "Use ++xx-xxx-xxxxxx format." if ( $regx eq "TEL" );
		$ret .= 'Use aabbcc@dddd.eee.ff' if ( $regx eq "EMAIL" );
		$ret = "Undefined Error" if ($ret eq "");

		$ret = "<BR><FONT COLOR=RED>Error. $ret</FONT><BR>"; 
	}
	return $ret;
}

sub checkForm {

	my $self = shift;
	my @keys = @_;

	my ( $ret, $in, $m );
	
	for $in ( @keys ) {
		$ret .= $self->newInputCheck( %$in );
	}

	$m = "<BR>|OK|[\ \(\)]";
	$ret =~ s/$m//g;

	return $ret;
};

sub printError {
	my $self = shift;
	my @keys = @_;

	my ( $html, $ret );

	my $errCode = $keys[0];
	my $errTxt  = $keys[1];

	$html = $self->start_html(-title=>'Error Accessing the Service',
		-BGCOLOR=>'#FFFFFF');

	$html .= '<FONT FACE=Helvetica SIZE=+4 COLOR="#E54211">';
	## $html .= $self->setFont( -size=>'+4',
	## 	-face=>"Helvetica",
	## 	-color=>'#E54211');

	$html .= "Error ( code $errCode )";
	$html .= "</FONT><BR><BR>\n";
	
	$html .= '<FONT SIZE=+1 COLOR="#113388">';
	## $html .= $self->setFont( -size=>'+1',
	## 	-color=>'#113388');

	if( "$errTxt" ne "" ) {
		## The Error Code is Present in the Array, so Let's treat it...
		$html .= $errTxt;

	} else {
		## General Error Message 
		$html .= "General Error Protection Fault : The Error Could" .
			 " not be determined by the server,<BR>";
		$html .= "if the error persists, please contact the system" .
			 " administrator for further explanation.<BR><BR>\n";
	};

	$html .= "</FONT><BR>\n\n";
	$html .= "</BODY></HTML>\n\n";
        
	return $html;
}

sub getFile {
	my $self = shift;
	my @keys = @_;

	my ( $ret, $temp );

	open( FD, $keys[0] ) || return;
	while ( $temp = <FD> ) {
		$ret .= $temp;
	};
	return $ret;
}

sub subVar {
	my $self = shift;
	my @keys = @_;

	my ( $text, $parname, $var, $ret, $match );

	$text    = $keys[0];
	$parname = $keys[1];
	$var     = $keys[2];

	$match = "\\$parname";
	$text =~ s/$match/$var/g;

	return $text;
}

sub startTable {
	my $self = shift;
	my $keys = { @_ };

	my $width      = $keys->{WIDTH};

	my $titleColor = $keys->{TITLE_COLOR};
	my $cellColor  = $keys->{CELL_COLOR};

	my $titleBg    = $keys->{TITLE_BGCOLOR};
	my $tableBg    = $keys->{TABLE_BGCOLOR};
	my $cellBg     = $keys->{CELL_BGCOLOR};
	my $spacing    = "1";

	my @cols = @{ $keys->{COLS} };

	my ( $ret, $name );

	$width      = "100%" if (not $width);
	$cellColor  = "#000000" if ( not $cellColor );

	$titleBg   = "#DDDDEE" if ( not $titleBg );
	$cellBg    = "#FFFFFF" if ( not $cellBg );

	if( $tableBg ) {
		my $spacing = "1";
	};

	my $titleFont = "FONT FACE=Helvetica,Arial";
	$titleFont .= " color=\"$titleColor\"" if( $titleColor );
	
	$ret =  "<TABLE BORDER=0 WIDTH=\"$width\" CELLPADDING=1 CELLSPACING=0 ";
	$ret .= "BGCOLOR=\"#000000\"" if ( $tableBg );
	$ret .= "><TR><TD>\n";

	$ret .= "<TABLE BORDER=0 WIDTH=\"100%\" CELLPADDING=2 BGCOLOR=$cellBg";
	$ret .= " CELLSPACING=\"$spacing\" FGCOLOR=\"$cellColor\">\n";
	$ret .= "<TR BGCOLOR=\"$titleBg\">\n";

	foreach $name (@cols) {
		$ret .= "<TD><$titleFont><B>$name</B></FONT></TD>\n";
	}

	$ret .= "</TR>\n";

	return $ret;
}

sub addTableLine {
	my $self = shift;
	my $keys = { @_ };

	my @data    = @{ $keys->{DATA} };
	my $bgColor = $keys->{BGCOLOR};
	my $color   = $keys->{COLOR};

	my ( $val, $colorEnd, $ret );
	
	if( $bgColor ) {
		$ret = "<TR BGCOLOR=$bgColor>\n";
	} else {
		$ret = "<TR>\n";
	}

	if( $color ) {
		$color = "<FONT COLOR=\"$color\">";
		$colorEnd = "</FONT>";
	}

	foreach $val ( @data ) {
		$ret .= "<TD>$color $val $colorEnd</TD>\n";
	}
	$ret .= "</TR>\n";

	return $ret;
}

sub endTable {
	my $self = shift;
	my $ret;

	$ret = "</TABLE></TD></TR></TABLE><P>\n";

	return $ret;
}

sub printCopyMsg {
	my $self = shift;
	my @keys = @_;
	my $ret;

	my $msg = $keys[0];

	$msg = "&copy 1998 by OpenCA Group" if ( not $msg );
	$ret = "<CENTER><BR>$msg<BR><CENTER>";

	return $ret;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

OpenCA::TRIStateCGI - Perl extension for implementing 3-state Input Objs.

=head1 SYNOPSIS

  use OpenCA::TRIStateCGI;

=head1 DESCRIPTION

Sorry, no description available. Currently implemented methods derives
mostly from the CGI.pm module, please take a look at that docs. Added
methods are:

	status        -
	newInput      -
	newInputCheck -
	checkForm     -
	startTable    -
	addTableLine  -
	endTable      -
	printCopyMsg  -
	printError    -

Deprecated methods (better use the OpenCA::Tools corresponding methods
instead) are:

	subVar        -
	getFile       -
	

=head1 AUTHOR

Massimiliano Pala (madwolf@openca.org)

=head1 SEE ALSO

CGI.pm, OpenCA::Configuration, OpenCA::OpenSSL, OpenCA::X509, OpenCA::CRL,
OpenCA::REQ, OpenCA::CRR, OpenCA::Tools

=cut

