sub fs_file_write_many_contents {
	my $this = shift;
	my $file_name = shift;
        unless (open(F, '>', $file_name)) {
		$localized_messages->carp_confess(
				'error_fs_open',
				[$file_name, $!],
				undef);
	}
	if($fs_binmode_os) {
		binmode(F);
	}

	flock(F, 2); #FIXME: 2 is a hardcoded value
	truncate(F, 0);
	foreach (@_) {
		print F $_;
	}
	flock(F, 8); #FIXME: 8 is a hardcoded value
	close(F);
	return;
}

1;
