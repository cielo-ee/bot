package MyBot;

use warnings;
use strict;
use utf8;
use Encode;

use Net::Twitter;
use XML::Simple;

sub new {
		my $class = shift;
		my $self  = {
				twit          => {}, #Net::Twitter�̃I�u�W�F�N�g
				userinfo      => 'userInfo.xml',
				black         => 'backlist.txt',     #�X�p���A�J�E���g�̃��X�g
				blacklist     => [],
				white         => 'whitelist.txt',    #�z���C�g���X�g
				whitelist     => [],
				follow        => 'followlist.txt',   #�t�H���[���͂����Ȃ����X�g
				followlist    => [],
				unfollow      => 'unfollowlist.txt', #�t�H���[���Ȃ����X�g
				unfollowlist  => [],
				friends       => 'friends.txt',      #�t�H���[�ς݂̃��X�g
				friendslist   => [],
				lastReplied   => 'lastReplied.txt',
				lastRepliedId => 0,
					
		};

		bless $self,$class;

		$self->{'twit'} = $self->init();
		
		return $self;


}

sub init {
		my $self = shift;
		
		my $userInfoXs = XML::Simple->new();
		my $userInfo = $userInfoXs->XMLin($self->{'userinfo'});
		
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

		$self->{'twit'} = $twit;
		
		return $self->{'twit'};
}



#sub loadFile{
#		my ($self,$filename) = @_;
#		my @list = @_;
#		open my $fh,'<',$filename or die "Cannnot open $filename:$!";
#		my @lines = <$fh>;
#		close $fh or die "Cannnot close $filename:$!";

#		s/\x0D?\x0A$//g for @lines;

#		return @lines;
#}

#sub saveFile{
#		my ($self,$filename) = @_;
#		my @list = $_;

		
#}

1;


