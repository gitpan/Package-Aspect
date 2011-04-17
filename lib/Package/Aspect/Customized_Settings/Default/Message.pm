package Package::Aspect::Customized_Settings::Default::Message;

use strict;
use warnings;
#use Carp qw();
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
	Package::Aspect::Customized_Settings::Default::_Table
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	('^:o-o:$');

sub multi_line { 1 }

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_TRANSLATIONS() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_TRANSLATIONS] = {};

	return;
}

sub reset {
	$_[THIS][ATR_TRANSLATIONS] = {};
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		{%{$this->[ATR_TRANSLATIONS]}}];
	bless($clon, ref($this));
	$clon->_lock();

	$this->reset;

	return($clon);
}

sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[$_[P_DATA]],
			undef);
	}
	$this->[ATR_DEFAULT] = 1;

	$this->parse_lines($_[P_DATA]);
	return;
}

sub P_LINES() { 1 }
sub parse_lines {
	my ($this) = @_;

#FIXME: do something here
#		if($global eq ':') { # now :o-o:
#			$localized_messages->add($name, $setting);
##			push(@settings, [$name, $setting]);
#		}

	return;
}

sub parse_config {
	my ($this) = @_;

	if (ref($_[P_DATA]) eq ref($this)) {
		return($this->inherit($_[P_DATA]));
	}
	$this->parse_lines($_[P_DATA]);

	return;
}

sub THAT() { 1 }
sub inherit {
	while (my ($key, $value) = each(%{$_[THAT][ATR_TRANSLATIONS]})) {
		next unless (exists($_[THIS][ATR_TRANSLATIONS]{$key}));
		$_[THIS][ATR_TRANSLATIONS]{$key} = $value;
	}
	return;
}

sub P_KEY() { 1 }
sub lookup {
	return unless (exists($_[THIS][ATR_TRANSLATIONS]{$_[P_KEY]}));
	return($_[THIS][ATR_TRANSLATIONS]{$_[P_KEY]});
}

sub P_KEYS() { 1 }
sub lookup_first {
	foreach my $key (@{$_[P_KEYS]}) {
		next unless (exists($_[THIS][ATR_TRANSLATIONS]{$key}));
		return($_[THIS][ATR_TRANSLATIONS]{$key});
	}
	return;
}

sub as_hash {
	return($_[THIS][ATR_TRANSLATIONS]);
}

#my $data = [
#];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config(q{});
#use Data::Dumper;
#print STDERR Dumper($setting);

1;

