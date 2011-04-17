sub url_decode {
	$_[0] =~ s/%([\da-fA-F]{2})/chr(hex($1))/eg;
}

1;
