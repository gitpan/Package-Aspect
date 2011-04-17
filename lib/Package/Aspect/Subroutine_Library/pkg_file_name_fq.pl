sub pkg_file_name_fq {
        my $pkg_file_name = $_[0];
        $pkg_file_name =~ s,::,/,sg;
        $pkg_file_name .= '.pm';
        return(exists($INC{$pkg_file_name}) ? $INC{$pkg_file_name} : '');
}

1;
