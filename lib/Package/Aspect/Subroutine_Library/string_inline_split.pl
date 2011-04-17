use strict;
use warnings;

sub string_inline_split($$;$) {
	$_[1] = [split(/$_[0]/, $_[1], $_[2])];
}

1;
