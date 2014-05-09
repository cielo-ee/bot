package myUpdateStatus;

use warnings;
use strict;
use utf8;
use Encode;
use Net::Twitter;
use XML::Simple;


sub init{
	
	my $userInfoXs = XML::Simple->new();
	my $userInfo = $userInfoXs->XMLin('userInfo.xml');

	my ($consumer_key,$consumer_key_secret,$access_token,$access_token_secret ) =
	    ($userInfo->{consumer_key},$userInfo->{consumer_secret},$userInfo->{access_token},$userInfo->{access_token_secret});


	
	my $twit = Net::Twitter->new(
		traits          => ['API::RESTv1_1', 'OAuth'],
		consumer_key    => $consumer_key,
		consumer_secret => $consumer_key_secret,
		ssl             => 1
		);
	$twit->access_token($access_token);
	$twit->access_token_secret($access_token_secret);

	return $twit;

}

sub updateStatus{
	my %arg = (
		status => '',
		in_reply_to_status_id => undef,
		debug => '0',
		@_
		);
	
	my $twit = &init;
	my $status = $arg{'status'};
	
	if(!$arg{'debug'}){
		if($arg{'in_reply_to_status_id'}){
			eval{
				return $twit->update({
					status => $arg{'status'},
					in_reply_to_status_id => $arg{'in_reply_to_status_id'}
				})
			    };
		}
		else{
			eval{
				return $twit->update({
					status => $arg{'status'}
				})
			    };
		}
		if($@){
			return;
		}
	}
	else{
		print encode_utf8($status);
	}
}


sub directMessages{
	my $twit = &init();
	
	return $twit->direct_messages();
}

sub destroyDirectMessage{
	my $id = shift;
	
	my $twit = &init();

	return $twit->destroy_direct_message($id);
}


sub friendsTimeline{
	my %arg = (
		since_id => 0,
		count    => 20,
		@_
		);

	my $twit = &init();

	return $twit->home_timeline({
		since_id => $arg{'since_id'},
		count   =>  $arg{'count'}
		
	});
}


sub destroyFriend{
	my $id = shift;

	my $twit = &init();

	return $twit->destroy_friend({id =>$id});

#	print "removed".$id."\n";
}

sub createFriend{
	my $id = shift;

	my $twit = &init();

	eval{
		return $twit->create_friend({id => $id});
	};
	if($@){
#		print "catch $@\n";
		return;
	}
#	print "followed".$id."\n";
}


sub followingIds{
	my $twit = &init();
	
	return $twit->following_ids();
    }

sub followersIds{
	my $twit = &init();

	return $twit->followers_ids();
}
1;

