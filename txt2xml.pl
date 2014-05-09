#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use XML::Simple;
use Getopt::Long;

#GetOptions();


#テキストファイルを読む

#変換元のファイル
my $txtFileName = "./postData.txt";

sub readPostDataFile(){
	my $fileName = shift;
	open FH,"<$fileName" or die "ファイルオープンに失敗しました。";
	my @data = <FH>;
	close FH;
	return \@data;
}

my $r_data = &readPostDataFile("./postData.txt");
my @data = @$r_data;
my $dataSize = @data;

#改行を取りのぞいてutf8フラグを立てる
foreach (@data){
	$_ =~ s/\r//;
	$_ =~ s/\n//;
	$_ =  decode_utf8($_);
#	print utf8::is_utf8($_) ? 1:0;
}

#postDataを生成
my $postData = {
	dataSize => $dataSize,
	randomPostData => {
		data => \@data
	    },
};


#xmlファイルを吐く
my $postXs = XML::Simple->new();
$postXs->XMLout(
	$postData,
	NoAttr => 1,
	OutputFile => 'postData.xml',
	XMLDecl    => "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
	RootName => 'postData'
);

exit;