#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Net::Twitter;
use XML::Simple;

print "consumer key?:";
my $consumer_key = <STDIN>;
chomp $consumer_key;
print "consumer_key_secret?:";
my $consumer_key_secret = <STDIN>;
chomp $consumer_key_secret;

my $twit = Net::Twitter->new(
  traits          => ['API::REST', 'OAuth'],
  consumer_key    => $consumer_key,
  consumer_secret => $consumer_key_secret,
);
print 'access this url by bot account : '.$twit->get_authorization_url."\n";
print 'input verifier PIN : ';
my $verifier = <STDIN>;
chomp $verifier;

my $token = $twit->request_token;
my $token_secret = $twit->request_token_secret;

$twit->request_token($token);
$twit->request_token_secret($token_secret);

my($at, $ats) = $twit->request_access_token(verifier => $verifier);

print "Access token : ".$at."\n";
print "Access token secret : ".$ats."\n";

my $userInfo = {
	consumer_key         => $consumer_key,
	consumer_secret      => $consumer_key_secret,
	access_token        => $at,
	access_token_secret => $ats
};

my $userInfoXs = XML::Simple->new();

$userInfoXs->XMLout($userInfo,
	       NoAttr=>1,
	       OutputFile => 'userInfo.xml',
	       XMLDecl    => "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
	       RootName => 'userInfo'
	       );

exit;