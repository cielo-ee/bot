#!/usr/bin/perl

=head1 NAME

デバッグ用に各種データをダンプする

=head1 SYNOPSIS

reply [options] 
 Options:
    --userid   -u  USEID USERIDのデータをダンプする
    --timoline -t  タイムラインのデータをダンプする
    --api      -a  HOGE 任意のNet::Twitterのメソッドを実行する
    --myid     -m  自分の情報
=cut


use strict;
use warnings;
use XML::Simple;
use utf8;
use Data::Dumper;
use Encode;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

use MyBot;

#コマンドラインオプション
my %opt = (
		'userid'   => '',
		'timeline' => 0,
		'api'      => '',
		'myid'     => 0
		);


GetOptions(
        \%opt, qw/
		userid|u=s
		timeline|t
		api|a=s
		myid|m
        /
        ) or pod2usage(verbose => 0);


my $bot = MyBot->new();

print Dumper $bot->{'twit'}->update_profile() if($opt{'myid'});
print Dumper $bot->{'twit'}->show_user($opt{'userid'}) if($opt{'userid'});
print Dumper $bot->{'twit'}->home_timeline() if($opt{'timeline'});
eval{"print Dumper $bot->{'twit'}->$opt{api}"} if($opt{'api'});



