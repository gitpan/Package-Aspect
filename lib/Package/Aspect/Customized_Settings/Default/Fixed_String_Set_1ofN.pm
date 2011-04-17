package Package::Aspect::Customized_Settings::Default::Fixed_String_Set_1ofN;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
	Package::Aspect::Customized_Settings::Default::_Tabular
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	qw('^\((_|\*)\)');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_SET() { 1 }
sub ATR_SELECTED() { 2 }

sub _init {
	my ($this) = @_;

        $this->[ATR_DEFAULT] = undef;
        $this->[ATR_SET] = {};
        $this->[ATR_SELECTED] = undef;

	return;
}

sub reset {
	$_[THIS][ATR_SELECTED] = $_[THIS][ATR_DEFAULT];
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		{%{$this->[ATR_SET]}},
		$this->[ATR_SELECTED]];
	bless($clon, ref($this));
	$clon->_lock();

	$_[THIS]->reset;

	return($clon);
}

sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		Carp::confess('Default already set');
	}
	my $i = -1;
	foreach (@{$_[P_DATA]}) {
		$i += 1;
		unless (m/^[\s\t]*\((\*|_)\)[\s\t]+(\S+)/sig) {
			Carp::confess("Did not recognize $_ in ".__PACKAGE__);
		}

		$this->[ATR_SET]{$2} = $i;
		if ($1 eq '*') {
			if (defined($this->[ATR_DEFAULT])) {
				Carp::confess('Only one member can be selected for 1ofN.');
			}
			$this->[ATR_DEFAULT] = $2;
			$this->[ATR_SELECTED] = $2;
		}
	}

	return;
}

sub parse_config {
	my ($this) = @_;

	unless (exists($this->[ATR_SET]{$_[P_DATA]})) {
		Carp::confess("Key '$_[P_DATA]' doesn't exists.");
	}
	$this->[ATR_SET]{$this->[ATR_SELECTED]} =
		numeric_maximum(values(%{$this->[ATR_SET]}))+1;
	$this->[ATR_SELECTED] = $_[P_DATA];
	$this->[ATR_SET]{$_[P_DATA]} = 1;

	return;
}

sub P_KEY() { 1 }
sub key_selected {
	return(exists($_[THIS][ATR_SET]{$_[P_KEY]})
		and $_[THIS][ATR_SET]{$_[P_KEY]});
}

sub selected_key {
	return($_[THIS][ATR_SELECTED]);
}

sub selected_position {
	return($_[THIS][ATR_SET]{$_[THIS][ATR_SELECTED]});
}

sub P_PREFIX() { 1 }
sub inline_function_code {
	my @pairs = ();
	while (my @pair = each(%{$_[THIS][ATR_SET]})) {
		push(@pairs, \@pair);
	};
	@pairs = sort {$a->[1] <=> $b->[1]} @pairs;
	my $code = join("\n",
		map(sprintf('sub %s%s() { %s }', $_[P_PREFIX], uc($_->[0]), $_->[1]), @pairs));
	return($code);
}

#my $data = ['(_) first', '(*) second', '(_) third'];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config('first');
#print STDERR $setting->inline_function_code('prf_');
#print STDERR Dumper($setting);

1;
