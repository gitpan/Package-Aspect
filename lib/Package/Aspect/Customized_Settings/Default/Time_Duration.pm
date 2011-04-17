package Package::Aspect::Customized_Settings::Default::Time_Duration;

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
	('^\d+[\s\t]*(s|m|h|d|w)(econds|ours|inutes|ays|eeks)?');

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
	my $value = 0;
	while ($_[P_DATA] =~ s/^(\d+)[\s\t]*(s|m|h|d|w)(?:econds?|inutes?|ours?|ays?|eeks?)?[\s\t]*//si) {
		if ($2 eq 's') {
			$value += $1;
		} elsif ($2 eq 'm') {
			$value += $1 *60;
		} elsif ($2 eq 'h') {
			$value += $1 *3600;
		} elsif ($2 eq 'd') {
			$value += $1 *86400;
		} elsif ($2 eq 'w') {
			$value += $1 *7*86400;
		}
	}
	$_[THIS][ATR_VALUE] = $value;

	if (length($_[P_DATA])) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$_[P_DATA]],
			undef);
	}

	return;
}

#my $spec = '1day 10s  1 minutes 0h 0d';
#my $setting = __PACKAGE__->new($spec);
#$setting->parse_default($spec);
#use Data::Dumper;
#print STDERR Dumper($setting);

1;
