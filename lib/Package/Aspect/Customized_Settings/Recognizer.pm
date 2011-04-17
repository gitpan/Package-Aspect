package Package::Aspect::Customized_Settings::Recognizer;

use strict;
use warnings;
use Carp qw();
#use Data::Dumper;
use parent qw(
	Object::By::Array
);

my @rules = ();
my $recognizer = sub { 'Package::Aspect::Customized_Settings::Default::_Invalid_' };

sub recognize() { return($recognizer->(@_)) }

sub P_DATA() { 1 }
sub rebuild() {
	my $subroutine = '
sub {
	$_ = $_[P_DATA];
	';

	foreach my $rule (@rules) {
		$subroutine .= "if (m/$rule->[0]/si) {
		return('$rule->[1]');
	} els";
	}

	$subroutine .= 'e {
		return("Package::Aspect::Customized_Settings::Default::_Syntax_Error_");
	}
}
';
	local($@);
	$recognizer = eval $subroutine;
	Carp::confess($@) if ($@);
}

sub P_CLASS() { 0 };
sub P_REGEXP() { 1 };
sub import($$) {
	return unless(defined($_[P_REGEXP]));
	push(@rules, [$_[P_REGEXP], (caller)[0]]);
	rebuild;
	return;
}

1;
