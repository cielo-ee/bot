package mapion_weather;

#!/bin/perl

use strict;
use warnings;

use HTML::TreeBuilder::XPath;
use URI;
use LWP::Simple;
use Encode;
use Data::Dumper;

use utf8;


sub extractWeatherInfo{

	my $path = shift;

	my $sourceURI = new URI('http://www.mapion.co.jp/');

	$sourceURI->path($path);

	my $tree = new HTML::TreeBuilder::XPath;

	my $content = get($sourceURI);

	if(!defined($content)){
		die "getting page failed\n";
	}

	$tree->parse($content) or die "parsing failed \n";

	my %weatherInfo;

	#今日と明日の天気
	for(0..1){

		my @weather       =  $tree->findvalues("/html/body/div/div[2]/div/div/div[$_ + 1]/table/tr[2]/td//\@alt");
		my @temperature   =  $tree->findvalues("/html/body/div/div[2]/div/div/div[$_ + 1]/table/tr[3]/td");
		my @precipitation =  $tree->findvalues("/html/body/div/div[2]/div/div/div[$_ + 1]/table/tr[4]/td");
		my @windForce     =  $tree->findvalues("/html/body/div/div[2]/div/div/div[$_ + 1]/table/tr[5]/td");
		my @windDirection =  $tree->findvalues("/html/body/div/div[2]/div/div/div[$_ + 1]/table/tr[5]/td//\@alt");

		my @day = ();

		for (0..7){
			my %hour = (
				"weather"       => pop(@weather),
				"temperature"   => pop(@temperature),
				"precipitation" => pop(@precipitation),
				"windForce"     => pop(@windForce),
				"windDirection" => pop(@windDirection)
				);
			unshift @day,\%hour;
		}
		#shiftとpushを使っちゃだめ
		#過去の天気は表示されないのでalt属性が空になってweatherの要素数が少なくなるので、
		#配列の後ろから詰めないといけない

		#print Dumper(\@day);

		if($_ == 0){
			#今日
			$weatherInfo{'today'} = \@day;
		}
		else{
			#明日
			$weatherInfo{'tomorrow'} = \@day;
		}

	}
	#週間天気
	my @date                 = $tree->findvalues('/html/body/div/div[2]/div/div[3]/table/tr[1]/td');
	my @weather              = $tree->findvalues('/html/body/div/div[2]/div/div[3]/table/tr[2]/td//@alt');
	my @temperature          = $tree->findvalues('/html/body/div/div[2]/div/div[3]/table/tr[3]/td');
	my @rainfallProbability  = $tree->findvalues('/html/body/div/div[2]/div/div[3]/table/tr[4]/td');

	my @week = ();
	for(0..5){
		my %day = (
			"date"                => pop(@date),
			"weather"             => pop(@weather),
			"temperature"         => pop(@temperature),
			"rainfallProbability" => pop(@rainfallProbability)
			);

		unshift @week,\%day;
	}

	$weatherInfo{'week'} = \@week;

	return \%weatherInfo;

}

1;

