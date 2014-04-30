#!/usr/bin/perl -w

# ex:ts=8 sw=4:

use strict;

package oui::parse;

sub parse_text() {
my $oui_text = shift;
my $count = 0;
my @a_oui;

my @lines = split (/\n/, $oui_text);
foreach my $value ( @lines ) {
	if ( $value =~ /hex/ )  {
		$a_oui[$count]{'MAC'} = substr($value,2, 8);
		$a_oui[$count]{'BRAND'} = substr($value, 20);
		$count++;
	}
	if ( $value =~ /\t\t\t/ ) {
		$a_oui[$count]{'DESCR'} .= substr( $value, 4);
		$a_oui[$count]{'DESCR'} =~ s/\t//g;
		$a_oui[$count]{'DESCR'} .= "\n";
	}
}
return @a_oui;
}

1;
