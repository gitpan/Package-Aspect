package Package::Aspect::Customized_Settings::Dot_Def;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Recognizer
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $subroutine_library = '::Subroutine_Library');
#        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer;
use Package::Aspect::Customized_Settings::Default::Fixed_String_Set_1ofN;
use Package::Aspect::Customized_Settings::Default::Fixed_String_Set_MofN;
use Package::Aspect::Customized_Settings::Default::Here;
use Package::Aspect::Customized_Settings::Default::Number;
use Package::Aspect::Customized_Settings::Default::Numeric_Range;
use Package::Aspect::Customized_Settings::Default::RGB;
use Package::Aspect::Customized_Settings::Default::String_plain;
use Package::Aspect::Customized_Settings::Default::Table_Indexed;
use Package::Aspect::Customized_Settings::Default::Table_Simple_Array;
use Package::Aspect::Customized_Settings::Default::Table_Simple_Hash;
use Package::Aspect::Customized_Settings::Default::Time_Duration;
use Package::Aspect::Customized_Settings::Default::Variable_String_Set;
use Package::Aspect::Customized_Settings::Default::Yes_No;
#use Package::Aspect::Customized_Settings::Default::Directory;
#use Package::Aspect::Customized_Settings::Default::File;
#use Package::Aspect::Customized_Settings::Default::String_acl;

use Package::Aspect::Customized_Settings::Collection;

sub THIS() { 0 }

sub ATR_DEFAULTS() { 0 }
sub ATR_CANDIDATES() { 1 }

sub _init {
	my ($this, $collection, $file_names, $caller, $visit_point, $isa) = @_;

	$this->[ATR_DEFAULTS] = undef;
	my $candidates = $this->[ATR_CANDIDATES] = [$this];
	$collection->{$caller->[0]} = $this;

	foreach my $pkg_name (@$isa) {
		next unless(exists($collection->{$pkg_name}));
		push(@$candidates, $collection->{$pkg_name});
	}

	return unless(defined($caller->[1]));

	my $pkg_file_base = $caller->[1];
	$pkg_file_base =~ s/\.\w+$//s;
	my $raw = "$pkg_file_base.def";
	$this->_init_defaults($raw);

	my $defaults = $this->[ATR_DEFAULTS];
	foreach my $file_name (@$file_names) {
#		print STDERR "fn: $file_name\n";
#		Carp::confess($raw);
		$defaults->file_configuration($file_name);
	}

	return;
}

sub _init_defaults {
	my ($this, $pkg_file_base) = @_;

	$pkg_file_base =~ s/\.\w+$//s;

	my $raw = "$pkg_file_base.def";
	my $compiled = "$raw.pl";
	if (-f $compiled) {
		if ((stat($raw))[9] <= (stat($compiled))[9]) {
			my $rv = do($compiled);
			if (defined($rv)) {
				if (ref($rv) eq ref($this)) {
					$this->[ATR_DEFAULTS] = $rv;
					return;
				}
			}
			Carp::confess($!, $rv);
		}
	}

	$this->parse_defaults_file($raw);

	if (-w $compiled) {
		fs_file_write_contents(
			$compiled,
			Dumper($this->[ATR_DEFAULTS])
			);
	}

	return;
}

sub parse_defaults_file {
	my ($this, $file_name) = @_;

	fs_file_read_contents(
		$file_name,
		my $buffer);
	if ($buffer =~ m,\n\t,s) {
		Carp::confess("File '$file_name' has tab stops at beginning of a line - can't handle that.");
	}
	my @lines = split(/\r?\n/, $buffer);
	my $default = undef;
	my $defaults = $this->[ATR_DEFAULTS] =
		Package::Aspect::Customized_Settings::Collection->new($file_name);
	$defaults->_unlock;
	my $i = 0;
	my $region = undef;
	my $indentation = undef;
	foreach my $line (@lines) {
		$i += 1;
		next if ($line =~ m/^#/);
		next if ($line =~ m/^\s*$/);

		if ($line =~ m/^\!/s) {
			Carp::confess("Policies are not implemented, yet.");
		}
		if ($line =~ m/^\+(\w+)[\s\t]*$/s) {
			my $name = $1;
			if (defined($region)) {
				$default->parse_default($region);
				$region = undef;
			}

			foreach my $candidate (@{$this->[ATR_CANDIDATES]}) {
				next unless(exists($candidate->{$name}));
				$default = $candidate->{$name};
				last;
			}
			unless (defined($default)) {
				Carp::confess("No default named '$name'.");
			}

			$defaults->{$name} = $default->clone;
			$default = undef;
			next;
		}
		if ($line =~ s/^(\w+)([\s\t]+)//s) {
			my $name = $1;
			$indentation = length($1) + length($2);
			$default->parse_default($region) if (defined($region));

			$default = oo_new_dynamic(
				$this->recognize($line));
			if ($default->multi_line) {
				$region = [$line];
			} else {
				$default->parse_default($line);
				$region = undef;
			}
			$defaults->{$name} = $default;
			next;
		}
		if (defined($region)) {
			if (substr($line, 0, 1) eq ' ') {
				push(@$region, substr($line, $indentation));
			} else {
				Carp::confess("Syntax error in line $i ('$line') of file '$file_name'.");
			}
		}
	}
	$default->parse_default($region) if (defined($region));
	$defaults->_lock;

	return;
}

sub collection {
	return($_[THIS][ATR_DEFAULTS]);
}

1;
