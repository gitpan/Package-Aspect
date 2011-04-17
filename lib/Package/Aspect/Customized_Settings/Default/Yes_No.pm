package Package::Aspect::Customized_Settings::Default::Yes_No;

use strict;
use warnings;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	('^yes\/no');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

sub _init {
	$_[THIS][ATR_DEFAULT] = undef;
	$_[THIS][ATR_VALUE] = undef;

	return;
}

my $re = '^(yes)\/(no)\$';
sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[],
			undef);
	}
	unless ($_[P_DATA] =~ m/$re/sio) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA], $re],
			undef);
	}
	my ($yes, $no) = ($1, $2);
	if ($yes eq 'YES') {
		$this->[ATR_DEFAULT] = $this->[ATR_VALUE] = 'yes';
	} elsif ($no eq 'NO') {
		$this->[ATR_DEFAULT] = $this->[ATR_VALUE] = 'no';
	} else {
		die;
	}

	return;
}

sub parse_config {
	unless (($_[P_DATA] eq 'yes') or ($_[P_DATA] eq 'no')) {
		$localized_messages->carp_confess(
			'error_invalid_attribute',
			[$_[P_DATA]],
			undef);
	}
	$_[THIS][ATR_VALUE] = $_[P_DATA];

	return;
}

sub is_yes {
	return($_[THIS][ATR_VALUE] eq 'yes');
}

sub is_no {
	return($_[THIS][ATR_VALUE] eq 'no');
}

#my $setting = __PACKAGE__->new();
#$setting->parse_default('YES/no');
#$setting->parse_config('yes');
#$setting->parse_config('no');
#use Data::Dumper;
#print STDERR Dumper($setting);

1;
