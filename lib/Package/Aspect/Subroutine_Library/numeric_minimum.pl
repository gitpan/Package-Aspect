sub numeric_minimum {
        return(undef) if ($#_ == -1);

        my $min = $_[0];
        foreach (@_) {
            $min = $_ if ($_ < $min);
        }
        return($min);
}

1;
