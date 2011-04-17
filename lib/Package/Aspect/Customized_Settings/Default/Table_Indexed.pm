package Package::Aspect::Customized_Settings::Default::Table_Indexed;

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
	('^\+==+');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_PARSER() { 1 }
sub ATR_COLUMNS() { 2 }
sub ATR_TABLE() { 3 }
sub ATR_INDICES() { 4 }

sub _init {
	my ($this) = @_;

        $this->[ATR_DEFAULT] = undef;
        $this->[ATR_PARSER] = undef;
        $this->[ATR_COLUMNS] = [];
        $this->[ATR_TABLE] = [];
        $this->[ATR_INDICES] = [];

	return;
}

sub reset {
        $_[THIS][ATR_TABLE] = [@{$_[THIS][ATR_DEFAULT]}];
	$_[THIS]->re_index_table;
	return;
}

sub clone {
	my ($this) = @_;

	my $clon = [
		$this->[ATR_DEFAULT],
		$this->[ATR_PARSER],
		$this->[ATR_COLUMNS],
		[@{$this->[ATR_TABLE]}],
		[@{$this->[ATR_INDICES]}]];
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
			[''],
			undef);
	}
	$this->[ATR_DEFAULT] = [];

	my $line1 = shift(@{$_[P_DATA]});
	my @outline = ($line1 =~ m/(?:^|\+)(==+)(?=$|\+)/sg);
	my $sum = 2;
	foreach my $entry (@outline) {
		my $l = length($entry);
		$entry = [$sum, $l-2];
		$sum += $l+1;
	}
	my $subroutine = "sub { return([\n". join(",\n", map("\tsubstr(\$_[0], $_->[0], $_->[1])", @outline)) .']) }';
	my $parser = $this->[ATR_PARSER] = eval $subroutine;
	Carp::confess($@) if ($@);

	my $line2 = shift(@{$_[P_DATA]});
	my @columns = map(do{s/[\s\t]+$//s; [$_, []]}, @{$parser->($line2)});

	my $line3 = shift(@{$_[P_DATA]});
	my @properties = map(substr($_, 0, 1), @{$parser->($line3)});

	my $i = -1;
	my %names = ();
	foreach my $column (@columns) {
		$i += 1;
		push(@$column, $properties[$i]);
		my $index = ($properties[$i] eq '-') ? undef : {};
		push(@{$this->[ATR_INDICES]}, $index);
		$names{$column->[0]} = $i;
	}
	$this->[ATR_COLUMNS] = \@columns;
	push(@{$this->[ATR_INDICES]}, \%names);

	$i = 0;
	my $former_row;
	foreach my $line (@{$_[P_DATA]}) {
		$i += 1;
		last if (substr($line, 0, 3) eq '+==');
		next if ($line =~ m/^(\+|\*)( -)+ ?(\+|\*)/);

		my $row = $parser->($line);
#		unless ($#$row == $#columns) {
#			Carp::confess("Column count '$#columns' does not match value '$#$row' count in data line $i '$line'.");
#		}

		if ($row->[0] =~ m,^[\s\t]*$,) {
			$this->unquote_row($row);
			for (my $i = 1; $i <= $#$former_row; $i++) {
				next if (length($row->[$i]) == 0);
				$former_row->[$i] .= "\n".$row->[$i];
			}
			next;
		} else {
			$this->unquote_row($row);
			push(@{$this->[ATR_TABLE]}, $row);
			push(@{$this->[ATR_DEFAULT]}, $row);
			$former_row = $row;
		}
	}

	$this->re_index_table;

	return;
}

sub clear_indices {
	my ($this) = @_;

	for (my $i = 0; $i < $#{$this->[ATR_INDICES]}; $i++) {
		next unless (defined($this->[ATR_INDICES][$i]));
		$this->[ATR_INDICES][$i] = {};
	}
	return;
}

sub re_index_table {
	my ($this) = @_;

	$this->clear_indices;
	foreach my $row (@{$this->[ATR_TABLE]}) {
		$this->index_row($row);
	}
	return;
}

sub P_ROW() { 1 }
sub index_row {
	my ($this) = @_;

	my $i = -1;
	my $row_count = $#{$this->[ATR_TABLE]};
	foreach my $element (@{$_[P_ROW]}) {
		$i += 1;
		my $index_type = $this->[ATR_COLUMNS][$i][2];
		if ($index_type eq '-') {
			next;
		}
		my $index = $this->[ATR_INDICES][$i];
		if ($index_type eq '?') {
			if (exists($index->{$element})) {
				push(@{$index->{$element}}, $row_count);
			} else {
				$index->{$element} = [$row_count];
			}
		} elsif ($index_type eq '!') {
			if (exists($index->{$element})) {
				Carp::confess("Duplicate key '$element' for element.");
			}
			$index->{$element} = $row_count;
		}
	}

	return;
}

sub P_KEY() { 1 }
sub P_VALUE() { 2 }
sub rows_where {
	my ($this) = @_;

	return(undef) unless (exists($this->[ATR_INDICES][-1]{$_[P_KEY]}));
	my $i = $this->[ATR_INDICES][-1]{$_[P_KEY]};
	return(undef) unless (exists($this->[ATR_INDICES][$i]{$_[P_VALUE]}));
	my $j = $this->[ATR_INDICES][$i]{$_[P_VALUE]};

	return($this->[ATR_INDICES][$j]);
}

sub P_NAME() { 3 }
sub elements_where {
	my ($this) = @_;

	return(undef) unless (exists($this->[ATR_INDICES][-1]{$_[P_KEY]}));
	my $i = $this->[ATR_INDICES][-1]{$_[P_KEY]};
	return(undef) unless (exists($this->[ATR_INDICES][$i]{$_[P_VALUE]}));
	my $j = $this->[ATR_INDICES][$i]{$_[P_VALUE]};

	return(undef) unless (exists($this->[ATR_INDICES][-1]{$_[P_NAME]}));
	my $k = $this->[ATR_INDICES][-1]{$_[P_NAME]};

	return($this->[ATR_TABLE][$j][$k]);
}

sub parse_config {
	if (ref($_[P_DATA]) eq ref($_[THIS])) {
		return($_[THIS]->inherit($_[P_DATA]));
	}
	Carp::confess('Not supported');

	return;
}

sub THAT() { 1 }
sub inherit {
	foreach my $row (@{$_[THAT][ATR_TABLE]}) {
		push(@{$_[THIS][ATR_TABLE]}, $row);
		$_[THIS]->index_row($row);
	}

	return;
}


#my $data = [
#	q{+===========+=====================+},
#	q{| aspect | package_name        |},
#	q{+-!---------+-?-------------------+},
#	q{| ''        | '::Generator::HTML' |},
#	q{|           | '::Generator::HTML' |},
#	q{+ - - - - - + - - - - - - - - - - +},
#	q{| 'html'    | '::Generator::HTML' |},
#	q{+===========+=====================+},
#];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
##$setting->parse_config(q{aspect='ps', package_name='::Generator::Postscript'});
#use Data::Dumper;
#print STDERR Dumper($setting);

#my $data = [
#	q{+===========+=====================+},
#	q{| aspect | package_name        |},
##	q{| [_] a     | YES/no              |},
##	q{| [_] b     |                     |},
#	q{+-!---------+-?-------------------+},
#	q{| ''        | '::Generator::HTML' |},
#	q{| 'html'    | '::Generator::HTML' |},
#	q{+===========+=====================+},
#];

1;

