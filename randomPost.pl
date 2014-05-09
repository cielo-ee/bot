#!/usr/bin/perl


=head1 NAME

post twitter timeline

=head1 SYNOPSIS

randomPost [options] 

 Options:
   --dry-run         dryrun
   --postdata        direct post
   --postfile        filename(default postData.xml)

=cut

use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;

use XML::Simple;
use Getopt::Long;

use Pod::Usage;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;


use update;

#コマンドラインオプション
GetOptions(
        \my %opts, qw/
        dry-run
        postdata=s
        postfile=s
        /
        ) or pod2usage(verbose => 0);

my $dry_run = $opts{'dry-run'};

#コマンドライン入力されたデータをpostする
if($opts{postdata}){
	#dry run(実際にはpostしない)
	if($dry_run){
		print encode_utf8($opts{postdata});
		exit;
	}
	myUpdateStatus::updateStatus(status => $opts{postdata});
	exit;

}


#postするデータファイルを読む
my $postDataFileName = "./postData.xml";

my $postDataXs = XML::Simple->new();
my $postData = $postDataXs->XMLin($postDataFileName);

#postしたヒストリを記録しておいて、同じpostをさせないようにする
#実質挨拶postで過去のpostと同じことをすることは少ないので、保留



my $dataSize       = $postData->{dataSize};
my $randomPostData = $postData->{randomPostData}{data};

my $dataNo = int(rand($dataSize));
my $text = $$randomPostData[$dataNo];

#dry run(実際にはpostしない)
if($dry_run){
	print encode_utf8($text);
	exit;
}

myUpdateStatus::updateStatus(status => $text);

exit;