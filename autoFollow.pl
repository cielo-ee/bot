#!/usr/bin/perl

=head1 NAME

auto follow back / remove

=head1 SYNOPSIS

randomPost [options] 

 Options:
   --dry-run         dryrun
   --users           number of users per 1time execution
=cut

use strict;
use warnings;

use Net::Twitter;
use Data::Dumper;
use utf8;
use Encode;
use Pod::Usage;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;


GetOptions(
	\my %opts, qw/
	dry-run
	users=i
	/
	) or pod2usage(verbose => 0);

use update;

my $users = 10; #1回につき10人まで

if($opts{'users'}){
	$users = $opts{'users'};
}


my $r_following  = myUpdateStatus::followingIds();
my $r_followers =  myUpdateStatus::followersIds();

#my @following = sort {$a->{'id'} <=> $b->{'id'}} @$r_following;
#my @followers = sort {$a->{'id'} <=> $b->{'id'}} @$r_followers;
print Dumper $r_following;

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
		if(!$opts{'dry-run'}){
			my $removed = myUpdateStatus::destroyFriend($_);
		}
		else{
			print "$_ is removed\n";
		}
		sleep(5);
	}
}

if(@follow){
	foreach(@follow){
		#スパムかどうかチェックする
		#		my $user = isSpam($_);
		###		if(!defined($user)){
		if(!$opts{'dry-run'}){
			my $followed = myUpdateStatus::createFriend($_);
		}
		else{
			print "$_ is followed\n";
		}
		sleep(5);
	}
}

exit;
#print "終了\n";
