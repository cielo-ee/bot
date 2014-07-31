#!/usr/bin/perl

=head1 NAME

twitterにpostする

=head1 SYNOPSIS

autoFollow.pl [options] 

 Options:
   --dry-run          表示だけして終了
   --file    -f       ファイル名（デフォルトpostData.txt）
   --post    -p       与えた文字列をpost
=cut

use warnings;
use strict;

use utf8;
use Encode;
use Pod::Usage;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

use Net::Twitter;
use XML::Simple;
use Data::Dumper;

use MyBot;

my %opt = (
		'dry-run' => 0,
		'file'    => 'postData.txt',
		'post'    => undef
	);



GetOptions(
    \%opt, qw/
    dry-run|n
    file|f=s
    post|p=s
/) or pod2usage(verbose => 0);


&init();

my $bot = MyBot->new();

my $data = decode('UTF-8',$opt{'post'});

if($opt{'post'}){
		&update($bot,encode_utf8($data),$opt{'dry-run'});
		exit;
}


my $filename = $opt{'file'};

open my $fh,'<',$filename or die "Cannot open $filename:$!";
my @lines = <$fh>;
close $fh or die "Cannot close $filename:$!";

my $line_count = @lines;
my $idx        = int(rand ($line_count-1));

&update($bot,$lines[$idx],$opt{'dry-run'});
exit;


sub init{
		if(!(-f 'userInfo.xml')){
				die "userInfo.xml is not exists";
		}
}

sub update{
		my ($bot,$data,$dry) = @_;
		
		if($dry){
				print $data;
		}
		else{
				$bot->{'twit'}->update($data);
		}
}


