use Net::SMTP;

sub app_mail_send_smtp_simple($$$) {
        my ($smtp_host, $from, $to) = @_;

        my $smtp = Net::SMTP->new($smtp_host, 'Debug' => 0) || return;
        $smtp->mail($from);
        $smtp->to(@$to);
        $smtp->data();
        $smtp->datasend($_[-1]);
        $smtp->dataend();
        $smtp->quit();
        return(1);
}

1;
