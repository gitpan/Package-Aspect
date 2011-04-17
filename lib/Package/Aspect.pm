package Package::Aspect;

use strict;
use warnings;
use Carp qw();

our $VERSION = '0.01';

our $DEBUG ||= 0;
Internals::SvREADONLY($DEBUG, 1);
sub DEBUG() { $DEBUG };

sub debug_print($;) {
	print STDERR join("\t", __PACKAGE__, time, @_)."\n";
}

my %VISIT_POINTS = ();
my %REGISTERED = ();
my %DEPENDENCIES = ();
my %PENDING = ();
my @AFTER_COMPLETION = ();

sub reservation {
	my @caller = caller;
	debug_print("reservation in '$caller[0]'") if(DEBUG);

	# next three lines duplicate code below
	Carp::confess($caller[0]) unless(exists($VISIT_POINTS{$caller[0]}));
	my $visit_point = $VISIT_POINTS{$caller[0]};
	my $ISA = $visit_point->('our @ISA; return(\@ISA)');

	foreach (@_) {
		Carp::confess('Undefined reservation.') unless(defined($_));
		my $type = $_;
		if(substr($type, 0, 2) eq '::') {
			$type = __PACKAGE__.$type;
		}

		debug_print("reservation for type '$type'.") if(DEBUG);
		if(exists($REGISTERED{$type})) {
			debug_print("confirmed") if(DEBUG);
			$_ = $REGISTERED{$type}->extend(
				\@caller,
				$visit_point,
				$ISA);
		} else {
			unless(exists($PENDING{$type})) {
				$PENDING{$type} = [];
			}
			debug_print("pending") if(DEBUG);
			$DEPENDENCIES{$caller[0]}{$type} = 1;
			push(@{$PENDING{$type}}, [\$_,
				[\@caller,
				$visit_point,
				$ISA]]);
		}
	}

	return;
}

sub provide(@) {
	my @caller = caller;
	debug_print("providing to '$caller[0]'") if(DEBUG);

	# next three lines duplicate code above
	Carp::confess($caller[0]) unless(exists($VISIT_POINTS{$caller[0]}));
	my $visit_point = delete($VISIT_POINTS{$caller[0]});
	my $ISA = $visit_point->('our @ISA; return(\@ISA)');

	my @aspects = ();
	foreach (@_) {
		my $type = $_;
		if(substr($type, 0, 2) eq '::') {
			$type = __PACKAGE__.$type;
		}
		Carp::confess unless(exists($REGISTERED{$type}));
		$type = $REGISTERED{$type};
		push(@aspects, $type->extend(
			\@caller,
			$visit_point,
			$ISA));
	}
	return(@aspects);
}

sub re_import($) {
	my $pkg_name = (caller)[0];
	debug_print("re_import for '$pkg_name'") if(DEBUG);

	$VISIT_POINTS{$pkg_name} = $_[0];
	return;
}

sub P_CLASS() { 0 }
sub P_VISIT_POINT() { 1 }
sub import {
	my $pkg_name = (caller)[0];
	debug_print("import for '$pkg_name'") if(DEBUG);

	if(exists($_[P_VISIT_POINT])) {
		$VISIT_POINTS{$pkg_name} = $_[P_VISIT_POINT];
		return;
	}

	return;
}

sub pending() {
	return(keys(%PENDING));
}

sub dependencies_count {
	(exists($DEPENDENCIES{$a}) ? scalar(keys(%{$DEPENDENCIES{$a}})) : 0)
		<=>
	(exists($DEPENDENCIES{$b}) ? scalar(keys(%{$DEPENDENCIES{$b}})) : 0)
}

sub complete(@) {
	my @pending = sort dependencies_count keys(%PENDING);
	foreach my $type (@pending) {
		debug_print("processing pending '$type'") if(DEBUG);

		unless (exists($REGISTERED{$type})) {
			unless ($type =~ m,^(\w+)(::\w+)+$,s) {
				Carp::confess("Invalid package name '$type'");
			}
			local($@);
			debug_print("use '$type'.") if(DEBUG);
			eval "use $type;";
			Carp::confess($@) if ($@);
#FIXME: namespace "package $type" really available?
			$REGISTERED{$type} = $type->new;
			debug_print("created new object of class '$type'.") if(DEBUG);
		}
		my $aspect = $REGISTERED{$type};

		my $pending = delete($PENDING{$type});
		foreach my $registration (@$pending) {
			my ($var, $args) = @$registration;
			debug_print("attempting to extend '$args->[0][0]'.") if(DEBUG);
			eval { $$var = $aspect->extend(@$args); };
			Carp::confess($@) if ($@);

			debug_print("done.") if(DEBUG);
		}
	}

	foreach my $hook (splice(@AFTER_COMPLETION)) {
		$hook->(@_);
	}
	%DEPENDENCIES = ();
	return;
}

sub after_completion(@) {
	foreach (@_) {
		unless(ref($_) eq 'CODE') {
			Carp::confess("Not a CODE reference");
		}
	}
	push(@AFTER_COMPLETION, @_);
	return;
}

1;
