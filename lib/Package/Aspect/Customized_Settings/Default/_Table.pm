package Package::Aspect::Customized_Settings::Default::_Table;

use strict;
use warnings;
#use Carp qw();
#use Data::Dumper;

sub multi_line { 1 }

sub P_ROW() { 1 }
sub unquote_row {
	foreach my $element (@{$_[P_ROW]}) {
		$element =~ s/\s+$//s;
		next if ($element eq 'NULL');
		if ($element =~ s/^('|")//s) {
			$element =~ s/$1[\s\t]*$//s;
			next;
		}
		$element =~ s/[\s\t]+$//s;
	}
	return;
}

1;

