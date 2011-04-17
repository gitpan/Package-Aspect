use strict;
use warnings;

sub oo_qualify_class {
	my ($base, $class_name) = @_;
	unless ($class_name =~ m,^($base)?(::\w+)+$,s) {
		Carp::confess("Invalid package name '$class_name'");
	}
	if (substr($class_name, 0, 2) eq '::') {
		$class_name = "$base$class_name";
	}
	if ($class_name =~ m,::_\w*$,s) {
		Carp::confess("Package name '$class_name' starts with an underscore, this is not allowed.");
	}

	return($class_name);
}

1;
