package Util;
use strict;
use warnings;
use utf8;
use 5.22.0;
use HTTP::Tiny;
use JSON::PP;
use IO::Socket::SSL;
use EvalbotExecuter;
use Exporter 'import';
our @EXPORT_OK = qw(slack_unescape perl6_eval perl5_eval perl6_version perl5_version ruby_eval python2_eval python3_eval js_eval);

sub slack_unescape {
    my $decoded = shift;
    state $unescape = sub {
        my $seq = shift;
        if    ($seq =~ s/^#C//)  { $seq =~ s/.*\|//; "#C$seq"  }
        elsif ($seq =~ s/^\@U//) { $seq =~ s/.*\|//; "\@$seq" }
        elsif ($seq =~ s/!//)    { $seq =~ s/.*\|//; "\@$seq"  }
        else                     { $seq =~ s/.*\|//; $seq     }
    };

    $decoded =~ s/<(.*?)>/ $unescape->($1) /eg;
    $decoded =~ s/&amp;/&/g;
    $decoded =~ s/&lt;/</g;
    $decoded =~ s/&gt;/>/g;
    $decoded;
}

sub format_output {
    my $response = shift;
    return "(no output)\n" unless length $response;

    my $newline = '␤';
    my $null    = "\N{SYMBOL FOR NULL}";
#    $response =~ s/\n/$newline/g;
    $response =~ s/\x00/$null/g;
    if ( length($response) > 300 ) {
        $response = substr($response, 0, 290) . "...";
    }

    return "$response";
}

sub perl6_eval {
    my $str = shift;
    my $perl6 = {
        cmd_line => q{RAKUDO_ERROR_COLOR= perl6 --setting=RESTRICTED %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $perl6, "perl6");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub perl5_eval {
    my $str = shift;
    my $perl5 = {
        cmd_line => q{perl %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $perl5, "perl5");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub ruby_eval {
    my $str = shift;
    my $cmd = {
        cmd_line => q{ruby %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $cmd, "ruby");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub python2_eval {
    my $str = shift;
    my $cmd = {
        cmd_line => q{python %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $cmd, "python");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub python3_eval {
    my $str = shift;
    my $cmd = {
        cmd_line => q{python3 %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $cmd, "python");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub js_eval {
    my $str = shift;
    my $cmd = {
        cmd_line => q{node %program},
    };

    # NOTE: result is decoded
    my $result = EvalbotExecuter::run($str, $cmd, "js");
    $result =~ s{/var/folders/[a-z0-9_/-]+}{/var/tempfile}gi;
    $result =~ s{/tmp/\S{10}}{/tmp/tempfile}g;
    format_output($result);
}

sub perl6_version {
    my $out = `perl6 -v` || '(something wrong)';
    $out;
}

sub perl5_version {
    my $out = `perl -v` || '(something wrong)';
    $out;
}
1;
