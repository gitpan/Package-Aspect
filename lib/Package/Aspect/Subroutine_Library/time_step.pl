{
	my $NOW = time();
sub time_step(;$) {
	$NOW = time() if (defined($_[0]));
	return($NOW);
}
}

1;
