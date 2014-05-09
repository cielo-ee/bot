#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;

use XML::Simple;
use Getopt::Long;

use update;

#コマンドラインオプション
my $dry_run = 0;

GetOptions('dry-run' => \$dry_run );

#postするデータファイルを読む
my $postDataFileName = "./postData.xml";

my $postDataXs = XML::Simple->new();
my $postData = $postDataXs->XMLin($postDataFileName);

#postしたヒストリを記録しておいて、同じpostをさせないようにする
#実質挨拶postで過去のpostと同じことをすることは少ないので、保留



#print Dumper $postData;

my $dataSize       = $postData->{dataSize};
my $randomPostData = $postData->{randomPostData}{data};

my $dataNo = int(rand($dataSize));
my $text = $$randomPostData[$dataNo];
if($dry_run){
	print encode_utf8($text);
	exit;
}

myUpdateStatus::updateStatus(status => $text);

exit;