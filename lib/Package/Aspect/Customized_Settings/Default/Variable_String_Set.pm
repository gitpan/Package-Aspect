package Package::Aspect::Customized_Settings::Default::Variable_String_Set;

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
	('^o\s+');

sub multi_line { 1 }

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_SET() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_SET] = [];

	return;
}

sub reset {
	$_[THIS][ATR_SET] = [];
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		[@{$this->[ATR_SET]}]];
	bless($clon, ref($this));
	$clon->_lock();

	$this->reset;

	return($clon);
}

sub P_DATA() { 1 }
sub parse_config {
	my ($this) = @_;

	my $i = -1;
	foreach (@{$_[P_DATA]}) {
		$i += 1;
		unless (m/^o\s+(.*)/sg) {
			$localized_messages->carp_confess(
				'error_invalid_default',
				[$_, __PACKAGE__],
				undef);
		}
		push(@{$this->[ATR_SET]}, $1);
	}

	return;
}

sub P_KEY() { 1 }
sub key_selected {
	return(exists($_[THIS][ATR_SET]{$_[P_KEY]})
		and $_[THIS][ATR_SET]{$_[P_KEY]});
}

#my $data = ['o  first', 'o  second', 'o  third'];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config(['o  first']);
#use Data::Dumper;
#print STDERR Dumper($setting);

1;
