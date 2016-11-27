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
		$a_oui[$count]{'MAC'} = substr($value,0, 8);
		$a_oui[$count]{'BRAND'} = substr($value, 18);
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

sub parse_mac() {
my $mac = shift;
my $macbrand;
my @a_mac;

@a_mac = split(/-/, $mac);
if ( length($a_mac[0]) ne 2 ) {
	@a_mac = split(/:/, $mac);
}
$macbrand = $a_mac[0] . "-" . $a_mac[1] . "-" . $a_mac[2];
$macbrand = uc $macbrand;
return $macbrand;
}

1;
