package Package::Aspect::Customized_Settings;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Dot_Def;

my @SEARCH_PATH = ();

sub THIS() { 0 }

sub ATR_PACKAGES() { 0 }

sub P_CLASS() { 0 }
sub _init {
	$_[THIS][ATR_PACKAGES] = {};
}

sub P_CALLER() { 0 } # because of shift
sub extend {
	my $this = shift;

	my $pkg_name = $_[P_CALLER][0];
	my @file_names = ();
#	print STDERR Dumper(\@SEARCH_PATH);
	foreach my $directory (@SEARCH_PATH) {
		my $file_name = "$directory/$pkg_name.cfg";
#		print STDERR "fn: $file_name\n";
		next unless (-f $file_name);
		push(@file_names, $file_name);
	}

	my $pkg = Package::Aspect::Customized_Settings::Dot_Def->new(
		$this->[ATR_PACKAGES], \@file_names, @_);
	my $collection = $pkg->collection;
	$this->[ATR_PACKAGES]{$pkg_name} = $collection;
	return($collection);
}

#sub export_messages {
#	my @collection = ();
#	foreach my $message (@{$_[THIS][ATR_MESSAGES]}) {
#		push(@collection, [$message->[0], $message->[1]->as_hashref]);
#	}
#	return(\@collection);
#}

sub import {
	my $class = shift;

	foreach my $directory (@_) {
		next if(-d $directory);
		# can't use $localized_messages, yet
		Carp::confess("The directory '$directory' from the search path does not exist.");
	}
	push(@SEARCH_PATH, @_);

	return;
}

1;
