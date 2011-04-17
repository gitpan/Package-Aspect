package Package::Aspect::Customized_Settings::Default::Table_Simple_Hash;

use strict;
use warnings;
#use Carp qw();
use parent qw(
	Object::By::Array
	Package::Aspect::Customized_Settings::Default::_
	Package::Aspect::Customized_Settings::Default::_Table
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	('^\*--+\*--+\+$');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_MAPPING() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_MAPPING] = {};

	return;
}

sub reset {
	$_[THIS][ATR_MAPPING] = {};
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		{%{$this->[ATR_MAPPING]}}];
	bless($clon, ref($this));
	$clon->_lock();

	$this->reset;

	return($clon);
}

sub P_DATA() { 1 }
sub parse_default {
	my ($this) = @_;

	if (defined($this->[ATR_DEFAULT])) {
		$localized_messages->carp_confess(
			'error_default_already_set',
			[$_[P_DATA]],
			undef);
	}
	$this->[ATR_DEFAULT] = 1;

	shift(@{$_[P_DATA]});
	shift(@{$_[P_DATA]});
	shift(@{$_[P_DATA]});

	$this->parse_lines($_[P_DATA]);
	return;
}

my $re = '^\| (.*) \| (.*) \|$';
sub P_LINES() { 1 }
sub parse_lines {
	my ($this) = @_;

	my $former_key = [];
	foreach (@{$_[P_LINES]}) {
		s/^[\s\t](?=\|)//s;
		s/(?<=\|)[\s\t]$//s;

		last if (m/^(\+|\*)--+/);
		next if (m/^(\+|\*)( -)+ ?(\+|\*)/);

		unless (m/$re/so) {
			$localized_messages->carp_confess(
				'error_invalid_default',
				[$_, $re],
				undef);
		}
		my @row = ($1, $2);
		$this->unquote_row(\@row);
		if (length($row[0]) == 0) {
			next if (length($row[1]) == 0);
			$this->[ATR_MAPPING]{$former_key} .= "\n".$row[1];
		} else {
			$this->[ATR_MAPPING]{$row[0]} = $row[1];
			$former_key = $row[0];
		}
	}
	return;
}

sub parse_config {
	my ($this) = @_;

	if (ref($_[P_DATA]) eq ref($this)) {
		return($this->inherit($_[P_DATA]));
	}
	$this->parse_lines($_[P_DATA]);
#	print STDERR "ref: ", ref($_[P_DATA]);
#	print STDERR Dumper($_[P_DATA]);
#	Carp::confess("Not supported.");
#	unless ($_[P_DATA] =~ m/^\| '([^|]*)' +\| '([^|]*)' +\|$/s) {
#		Carp::confess("Line '$_' not recognized.");
#	}
#	$this->[ATR_MAPPING]{$1} = $2;

	return;
}

sub THAT() { 1 }
sub inherit {
	while (my ($key, $value) = each(%{$_[THAT][ATR_MAPPING]})) {
		next unless (exists($_[THIS][ATR_MAPPING]{$key}));
		$_[THIS][ATR_MAPPING]{$key} = $value;
	}
	return;
}

sub P_KEY() { 1 }
sub lookup {
	return unless (exists($_[THIS][ATR_MAPPING]{$_[P_KEY]}));
	return($_[THIS][ATR_MAPPING]{$_[P_KEY]});
}

sub P_KEYS() { 1 }
sub lookup_first {
	foreach my $key (@{$_[P_KEYS]}) {
		next unless (exists($_[THIS][ATR_MAPPING]{$key}));
		return($_[THIS][ATR_MAPPING]{$key});
	}
	return;
}

sub as_hash {
	return($_[THIS][ATR_MAPPING]);
}

#my $data = [
#	q{*-----------*---------------------+},
#	q{| aspect | package_name        |},
#	q{*-----------*---------------------+},
#	q{| ''        | '::Generator::HTML' |},
#	q{|           | '::Generator::HTML' |},
#	q{* - - - - - * - - - - - - - - - - +},
#	q{| 'html'    | '::Generator::HTML' |},
#	q{*-----------*---------------------+}
#];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config(q{| 'ps'    | '::Generator::Postscript' |});
#use Data::Dumper;
#print STDERR Dumper($setting);

1;

