package Package::Aspect::Localized_Messages::Dot_Msg;

use strict;
use warnings;
use Carp qw();
use Data::Dumper;
use parent qw(
	Object::By::Array
);

#use Package::Aspect sub{eval shift};
use Package::Aspect sub{my $code = shift; Carp::cluck() unless(defined($code)); eval $code};
Package::Aspect::reservation(
	my $subroutine_library = '::Subroutine_Library');
#,	my $customized_settings = '::Customized_Settings');

sub THIS() { 0 }

sub ATR_MESSAGES() { 0 }
sub ATR_CANDIDATES() { 1 }

#sub P_COLLECTION() { 1 };
#sub P_CALLER() { 2 };
#sub P_VISIT_POINT() { 3 };
#sub P_ISA() { 4 };
sub _init {
	my ($this, $collection, $caller, $visit_point, $isa) = @_;

	my $messages = $this->[ATR_MESSAGES] = {};
	my $candidates = $this->[ATR_CANDIDATES] = [$this];

	if(exists($collection->{$caller->[0]})) {
		Carp::confess("The collection for '$caller->[0]' already exists.");
	}
	$collection->{$caller->[0]} = $this;

	foreach my $pkg_name (@$isa) {
		next unless(exists($collection->{$pkg_name}));
		push(@$candidates, $collection->{$pkg_name});
	}

	return unless(defined($caller->[1]));

	my $pkg_file_base = $caller->[1];
	$pkg_file_base =~ s/\.\w+$//s;

	my $raw = "$pkg_file_base.msg";
	my $compiled = "$pkg_file_base.msg.pl";
	if (-f $compiled) {
		if ((stat($raw))[9] <= (stat($compiled))[9]) {
			my $rv = do($compiled);
			if (defined($rv)) {
				if (ref($rv) eq ref($this)) {
					$this->[ATR_MESSAGES] = $rv;
					return;
				}
			}
			Carp::confess($!, $rv);
		}
	}
	return unless(-f $raw);

	fs_file_read_contents($raw, my $buffer);
	my @lines = split(/\r?\n/, $buffer);
	my $current = '';
	my $languages = undef;
	foreach my $line (@lines) {
		next if ($line =~ m/^#/);
		next if ($line =~ m/^[\s\t]*$/);

		if ($line =~ s/^(\t\t|\s{16})//s) {
			$$current .= "\n$line";
		} elsif ($line =~ m/^(\w+)[\s\t]*(.*)$/s) {
			$languages = {};
			$messages->{$1} = $languages;
		} elsif ($line =~ m/^\@(\w+)[\s\t]*$/s) {
			my $message_name = $1;
#FIXME: some code vanished - this was ready to use
#FIXME: read from which directory?
			my @file_names = grep(/^\w+\.msg$/,
				@{fs_directory_list()});
			foreach my $file_name (@file_names) {
				fs_file_read_contents(
					$file_name,
					$messages->{$message_name});
			}
		} elsif ($line =~ m/^(?:\t|\s{8})(\w+)[\t\s]+(.*)$/s) {
			$current = $languages->{$1} = \(my $dummy = $2);
		}
	}

	if (-w $compiled) {
		fs_file_write_contents(
			$compiled,
			Dumper($this->[ATR_MESSAGES])
			);
	}

	return;
}

sub P_NAME() { 1 }
sub P_VALUE() { 2 }
sub add_message {
	$_[THIS][ATR_MESSAGES]{$_[P_NAME]} = $_[P_VALUE];
}

sub P_DETAILS() { 2 }
sub P_LANGUAGES() { 3 }
sub lookup {
	my ($this, $name, $details, $languages) = @_;

	unless(defined($languages)) {
		$languages = $Package::Aspect::Localized_Messages::languages;
	}

	my $translations;
	foreach my $candidate (@{$this->[ATR_CANDIDATES]}) {
		next unless(exists($candidate->[ATR_MESSAGES]{$_[P_NAME]}));
		$translations = $candidate->[ATR_MESSAGES]{$_[P_NAME]};
		last;
	}
	unless (defined($translations)) {
		Carp::confess("No message named '$_[P_NAME]'.");
	}

	my $message;
	foreach my $language (@{$_[P_LANGUAGES]}) {
		next unless(exists($translations->{$language}));
		$message = $translations->{$language};
		last;
	}

	unless(defined($message)) {
		Carp::confess("Found a message named '$_[P_NAME]' but not in the right language.");
	}

	return(($#{$_[P_DETAILS]} > -1)
		? \sprintf($$message, @{$_[P_DETAILS]})
		: $message);
}

sub carp_confess {
	my $msg = $_[THIS]->lookup(
		       $_[P_NAME],
		       $_[P_DETAILS],
		       $_[P_LANGUAGES]);
	Carp::confess($$msg);
	return;
}

#FIXME: this is untested now
sub P_COLLECTION() { 1 }
sub import_messages {
	my $messages = $_[THIS][ATR_MESSAGES];
	foreach my $collection (@{$_[P_COLLECTION]}) {
		my ($name, $exported) = @$collection;
		unless(exists($messages->{$name})) {
			Carp::confess("Undefined key '$name'.");
		}
		my $languages = $messages->{$name};
		$messages->{$name} = $exported;
		while (my ($language, $message) = each(%$languages)) {
			next if(exists($exported->{$language}));
			$exported->{$language} = $message;
		}
	}
	return;
}

1;
