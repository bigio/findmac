#!/usr/bin/perl -w

# ex:ts=8 sw=4:

# autoflush buffer
$| = 1;

use strict;

use FindBin;
use lib ("$FindBin::Bin");

use Getopt::Std;
use LWP::UserAgent;
use DBI;

use oui::parse;

my $GRABURL = "http://standards.ieee.org/develop/regauth/oui/oui.txt";
my $ouifile;
my %opts = ();
my $txt_ouifile;
my $offline = 0;
my @a_oui;

my $tbdb = 'oui.sqlite';
my $conn;
my $query;
my $mac;
my $brand;
my $descr;
my $tot_id;

getopts('h', \%opts);
if ( defined $opts{'h'} ) {
	print "Usage: populatedb.pl [text file]\n";
	exit;
} else {
	# The first parameter is the file to parse
	# if not specified it will grab the data from the ieee site
	$ouifile = shift;
}

if ( defined $ouifile ) {
	print "Using $ouifile as input\n";
	$offline = 1;
}

if ( !$offline ) {
	# Create a user agent object
	my $ua = LWP::UserAgent->new;
	$ua->agent("findmac/0.1");

	# Create a request
	my $req = HTTP::Request->new(GET => $GRABURL);

	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);

	# Check the outcome of the response
	if ($res->is_success) {
		$txt_ouifile = $res->content;
	} else {
		die $res->status_line, "\n";
	}
} else {
	open(my $fh, $ouifile) or die "Can't open $ouifile: $!";

	while ( ! eof($fh) ) {
		defined( $_ = <$fh> )
			or die "readline failed for $ouifile: $!";
		$txt_ouifile .= $_;
	}
}
@a_oui = &oui::parse::parse_text($txt_ouifile);
if ( ! -f $tbdb ) {
	my $sql_create = "CREATE TABLE oui (
		id INTEGER PRIMARY KEY,
		mac TEXT NOT NULL,
		brand TEXT NOT NULL,
		descr TEXT NULL
		);";
	$conn = DBI->connect("DBI:SQLite:database=$tbdb",{RaiseError => 1});
	$query = $conn->do("$sql_create");
}

if ( !$conn ) {
	$conn = DBI->connect("DBI:SQLite:database=$tbdb",{RaiseError => 1});
}
$conn->begin_work();

my $sql_del = qq(DELETE FROM oui; VACUUM;);
$query = $conn->do($sql_del);

for my $id ( 1 .. @a_oui ) {
	my ($mac, $brand, $descr) = ($a_oui[$id]{'MAC'}, $a_oui[$id]{'BRAND'}, $a_oui[$id]{'DESCR'});
	if ( not defined $descr ) {
		$descr = "";	
	}
	if ( defined $mac ) {
		$query = $conn->prepare("INSERT INTO oui (id, mac, brand, descr) VALUES (?, ?, ?, ?);");
		$query->execute($id, $mac, $brand, $descr);
		if ( ( $id % 100 ) eq 0 ) {
			print ".";
		}
		$tot_id++;
	}
}
print "\n";
$conn->commit();
$conn->disconnect();
print "Database $tbdb populated with $tot_id records\n";
