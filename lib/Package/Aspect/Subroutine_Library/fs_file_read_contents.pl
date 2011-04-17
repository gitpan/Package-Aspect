use strict;
use warnings;

sub fs_file_read_contents {
        unless (open(F, '<', $_[0])) {
		_localized_messages()->carp_confess(
				'error_fs_open',
				[$_[0], $!],
				undef);
	}
	if(_fs_fd_binmode_os()) {
		binmode(F);
	}
        read(F, $_[1], (stat(F))[7]);
        close(F);
	return;
}

1;
