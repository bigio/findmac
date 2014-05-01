#!/usr/bin/perl -w

# ex:ts=8 sw=4:

use strict;

use Getopt::Std;
use DBI;

use FindBin;
use lib ("$FindBin::Bin");

use oui::parse;

my %opts = ();
my $tbdb = 'oui.sqlite';
my $db;
my $mac;
my $macbrand;

my $conn;
my $query;
my @row;
my $descr;

getopts('h', \%opts);
if ( defined $opts{'h'} ) {
        print "Usage: findmac.pl macaddress [database file]\n";
        exit;
} else {
        # The first parameter is the file to parse
        # if not specified it will grab the data from the ieee site
	$mac = shift;
        $db = shift;
	if ( defined $db ) {
		$tbdb = $db;
	}
}
$macbrand = &oui::parse::parse_mac($mac);

$conn = DBI->connect("DBI:SQLite:database=$tbdb",{RaiseError => 1});

$query = $conn->prepare("SELECT id, brand, descr FROM oui WHERE mac = '$macbrand'");
$query->execute();

while (@row = $query->fetchrow_array()) {
        print "Mac address:\t" . $mac . "\n";
	print "Brand:\t\t" . $row[1] . "\n";
	# Format description
	$descr = $row[2];
	$descr =~ s/\n/\n\t\t/g;
	print "Description:\t" . $descr . "\n";
}
$query->finish();
if ( not defined $descr ) {
	warn "No records found, is your mac address correct ?\n";
}
