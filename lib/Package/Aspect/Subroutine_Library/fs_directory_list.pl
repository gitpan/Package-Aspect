sub fs_directory_list {
        unless (opendir(DIR, $_[0])) {
		$localized_messages->carp_confess(
				'error_fs_opendir',
				[$_[0], $!],
				undef);
	}
        my @names = readdir(DIR);
        close(DIR);

        return(\@names);
};

1;
