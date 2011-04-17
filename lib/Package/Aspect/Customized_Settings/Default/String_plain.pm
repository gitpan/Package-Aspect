package Package::Aspect::Customized_Settings::Default::String_plain;

use strict;
use warnings;
#use Carp qw();
#use Data::Dumper;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	q{^(\'|\"|NULL)};

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_VALUE] = undef;

	return;
}

my $re = '^(?:\'|\")(.*)(?:\'|\")$';
sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[$_[P_DATA]],
			undef);
	}
	$this->parse_config($_[P_DATA]);
	$this->[ATR_DEFAULT] = $this->[ATR_VALUE];

	return;
}

sub parse_config {
	my ($this) = @_;

	if ($_[P_DATA] eq 'NULL') {
		$this->[ATR_VALUE] = undef;
	} elsif ($_[P_DATA] !~ m/$re/si) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA], $re],
			undef);
	} else {
		$this->[ATR_VALUE] = $1;
	}

	return;
}

sub set_value {
	$_[THIS][ATR_VALUE] = $_[P_DATA];
	return;
}

#my $setting = __PACKAGE__->new("'-55.4'");
#print STDERR Dumper($setting);

1;

