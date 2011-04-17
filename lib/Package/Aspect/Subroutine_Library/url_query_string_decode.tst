my $query_string = 'a=b+f&c=d&a=e';
print STDERR Dumper(url_query_string_decode(undef, \$query_string, '&'));

