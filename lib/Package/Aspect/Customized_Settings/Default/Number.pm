package Package::Aspect::Customized_Settings::Default::Number;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

my $number_re = '^((?:\+|\-)?\d+(?:\.\d*))';

use Package::Aspect::Customized_Settings::Recognizer
	($number_re);

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

sub _init {
	$_[THIS][ATR_DEFAULT] = undef;
	$_[THIS][ATR_VALUE] = undef;

	return;
}

sub P_DATA() { 1 }
sub parse_config {
	unless ($_[P_DATA] =~ m/$number_re/sio) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA], $number_re],
			undef);
	}
	$_[THIS][ATR_VALUE] = $1;

	return;
}

#my $setting = __PACKAGE__->new();
#$setting->parse_default(-55.4);
#$setting->parse_config(+66.3);
#print STDERR Dumper($setting);

1;

