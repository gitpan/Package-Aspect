#!/usr/bin/perl -W -T

use strict;
use warnings;
use Data::Dumper;
#use Test::Simple tests => 0;

use Package::Aspect::Customized_Settings
	('/tmp/pasp');
use Mica;
use Package::Aspect sub{eval shift};

Package::Aspect::reservation(
	my $customized_settings = '::Customized_Settings',
	my $dbh = '::DBH');
Package::Aspect::complete();

#print STDERR Dumper($dbh);

exit(0);
