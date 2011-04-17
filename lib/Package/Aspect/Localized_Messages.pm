package Package::Aspect::Localized_Messages;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
	my $subroutine_library = '::Subroutine_Library');
#,
#	my $customized_settings = '::Customized_Settings');

use Package::Aspect::Localized_Messages::Dot_Msg;

sub THIS() { 0 }

sub ATR_PACKAGES() { 0 }

sub _init {
	$_[THIS][ATR_PACKAGES] = {};
}

sub P_CALLER() { 0 } # because of shift
sub extend {
	my $this = shift;

	my $pkg = Package::Aspect::Localized_Messages::Dot_Msg->new(
		$this->[ATR_PACKAGES], @_);
	$this->[ATR_PACKAGES]{$_[P_CALLER][0]} = $pkg;
	return($pkg);

	return();
}

our $languages = [];
if(exists($ENV{'LANG'})) {
	push(@$languages, $ENV{'LANG'});
	if($ENV{'LANG'} =~ m/^([a-z]+_[a-z]+)\./si) {
		push(@$languages, $1);
	}
	if($ENV{'LANG'} =~ m/^([a-z]+)_/si) {
		push(@$languages, $1);
	}
}

1;
