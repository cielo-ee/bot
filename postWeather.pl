#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Data::Dumper;

use URI;


use mapion_weather;
use update;

my $path = '/weather/admi/21/21604.html'; #白川村
my $shortURL = new URI('http://bit.ly/7BILqh');

my $info = mapion_weather::extractWeatherInfo($path);

my @time = localtime(time);

#################################################
#  0   1   2   3    4     5      6    7         
# 0-3 3-6 6-9 9-12 12-15 15-18 18-21 21-24     
#################################################
my $hour;
my $day = 'today';
my $dateText;
if($time[2] < 6){ #朝の天気
	$hour = 2;
	$dateText = "今日朝";
}
elsif($time[2] < 12){ #昼頃の天気
	$hour = 4;
	$dateText = "今日昼頃";
}
elsif($time[2] < 18){ #夕方の天気
	$hour = 6;
	$dateText = "今日の夜";
}
else{ #明日夜の天気
	$hour = 0;
	$day = 'tomorrow';
	$dateText = "明日夜明け前";
}
my $weather = $info->{$day}[$hour];

my $updateText = sprintf($dateText."の白川村の天気は".$weather->{'weather'}."、気温は".$weather->{'temperature'}."だよ。 ".$shortURL->as_string);

#print $updateText;

myUpdateStatus::updateStatus(status=>$updateText);

__END__
