sub eval_fatal {
	my $rv = eval $_[0];
	Carp::confess($@) if ($@);
	return($rv);
}

1;
