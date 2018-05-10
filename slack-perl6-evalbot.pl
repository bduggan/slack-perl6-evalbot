#!/usr/bin/env perl
use 5.22.0;
use warnings;
use lib "lib";
use Mojo::SlackRTM;
use Util qw(slack_unescape perl6_eval perl6_version perl5_eval perl5_version ruby_eval python2_eval python3_eval js_eval);

my $token = $ENV{SLACK_TOKEN} or die "miss SLACK_TOKEN";
delete $ENV{$_} for grep {/^SLACK/} keys %ENV;

my $slack = Mojo::SlackRTM->new(token => $token);

$slack->on(message => sub {
    my ($slack, $event) = @_;
    my $channel = $event->{channel};
    my $text = $event->{text} // ($event->{message} || +{})->{text} // "";
    my $edited = ($event->{subtype} // "") eq 'message_changed';
    return unless $text =~ m{\A(?:m|moar|perl6|perl6-m|perl5|ruby|python2|python3|js):\s*(\S.*)}sm
               || $text =~ m{\A(?:\s*```perl6\s+(\S.*)```\Z)}sm
               || $text =~ m{\A(?:\s*```perl5\s+(\S.*)```\Z)}sm
               ;
    my $program = $1;
    $program =~ s/\s+\z//sm;
    $program = $1 if $program =~ /\A```(.+)```\z/sm;
    $program = $1 if $program =~ /\A`(.+)`\z/sm;
    $program = slack_unescape $program;
    my $out;
    for ($text) {
    	/perl5:/   and $out = perl5_eval($program);
    	/ruby:/    and $out = ruby_eval($program);
    	/python2:/ and $out = python2_eval($program);
    	/python3:/ and $out = python3_eval($program);
    	/js:/      and $out = js_eval($program);
    	/perl6:/   and $out = perl6_eval($program);
    }
    $out = "\n" . '```' . "\n" . $out . '```';
    $out = "(edited) $out" if $edited;
    $slack->send_message($channel => $out);
});

$slack->on(message => sub {
    my ($slack, $event) = @_;
    my $channel = $event->{channel};
    my $text = $event->{text} // ($event->{message} || +{})->{text} // "";
    my $edited = ($event->{subtype} // "") eq 'message_changed';
    return unless $text =~ m{\A(?:m|moar|perl6|perl6-m)-(?:v|version):};
    my $out = perl6_version;
    $out = "(edited) $out" if $edited;
    $slack->send_message($channel => $out);
});

$slack->start;
