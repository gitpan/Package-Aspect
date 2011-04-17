package Package::Aspect::Customized_Settings::Default::Here;

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
	(q{^<<--+});

sub multi_line { 1 }

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_VALUE() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_VALUE] = undef;

	return;
}

my $re = '^<<--+[\s\t]*';
sub P_DATA() { 1 }
sub parse_config {
	my $start = shift(@{$_[P_DATA]});
	unless ($start =~ m,$re,s) {
		$localized_messages->carp_confess(
			'error_invalid_default',
			[$start, $re],
			undef);
	}
	$_[THIS][ATR_VALUE] = join("\n", @{$_[P_DATA]});

	return;
}

#some_setting <<--------------------
#	     first line
#	     second line
#	     third line
#some_setting <<--------------------
#	     first line
#	     second line
#	     third line

#my $data = [
#	q{<<------------},
#	q{First Line},
#	q{Second Line},
#	q{Third Line}];
#my $setting = __PACKAGE__->new();
#$setting->parse_default($data);
#print STDERR Dumper($setting);

1;
