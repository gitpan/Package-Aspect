use strict;
use warnings;

sub string_inline_csv_split {
	return if (ref($_[0]));
	$_[0] = [split(',', $_[0] || '')];
	return;
}

1;
