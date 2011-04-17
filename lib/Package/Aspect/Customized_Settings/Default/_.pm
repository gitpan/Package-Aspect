package Package::Aspect::Customized_Settings::Default::_;

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

sub clone {
	my $clon = [@{$_[THIS]}];
	bless($clon, ref($_[THIS]));
	$clon->_lock();

	$_[THIS]->reset;

	return($clon);
}

sub inherit {}

sub multi_line { 0 }

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
	my $type = ref($this->[ATR_VALUE]);
	if($type eq 'SCALAR') {
		$this->[ATR_DEFAULT] = $this->[ATR_VALUE];
	} elsif($type eq 'ARRAY') {
		@{$this->[ATR_DEFAULT]} = @{$this->[ATR_VALUE]};
	} elsif($type eq 'HASH') {
		%{$this->[ATR_DEFAULT]} = %{$this->[ATR_VALUE]};
	} else {
		Carp::confess("Don't know how to handle type '$type'.");
	}

	return;
}

sub value {
	return($_[THIS][ATR_VALUE]);
}

sub set_value {
	return($_[THIS]->parse_config($_[P_DATA]));
}

1;
