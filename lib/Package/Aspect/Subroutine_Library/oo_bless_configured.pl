{
	my $file_name = '/etc/mica-bless.cfg';
	if (-f $file_name) {
		my $sections = FIXME::load_sections($file_name, "\t");
		while (my ($key, $values) = each(%$sections)) {
			foreach my $value (@$values) {
				my ($calling_pkg, $class) = split(/[\s\t]+/, $value, 2);
				$MAPPINGS{$key}{$calling_pkg} = $class;
			}
		}
	}

sub oo_bless_configured {
        my $class = $_[2];
        if (exists($MAPPINGS{$class})) {
                if (exists($MAPPINGS{$class}{$_[0]})) {
                        $class = $MAPPINGS{$class}{$_[0]}
                } elsif (exists($MAPPINGS{$class}{'*'})) {
                        $class = $MAPPINGS{$class}{'*'}
                }
        }
        return(bless($_[1], $class));
}

}

1;
