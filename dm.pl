#!/usr/bin/perl

use strict;
use Data::Dumper;
use utf8;
use Encode;

use update;

my $r_dms = myUpdateStatus::directMessages();

#print Dumper($r_dms);

foreach(@$r_dms){
	my $text = $_->{'text'};
	my $sender = $_->{'sender_screen_name'};
	my $id = $_->{id};
	if($text =~ s/^((\s*)\!post)//){
		my $reply_text = sprintf("$text (via $sender)");
#		print $reply_text;
		myUpdateStatus::updateStatus(status => $reply_text);
		myUpdateStatus::destroyDirectMessage($id);
	}
}

