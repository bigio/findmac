#!/usr/bin/perl

#------------------------------------------------------------------------------
# Copyright (c) 2014,2016, Giovanni Bechis
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#------------------------------------------------------------------------------

use strict;
use warnings;

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
$mac = shift;
if ( ( defined $opts{'h'} ) || ( not defined $mac ) ) {
        print "Usage: findmac.pl macaddress [database file]\n";
        exit;
} else {
        # The first parameter is the file to parse
        # if not specified it will use the default oui.sqlite database
        $db = shift;
	if ( defined $db ) {
		$tbdb = $db;
	}
}
$macbrand = &oui::parse::parse_mac($mac);

if ( ! -f $tbdb ) {
	die("Database $tbdb not found.");
}
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
