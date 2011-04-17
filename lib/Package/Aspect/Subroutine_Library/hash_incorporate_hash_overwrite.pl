use strict;
use warnings;

sub hash_incorporate_hash_overwrite {
	my $master = shift;

	foreach my $hash (@_) {
		while (my ($key, $value) = each(%$hash)) {
			next unless (exists($master->{$key}));
			$master->{$key} = $value;
		}
	}
	return;
}

1;
