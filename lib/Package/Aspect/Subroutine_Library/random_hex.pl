sub random_hex($) {
	return(join('', map(sprintf('%08x', int(rand(2**31-1))), 1..$_[0])))
}

1;
