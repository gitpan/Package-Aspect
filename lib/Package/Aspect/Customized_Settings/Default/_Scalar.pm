package Package::Aspect::Customized_Settings::Default::_Scalar;

use strict;
use warnings;
use Carp qw();

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

sub default {
	return($_[THIS][ATR_DEFAULT]);
}

sub reset {
	$_[THIS][ATR_VALUE] = $_[THIS][ATR_DEFAULT];
	return;
}

sub multi_line { 0 }

sub value {
	return($_[THIS][ATR_VALUE]);
}

sub set_value {
	return($_[THIS]->parse_config($_[P_DATA]));
}

1;
