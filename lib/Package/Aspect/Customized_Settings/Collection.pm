package Package::Aspect::Customized_Settings::Collection;

use strict;
use warnings;
#use Carp qw();
#use Data::Dumper;
use parent qw(
	Object::By::Hash
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $subroutine_library = '::Subroutine_Library',
        my $localized_messages = '::Localized_Messages');

sub THIS() { 0 }

sub P_PKG_FILE() { 1 };
sub _init {
	$_[THIS]{''} = $_[P_PKG_FILE];
}

sub clone {
	my $that = {};
	while (my ($key, $value) = each(%{$_[THIS]})) {
		$that->{$key} = $value->clone;
	}
	bless($that, ref($_[THIS]));
	$that->_lock();
	return($that);
}

sub P_SETTINGS() { 1 }
sub customized {
	my $customized = $_[THIS]->clone;
	$customized->hash_configuration($_[P_SETTINGS]);
	return($customized);
}

sub extracted_values {
	my $this = shift;

	my @values = ();
	foreach (@_) {
		if(exists($this->{$_})) {
			push(@values, $this->{$_}->value);
		} else {
			push(@values, undef);
		}
	}
	return(@values);
}

sub inherit {
	my ($this, $that) = @_;

	return if (ref($this) ne ref($that));
	foreach my $key (keys(%$this)) {
		$this->{$key}->inherit($that->{$key});
	}

	return;
}

sub file_configuration {
	my ($this, $file_name) = @_;

	fs_file_read_contents(
		$file_name,
		my $buffer);
	if ($buffer =~ m,\n\t,s) {
		Carp::confess("File '$file_name' has tab stops at beginning of a line - can't handle that.");
	}
	my @lines = split(/\r?\n/, $buffer);
	my $setting = undef;
	my $i = 0;
	my $region = undef;
	my $indentation = undef;
	foreach my $line (@lines) {
		$i += 1;
		next if ($line =~ m/^#/);
		next if ($line =~ m/^\s*$/);

		if ($line =~ m/^\!/s) {
			Carp::confess("Line '$i' in file '$file_name': policies are not implemented, yet.");
		}
		if ($line =~ s/^(\w+)([\s\t]+)//s) {
			my $name = $1;
			$indentation = length($1) + length($2);
			$setting->parse_config($region) if (defined($region));

			unless(exists($this->{$name})) {
				Carp::confess("Line '$i' in file '$file_name': setting '$name' is has no default.");
			}
			$setting = $this->{$name};
			if ($setting->multi_line) {
				$region = [$line];
			} else {
				$setting->parse_config($line);
				$region = undef;
			}
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
	$setting->parse_config($region) if (defined($region));

	return;
}

sub hash_configuration {
	my ($this, $settings) = @_;

	return unless(defined($settings));
#aus Package.pm

	foreach my $key (keys(%$settings)) {
		unless (exists($this->{$key})) {
			Carp::confess(
				"Key '$key' isn't part of the defaults in '",
				$this->{''}, "'.");
		}
		$this->{$key}->parse_config($settings->{$key});
	}

	return;
}

#sub overwrite {
#	my ($this, $settings) = @_;
#
#	foreach my $key (keys(%$settings)) {
#		next unless (exists($this->{$key}));
#		$this->{$key}->parse_config($settings->{$key});
#	}
#
#	return;
#}

#sub P_NAME() { 1 }
#sub P_DEFAULT() { 2 }
#sub value_or_default {
#	return($_[P_DEFAULT]) unless (exists($_[THIS]->{$_[P_NAME]}));
#	return($_[THIS]->{$_[P_NAME]}->value);
#}

1;
