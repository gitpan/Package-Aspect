package Package::Aspect::Customized_Settings::Default::RGB;

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

use Package::Aspect::Customized_Settings::Recognizer
	('^\#(\d{3}|\d{6})');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_VALUE] = undef;

	return;
}

my $re = '^\#([\da-f]{6}|[\da-f]{3})$';
sub P_DATA() { 1 }
sub parse_config {
	unless ($_[P_DATA] =~ m/$re/sio) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA], $re],
			undef);
	}
	$_[THIS][ATR_VALUE] = $1;

	return;
}

#my $setting = __PACKAGE__->new;
#$setting->parse_default('#ffee55');
#$setting->parse_config('#1122aa');
#print STDERR Dumper($setting);

1;

