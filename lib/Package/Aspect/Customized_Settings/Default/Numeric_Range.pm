package Package::Aspect::Customized_Settings::Default::Numeric_Range;

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
	('^(\+|\-)?[\d\.]+<');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }
sub ATR_CHECKER() { 2 }

sub _init {
	my ($this) = @_;

        $this->[ATR_DEFAULT] = undef;
        $this->[ATR_VALUE] = undef;
        $this->[ATR_CHECKER] = undef;

	return;
}

sub P_LOWER() { 1 };
sub P_UPPER() { 4 };
sub compile_checker {
	my @checks = ();
	if (defined($_[P_UPPER])) {
		push(@checks,
			sprintf('($_[0] %s %s)', $_[3], $_[P_UPPER]));
	}
	if (defined($_[P_LOWER])) {
		push(@checks,
			sprintf('(%s %s $_[0])', $_[P_LOWER], $_[2]));
	}
	my $subroutine = 'sub { return('. join(' and ', @checks). ') }';
	local($@);
	my $checker = eval $subroutine;
	Carp::confess($@) if ($@);
	return($checker);
}

my $re = '^((?:\+|\-)?\d+\.?\d*)(<=?)((?:\+|\-)?\d+\.?\d*)(<=?)((?:\+|\-)?\d+\.?\d*)$';
sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[$_[P_DATA]],
			undef);
	}
	unless ($_[P_DATA] =~ m/$re/sio) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA], $re],
			undef);
	}
	my $value = $this->[ATR_DEFAULT] = $this->[ATR_VALUE] = $3;
	if ($1 > $5) {
		$localized_messages->carp_confess(
			'error_invalid_limit',
			[$1, $5],
			undef);
	}

	my $checker = $this->[ATR_CHECKER] = $this->compile_checker($1, $2, $4, $5);;
	unless ($checker->($value)) {
		$localized_messages->carp_confess(
			'error_invalid_limit',
			[$value, $1, $5],
			undef);
	}

	return;
}

sub parse_config {
	unless ($_[THIS][ATR_CHECKER]->($_[P_DATA])) {
		$localized_messages->carp_confess(
			'error_invalid_limit',
			[$_[P_DATA], $1, $5],
			undef);
	}
	$_[THIS][ATR_VALUE] = $_[P_DATA];

	return;
}

sub check {
	return($_[THIS][ATR_CHECKER]->($_[P_DATA]));
}

#my $setting = __PACKAGE__->new;
#$setting->parse_default('155<66<=77');
#print STDERR Dumper($setting);

1;
