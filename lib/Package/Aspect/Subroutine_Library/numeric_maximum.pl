sub numeric_maximum {
        return(undef) if ($#_ == -1);

        my $max = $_[0];
        foreach (@_) {
            $max = $_ if ($_ > $max);
        }
        return($max);
}

1;
