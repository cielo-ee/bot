#!/usr/bin/perl
use strict;
use warnings;
use XML::Simple;
use utf8;
use Data::Dumper;
use Encode;
use Getopt::Long;

use update;

#コマンドラインオプション
my $dry_run = 0;

GetOptions('dry-run' => \$dry_run );

#デバッグ時はSmart::Commentsをインストールしてある場合，
# perl -MSmart::Comments reply.pl
#のようにして実行

#設定ファイルを読む
my $configFileName = "configure.xml";
if(!( -f $configFileName)){
	die "$configFileName is not found.\n";
}
my $configXs = XML::Simple->new();
my $config = $configXs->XMLin($configFileName);

#前回の状態ファイルを読む
my $stateFileName = "state.xml";


if(!( -f $stateFileName)){
	#fixme
	#ファイルが無い場合は自動で作られるようにすること。
	die "$stateFileName is not found.\n";
}



my $stateXs = XML::Simple->new();
my $state = $stateXs->XMLin($stateFileName);

#前回終了時の情報を取得
#最後にチェックしたid
my $lastCheckedId = $state->{'lastCheckedId'};
### $lastCheckedId;

#タイムライン取得
my $r_timeline = myUpdateStatus::friendsTimeline(
	since_id => $lastCheckedId,
	count => 200
    );

if(!defined($r_timeline)){ #タイムライン取得失敗
	die "failed to get timeline.\n";
}

my @timeline = @$r_timeline;

#取得したタイムラインの中の最新のid
my $nextLastChackedId = $timeline[0]->{'id'};
$state->{'lastCheckedId'} = $nextLastChackedId;

#前回からタイムラインの更新がなければ、終了
if(!defined($nextLastChackedId)){
### 	
	exit;
}


#古い順に読まないといけないので、ひっくり返す
@timeline = reverse(@timeline);


my $r_skipWords = $config->{'skipData'};
my $r_patterns =  $config->{'replyData'}->{'pattern'};
my @replyPatterns = @$r_patterns;
#print @replyPatterns;


foreach my $r_status(@timeline){
	if($r_status->{'user'}{'id'} == $config->{'userinfo'}->{'userid'}){
		#自分自身だったらスキップ
		next;
	}
	if($r_status->{'text'} =~ /@/){
		if(!defined($r_status->{'in_reply_to_screen_name'})){
			#@で始まっていない
			next;
		}
		if($r_status->{'in_reply_to_screen_name'} eq $config->{'userinfo'}->{'username'}){
			#自分への@だったらスキップしない
#			print Dumper $r_status;
		}
		else{
			#誰かへの@だったらスキップ
			next;
		}
	}
	if(&isWordExists($r_skipWords->{'skip'},$r_status->{'text'})){
		#スキップすべき単語だったらスキップ
		next;
	}
	foreach my $r_reply(@replyPatterns){
#		print $r_reply->{'source'}."\n";
		if($r_status->{'text'} =~ /$r_reply->{'source'}/){
			my $replyText;
			if('ARRAY' eq ref($r_reply->{'reply'})){
				my $dataSize =  @{$r_reply->{'reply'}};
				$replyText = $r_reply->{'reply'}[int(rand($dataSize))];
			}
			else{
				$replyText = $r_reply->{'reply'};
			}
			my $replyName = $r_status->{'user'}{'screen_name'};
			my $inReplyTo = $r_status->{'id'};
#			&reply($twit,$replyName,$replyText,$inReplyTo,$dry_run);

#			print $replyText."\n"; 
			&reply(
				reply_to => $replyName,
				reply_text => $replyText,
				inReplyTo => $inReplyTo,
				dry_run   => $dry_run
				);
			next;
		}
	}

}


#現在の状態をファイルに書き出し
my $newState = new XML::Simple; 
$newState->XMLout($state,
		  NoAttr=>1,
		  OutputFile => 'state.xml',
		  XMLDecl    => "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
		  RootName => 'state'
		  );

exit;

sub isWordExists(){
	my $r_list = $_[0];
	my $line = $_[1];

	foreach (@$r_list){
		if ($line =~ /$_/){
			return 1;
		}
	}
	return 0;
}

sub reply(){

	my %arg = (
		reply_to => '',
		reply_text => '',
		inReplyTo => '',
		dry_run => 0,
		@_
		);

	my ($reply_to,$reply_text,$inReplyTo,$dry_run) = @arg{'reply_to','reply_text','inReplyTo','dry_run'};

#	print $twit."\n";
	    
	my $text = sprintf('@%s %s',$reply_to,$reply_text);

#	if($dry_run){

#		print encode_utf8($text." ".$inReplyTo."\n");
#		return;
#	}
	return myUpdateStatus::updateStatus(
		status => $text,
		in_reply_to_status_id => $inReplyTo,
		debug => $dry_run
	);
#	print $text;
}

exit;
