package Package::Aspect::Customized_Settings::Default::Table_Simple_Array;

use strict;
use warnings;
use Carp qw();
#use Data::Dumper;
use parent qw(
        Object::By::Array
        Package::Aspect::Customized_Settings::Default::_
        Package::Aspect::Customized_Settings::Default::_Table
);

use Package::Aspect sub{eval shift};
Package::Aspect::reservation(
        my $localized_messages = '::Localized_Messages');

use Package::Aspect::Customized_Settings::Recognizer
	('^\+--+$');

sub THIS() { 0 }

sub ATR_DEFAULT() { 0 }
sub ATR_ROWS() { 1 }

sub _init {
        $_[THIS][ATR_DEFAULT] = undef;
        $_[THIS][ATR_ROWS] = [];

        return;
}

sub reset {
	$_[THIS][ATR_ROWS] = [];
	return;
}

sub clone {
        my $clon = [
                $_[THIS][ATR_DEFAULT],
                [@{$_[THIS][ATR_ROWS]}]];
        bless($clon, ref($_[THIS]));
        $clon->_lock();

	$_[THIS]->reset;

        return($clon);
}

sub P_DATA() { 1 }
sub parse_default {
        if (defined($_[THIS][ATR_DEFAULT])) {
                $localized_messages->carp_confess(
                        'error_default_already_set',
                        [''],
                        undef);
        }
        $_[THIS][ATR_DEFAULT] = 1;

        shift(@{$_[P_DATA]});
        shift(@{$_[P_DATA]});
        shift(@{$_[P_DATA]});

        $_[THIS]->parse_lines($_[P_DATA]);
        return;
}

my $re = '(?:\| ([^|]*) )';
sub P_LINES() { 1 }
sub parse_lines {
        my $former_row = [];
        foreach (@{$_[P_LINES]}) {
                s/^[\s\t](?=\|)//s;
                s/(?<=\|)[\s\t]$//s;

                last if (m/^(\+|\*)--+/);
                next if (m/^(\+|\*)( -)+ ?(\+|\*)/);

                my @row = (m/$re/sg);
                if ($#row == -1) {
                        $localized_messages->carp_confess(
                                'error_invalid_default',
                                [$_, $re],
                                undef);
                }

                if ($row[0] =~ m,^[\s\t]*$,) {
                        $_[THIS]->unquote_row(\@row);
                        for (my $i = 1; $i <= $#$former_row; $i++) {
                                next if (length($row[$i]) == 0);
                                $former_row->[$i] .= "\n".$row[$i];
                        }
                } else {
                        $_[THIS]->unquote_row(\@row);
                        push(@{$_[THIS][ATR_ROWS]}, \@row);
                        $former_row = \@row;
                }
        }

        return;
}

sub parse_config {
        if (ref($_[P_DATA]) eq ref($_[THIS])) {
                return($_[THIS]->inherit($_[P_DATA]));
        }
        $_[THIS]->parse_lines($_[P_DATA]);
#       my @row = ($_[P_DATA] =~ m/(?:\| '([^|]*)' +)/sg);
#       if ($#row == -1) {
#               Carp::confess("Line '$_' not recognized.");
#       }
#       push(@{$_[THIS][ATR_ROWS]}, \@row);

        return;
}

sub THAT() { 1 }
sub inherit {
        push(@{$_[THIS][ATR_ROWS]}, @{$_[THAT][ATR_ROWS]});
        return;
}

#my $data = [
#	q{+-----------+---------------------+},
#	q{| aspect | package_name        |},
#	q{+-----------+---------------------+},
#	q{| ''        | '::Generator::HTML' |},
#	q{|           | '::Generator::HTML' |},
#	q{+ - - - - - + - - - - - - - - - - +},
#	q{| 'html'    | '::Generator::HTML' |},
#	q{+-----------+---------------------+},
#];
#my $setting = __PACKAGE__->new;
#$setting->parse_default($data);
#$setting->parse_config(q{| 'ps'    | '::Generator::Postscript' |});
#print STDERR Dumper($setting);

1;
