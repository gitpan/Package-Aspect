package Package::Aspect::Subroutine_Library::Shelf;
use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
	my $localized_messages = '::Localized_Messages');
#,	my $customized_settings = '::Customized_Settings');

sub _localized_messages { return($localized_messages); }

my $fs_fd_binmode_os = 0;
sub _fs_fd_binmode_os() { return($fs_fd_binmode_os); }

my $fs_namespace_separator = undef;
my $sub_eval_shift0 = sub{eval shift};


package Package::Aspect::Subroutine_Library;
use strict;
use warnings;
use Carp qw();
use parent qw(
	Object::By::Array
);

our $VERSION = '0.01';

our $DEBUG ||= 0;
Internals::SvREADONLY($DEBUG, 1);
sub DEBUG() { $DEBUG };

sub debug_print($;) {
	print STDERR join("\t", __PACKAGE__, time, @_, '.')."\n";
}

my $sub_eval_shift1 = $sub_eval_shift0;
undef $sub_eval_shift0;
my %PACKAGES = ();

my $autoload = '*AUTOLOAD = \&Package::Aspect::Subroutine_Library::AUTOLOAD;';

$fs_fd_binmode_os = ($^O =~ m/^(dos|mswin|cygwin|netware|os2|vms)/si)
	? 1
	: 0;
$fs_namespace_separator = ($^O =~ m/^(dos|mswin|os2)/si)
	? '\\'
	: '/';

sub THIS() { 0 };
sub P_MESSAGE_COLLECTION() { 1 };
sub localized_messages {
	if(defined($localized_messages)) {
		Carp::confess('Message collection already set.');
	}
	$localized_messages = $_[P_MESSAGE_COLLECTION];
}

sub P_CALLER() { 1 };
sub P_VISIT_POINT() { 2 };
sub P_ISA() { 3 };
sub extend($;) {
	my ($this, $caller, $visit_point, $isa) = @_;

	debug_print("Package '$caller->[0]' is being extended.")
		if(DEBUG);

	if(exists($PACKAGES{$caller->[0]})) {
		Carp::confess("Package '$caller->[0]' already registered with Package::Subroutine_Library.\n");
	}

	local($@);
	$_[P_VISIT_POINT]->($autoload);
	Carp::confess($@) if($@);
	$PACKAGES{$caller->[0]} = $_[P_VISIT_POINT];

	return(undef);
}

sub fs_file_read_contents {
        unless (open(F, '<', $_[0])) {
		Carp::Confess("$_[0]: open: $!");
	}
	if($fs_fd_binmode_os) {
		binmode(F);
	}
        read(F, $_[1], (stat(F))[7]);
        close(F);
	return;
}


our $AUTOLOAD;
sub AUTOLOAD {
	if(defined(&$AUTOLOAD)) {
		Carp::confess("AUTOLOAD called although '$AUTOLOAD' exists. Did you call AUTOLOAD explicitly?\n");
	}

	unless ($AUTOLOAD =~ m,^(?:([\w\:]+)(::))?(\w+)$,,) {
		Carp::confess("\$AUTOLOAD is the invalid value '$AUTOLOAD'.\n");
	}
	my ($pkg_name, $sub_name) = ($1, $3);
	return if($sub_name eq 'DESTROY');

	my $caller0 = (caller)[0];
	if(DEBUG) {
		require Scalar::Util;
		if($pkg_name ne $caller0) {
			if(Scalar::Util::blessed($_[0])) {
				debug_print("Looks like AUTOLOAD is called to create a method.");
			} else {
				debug_print("Ooops, an unidentified case.");
			}
		}
	}

	debug_print("Package '$pkg_name' needs the subroutine '$sub_name'.")
		if(DEBUG);

	my $sub_library = "Package::Aspect::Subroutine_Library::Shelf\::$sub_name";

	if(defined(&$sub_library)) {
		debug_print("Subroutine '$sub_name' already on the shelf.")
			if(DEBUG);
		goto &$sub_library;;
	} else {
		debug_print("Putting subroutine '$sub_name' on the shelf.")
			if(DEBUG);
	}

	my $code = "require 'Package/Aspect/Subroutine_Library/$sub_name.pl'";

	local($@);
	$sub_eval_shift1->($code);
	Carp::confess($@) if($@);
	unless(defined(&$sub_library)) {
		Carp::confess("The file 'Package/Aspect/Subroutine_Library/$sub_name.pl' was loaded, but it did not result in a subroutine named '$sub_name'.");
	}
	goto &$sub_library;
}

sub check_syntax() {
	my @files = ();

# build a list of all .pl files, then strip base name
# check for conflicts
# load all .pl files
}
check_syntax() if($^C);

1;
