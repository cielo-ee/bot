#!/usr/bin/perl
use strict;
use Net::Twitter;
use Data::Dumper;
use utf8;
use Encode;

use update;

my $r_following  = myUpdateStatus::followingIds();
my $r_followers =  myUpdateStatus::followersIds();

#my @following = sort {$a->{'id'} <=> $b->{'id'}} @$r_following;
#my @followers = sort {$a->{'id'} <=> $b->{'id'}} @$r_followers;

my @following = sort{$a <=> $b} @$r_following;
my @followers = sort{$a <=> $b} @$r_followers;

###print @following."\n";
###print @followers."\n";

my @follow = ();
my @remove = ();

#print "following\t followers\n";

while(1){
	if(@following != 0 && @followers != 0){

		if($following[0] == $followers[0]){
#			print $following[0]."\t".$followers[0]."\n";
			shift @following;
			shift @followers;
			
		}
		elsif($following[0] > $followers[0]){
#			print $following[0]."\t".$followers[0]."\tfollow++\n";
			push @follow,(shift @followers);
			
		}
		else{ #$following[0] < $followers[0]){
#			print $following[0]."\t".$followers[0]."\tremove++\n";
			push @remove,(shift @following);

		}
	}
	elsif(@following == 0){
		push (@follow,@followers);
		last;
	}
	else{
		push (@remove,@following);
		last;
	}
}

#print "remove";
#print "@remove";
#print "\n";

#print "follow";
#print "@follow";
#print "\n";

if(@remove){

	foreach(@remove){
		my $removed = myUpdateStatus::destroyFriend($_);
###			if(defined($removed)){
###				print "$_をリムーブしました\n";
###			}
###			else{
###				print "$_のリムーブに失敗しました。\n"
###			}
			sleep(5);
	}
}

if(@follow){
	foreach(@follow){
		#スパムかどうかチェックする
		#		my $user = isSpam($_);
		###		if(!defined($user)){
		my $followed = myUpdateStatus::createFriend($_);
		###			if(defined($followed)){
		###				print "$_をフォローしました\n";
		###			}
		###			else{
		###				print "$_のフォローに失敗しました。\n"
		###			}
		sleep(5);
	}
}


#print "終了\n";
