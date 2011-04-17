use strict;
use warnings;

sub hash_subset_by_key_prefix {
	my %rv = ();
        while (my ($key, $value) = each(%{$_[0]})) {
		next unless ($key =~ m/^$_[1](.*)$/s);
		$rv{$1} = $value;
	}
	return(\%rv);
}

1;
