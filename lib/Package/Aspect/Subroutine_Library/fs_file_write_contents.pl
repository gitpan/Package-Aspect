sub fs_file_write_contents {
        unless (open(F, '>', $_[0])) {
		$localized_messages->carp_confess(
				'error_fs_open',
				[$_[0], $!],
				undef);
	}
	if($fs_binmode_os) {
		binmode(F);
	}

	flock(F, 2); #FIXME: 2 is a hardcoded value
	truncate(F, 0);
	print F $_[1];
	flock(F, 8); #FIXME: 8 is a hardcoded value
	close(F);
	return;
}

1;
