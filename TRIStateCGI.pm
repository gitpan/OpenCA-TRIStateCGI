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

package OpenCA::TRIStateCGI;

use CGI;

@ISA = ( "CGI" );
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
$VERSION = '1.02';


# Preloaded methods go here.

## General Functions
sub status {
	my $self = shift;
	my @keys;
	@par = $self->param;
	$i = @par;

     	$ret = $self->param('status');
     	if ( $ret =~ /(client\-filled\-form|client\-confirmed\-form)/ ) {
		return $ret;
	} else {
        	return "start";
	};
}

## New AutoChecking Input Object

sub newInput {

	my $self = shift;
	my @keys;
	my $ret;
	@keys = @_;

	## Get all the Checking and Input Data
	my($type,$maxlen,$minlen,$regx) = 
		$self->rearrange([INTYPE,MAXLEN,MINLEN,REGX],@keys);
     
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
	my @keys;
	my $ret;
	@keys = @_;

	my($type,$maxlen,$minlen,$regx,$name) = 
		$self->rearrange([INTYPE,MAXLEN,MINLEN,REGX,NAME],@keys);

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
     
	$m = "[a-zA-Z\ ]+" if ( "$regx" eq "LETTERS" );
	$m = "[a-zA-Z\ \,\.\_\:\'\`\\\/\(\)\!\;]+" if ( "$regx" eq "TEXT" );
	$m = "[0-9]+" if ( "$regx" eq "NUMERIC" );
	$m = "[a-zA-Z0-9\ \,\.\_\:\'\`\\\/\(\)\!\;]+" if ( "$regx" eq "MIXED" );
	$m = "[0-9\-\/]+" if ( "$regx" eq "DATE" );
	$m = "[0-9\-\+]+" if ( "$regx" eq "TEL" );
	$m = "[0-9a-zA-Z\_\.]+@[a-zA-Z0-9\.\-]+" if ( "$regx" eq "EMAIL" );
	$m = "[a-zA-Z\ À-ÿ]+" if ( "$regx" eq "LATIN1_LETTERS" );

	$p =~ s/$m//g;

	if ( length($p) == 0 ) {
		$ret = "<BR>(OK)<BR>";
	} else {
		$ret = "Error. ";
		$ret .= "Use only chars" if ( $regx eq "TEXT" );
		$ret .= "Use only numbers" if ( $regx eq "NUMERIC" );
		$ret .= "Usa only chars./numbers" if ( $regx eq "MIXED" );
		$ret .= "Use xx\/xx\/xxxx format." if ( $regx eq "DATE" );
		$ret .= "Use ++xx-xxx-xxxxxx format." if ( $regx eq "TEL" );
		$ret .= 'Use aabbcc@dddd.eee.ff' if ( $regx eq "EMAIL" );

		$ret = "<BR><FONT COLOR=RED>$ret</FONT><BR>"; 
	}
	return $ret;
}

sub checkForm {

	my $ret ="";
	
	$ret .= $signed->newInputCheck( %par1 );
	$ret .= $signed->newInputCheck( %par2 );
	$ret .= $signed->newInputCheck( %par3 );
	$ret .= $signed->newInputCheck( %par4 );
	$ret .= $signed->newInputCheck( %par5 );
	$ret .= $signed->newInputCheck( %par6 );
	$ret .= $signed->newInputCheck( %par7 );

	$m = "<BR>|OK|[\ \(\)]";
	$ret =~ s/$m//g;

	## print "<!----$ret----!>";
	return $ret;
};

sub printError {
	my $self = shift;
	my $ret;
	my @keys;
	@keys = @_;

	$errCode = $keys[0];
	$errTxt  = $keys[1];

	$html = $self->start_html(-title=>'Error Accessing the Service',
		-author=>'CGI manager <madwolf@comune.modena.it>',
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
		$html .= "General Error Protection Fault : The Error Could not be determined by the server,\n";
		$html .= "if the error persists, please contact the system administrator for further explanation.<BR><BR>\n";
		$html .= "Errore di Protezione Generale : Non e\' stato possibile determinare l\'errore verificatosi,\n";
		$html .= "se questa condizione dovesse persistere siete pregati di contattare l\'amministratore di sistema\n";
		$html .= "per maggiori informazioni<BR><BR>\n";
	};

	$html .= "</FONT><BR>\n\n";
	$html .= "</BODY></HTML>\n\n";
        
	return $html;
}

## New TRIState Specific Functions
## ===============================
sub getFile {
	my $self = shift;
	my $ret;
	my @keys;
	@keys = @_;

	open( FD, $keys[0] ) || return;
	while ( $temp = <FD> ) {
		$ret .= $temp;
	};
	return $ret;
}


sub subVar {
	my $self = shift;
	my $ret;
	my @keys;
	@keys = @_;

	$text    = $keys[0];
	$parname = $keys[1];
	$var     = $keys[2];

	$match = "\\$parname";
	$text =~ s/$match/$var/g;

	return $text;
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

Sorry, no description available

=head1 AUTHOR

Massimiliano Pala (madwolf@openca.org)

=head1 SEE ALSO

perl(1).

=cut

