sub url_query_string_decode {
	my ($this, $settings, $delimiter) = @_;

	return({}, []) unless (defined($$settings));

	$$settings =~ tr/+/ /;
	my @settings = split(/$delimiter/, $$settings);

	my $return_ordered_names = wantarray() ? 1 : 0;

	my %settings = ();
	my @ordered_names = ();
	foreach my $setting (@settings) {
		my ($name, $value) = split (/=/, $setting, 2);

		url_decode($name);
		url_decode($value);

		if (exists($settings{$name})) {
			push(@{$settings{$name}}, $value);
		} else {
			push(@ordered_names, $name) if ($return_ordered_names);
			$settings{$name} = [$value];
		}
	}

	if ($return_ordered_names) {
		return(\%settings, \@ordered_names);
	} else {
		return(\%settings);
	}
}

1;
