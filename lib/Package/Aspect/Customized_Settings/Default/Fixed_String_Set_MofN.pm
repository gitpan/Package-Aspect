package Package::Aspect::Customized_Settings::Default::Fixed_String_Set_MofN;

use strict;
use warnings;
use Carp qw();
#use Data::Dumper;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
	Package::Aspect::Customized_Settings::Default::_Tabular
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	('^\[(_|x)\]');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_SET() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_SET] = {};

	return;
}

sub reset {
	my $set = $_[THIS][ATR_SET];
	foreach my $key (keys(%$set)) {
		$set->{$key} = 0;
	}
	foreach my $key (@{$_[THIS][ATR_DEFAULT]}) {
		$set->{$key} = 1;
	}
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		{%{$this->[ATR_SET]}}];
	bless($clon, ref($this));
	$clon->_lock();

	$_[THIS]->reset;

	return($clon);
}

my $re = '^[\s\t]*\[(x|_)\][\s\t]+(\S+)';
sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[$_[P_DATA]],
			undef);
	}
	$this->[ATR_DEFAULT] = [];
	foreach (@{$_[P_DATA]}) {
		unless (m/$re/si) {
			$localized_messages->carp_confess(
				'error_invalid_default',
				[$_, $re],
				undef);
		}
		if ($1 eq 'x') {
			push(@{$this->[ATR_DEFAULT]}, $2);
			$this->[ATR_SET]{$2} = 1;
		} else {
			$this->[ATR_SET]{$2} = 0;
		}
	}

	return;
}

sub parse_config {
	my @keys = split(',', $_[P_DATA]);
	foreach my $key (@keys) {
		$key =~ s/^(\+|\-|)//s;
		my $action = $1;
		unless (exists($_[THIS][ATR_SET]{$key})) {
			$localized_messages->carp_confess(
				'error_invalid_attribute',
				[$key],
				undef);
		}
		$_[THIS][ATR_SET]{$key} = ($action eq '-') ? 0 : 1;
	}

	return;
}

sub THAT() { 1 }
sub inherit {
	while (my ($key, $value) = each(%{$_[THAT][ATR_SET]})) {
		next unless ($value);
		next unless (exists($_[THIS][ATR_SET]{$key}));
		$_[THIS][ATR_SET]{$key} = $value;
	}
}

sub selected_keys {
	return(keys(%{$_[THIS][ATR_SET]}));
}

sub P_KEY() { 1 }
sub key_selected {
	return(exists($_[THIS][ATR_SET]{$_[P_KEY]})
		and $_[THIS][ATR_SET]{$_[P_KEY]});
}

#my $data = ['[_] first', '[x] second', '[_] third'];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config('-second,third,first');
#print STDERR Dumper($setting);

1;

