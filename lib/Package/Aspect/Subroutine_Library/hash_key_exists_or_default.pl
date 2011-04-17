use strict;
use warnings;

sub hash_key_exists_or_default($$$) {
	if (exists($_[0]{$_[1]})) {
		return($_[0]{$_[1]});
	} else {
		return($_[2]);
	}
	return;
}

1;
