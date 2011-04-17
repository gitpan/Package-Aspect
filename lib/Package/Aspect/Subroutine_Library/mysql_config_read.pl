sub mysql_config_file_read($$) {
	my ($cfg_file, $name) = @_;

	fs_file_read_contents(
		[], $cfg_file, my $buffer);
	$buffer =~ s,\t, ,sg;

	$buffer =~ s,\r,,sg;
	$buffer =~ s,\t, ,sg;
	return() unless ($buffer =~ m,(^|\n)\s*\[\s*$name\s*\]\s*\n(.*?)($|\n\s*\[[^\]\n]+\]\n),si);
	my $section = $2;

	my @config = ();
	foreach my $keyword qw(database host port user password) {
		push(@config, join('', ($section =~ m,(?:^|\n)[\t\s]*$keyword\s*=\s*([^\t\s\r\n]+),si)));
	}

	my $dsn = 'DBI:mysql:';
	my $database = shift(@config);
	$dsn .= (length($database) ? $database : 'fredi');
	my $host = shift(@config);
	if (defined($host) and length($host)) {
		$dsn .= ";host=$host";
	}
	my $port = shift(@config);
	if (defined($port) and length($port)) {
		$dsn .= ";port=$port";
	}

	unshift(@config, $dsn);
	return(@config);
}

1;
