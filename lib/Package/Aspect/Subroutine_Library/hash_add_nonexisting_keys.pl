use strict;
use warnings;

sub hash_add_nonexisting_keys {
	my $master = shift;

	foreach my $hash (@_) {
		while (my ($key, $value) = each(%$hash)) {
			if (!exists($master->{$key}) or !defined($master->{$key})) {
				$master->{$key} = $value;
			}
		}
	}
	return;
}

1;
