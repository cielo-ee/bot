#!/usr/bin/perl

=head1 NAME

reply some followers post

=head1 SYNOPSIS

reply [options] 
 Options:
   --dry-run -n       表示だけして終了
   --file    -f       ファイル名（デフォルトreplyData.tsv）
   --post    -p       与えた文字列をpost
   --statid  -s       replyするstatus id
   --myid    -m       自分のidが書かれたファイル(デフォルトreplyData.tsv);
   与えられたstatus idに対してreply(-sと-pは同時に使う必要がある)
=cut

use strict;
use warnings;
use XML::Simple;
use utf8;
use Data::Dumper;
use Encode;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

use MyBot;


#コマンドラインオプション
my %opt = (
		'dry-run' => 0,
		'file'    => 'replyData.tsv',
		'myid'    => 'myid.txt',
		'NGword'  => 'NGword.txt',
		'NGuser'  => 'NGuser.txt',
		'lastidf' => 'lastId.txt',
		'post'    => undef,
		'statid'  => undef
		);


GetOptions(
        \my %opts, qw/
        dry-run|n
		file|r=s
		myid|m=s
		NGword|w=s
		NGuser|u=s
		lastidf|l=s
		post|p=s
		statf|s=s
        /
        ) or pod2usage(verbose => 0);


#設定ファイルの読み込み
my $config = &init(%opt);

#print Dumper $config;


#Net::Twitterのオブジェクトを作る
my $bot = MyBot->new();


#状態ファイルがある場合、前回終了時の情報を取得
#ない場合は前回は1とみなす(0だとエラーになる・・・)
my $lastCheckedId = 1;

my $lastIdfile = $opt{'lastidf'};
if(-f $lastIdfile){
		$lastCheckedId = loadLine($lastIdfile);
}

my $r_timeline = $bot->{'twit'}->home_timeline({since_id => $lastCheckedId})
	 or die "failed to get timeline.\n";

	 
#取得したタイムラインの中の最新のid
my $nextLastChackedId = $r_timeline->[0]->{'id'};
saveLine($lastIdfile,$nextLastChackedId);



#古い順に読まないといけないので、ひっくり返す
my @timeline = reverse(@$r_timeline);


#foreach(@timeline){
#		&execReply($bot,$myID,$_,\@OK,\@NG,$opt{'dry-run'});
#}



exit;



sub getMyId{
		my ($bot,$filename) = @_;
		my $id = 0;
		if(-f $filename){
				$id = loadLine($filename);
		}
		else{   #ファイルがない場合は、APIを叩いてIDを持ってくる
				$id = $bot->{'twit'}->update_profile()->{'id'};
				saveLine($filename,$id);
		}
		return $id;
}

sub loadLine{
		my $filename = shift;	
		open my $fh, '<',$filename or die "Cannnot open $filename:$!";
		my $line = readline $fh;
		close $fh or die "Cannot close $filename:$!";
		chomp $line;
		return $line;
}

sub saveLine{
		my ($filename,$line) = @_;
		open my $fh,'>',$filename or die "Cannot open $filename:$!";
		print $fh $line;
		close $fh or die "Cannot close $filename:$!";
}

sub getReplyData{
		my $filename = shift;
		open my $fh, '<',$filename or die "Cannnot open $filename:$!";
		my @lines = <$fh>;
		close $fh or die "Cannot close $filename:$!";
		return @lines;
}


sub isWordExists{
		my ($text,$wordlist) = @_;

		foreach my $word(@$wordlist){
				return if $text =~ /$word/;
		}
}

sub loadFile{
		my $filename = shift;
		open my $fh,'<',$filename or die "Cannot open $filename:$!";
		my @lines = <$fh>;
		close $fh or die "Cannot close $filename:$!";
		@lines = map {decode_utf8 $_} @lines;
		@lines = chomp for @lines;
		return @lines;
}

sub loadReplyFile{
		my $filename = shift;
		my %replyData = ();
		
		my @lines = &loadFile($filename);

		foreach my $line(@lines){
				my ($key,$value) = split /\t/,$line;
				$replyData{$key} = $value;
		}

		return %replyData;
}




sub init{
		#設定ファイルの読み込み
		my %opt = @_;

		my $myID      = &getMyId($bot,$opt{'myid'});
		my %replyPair  = loadReplyFile($opt{'file'});
		my $NGwordfile = $opt{'NGword'};
		my $NGuserfile = $opt{'NGdata'};
		my $id = getMyId($bot,$opt{'myid'});
		my @NGword = ();
		my @NGuser = ();
		if(-f $NGwordfile){
				@NGword = loadFile($NGwordfile);
				print Dumper @NGword;
		}
		if(-f $NGuserfile){
				@NGuser = loadFile($NGuserfile);
		}
		
		my $config ={
				'myID'            => $myID,
				'replyPair'       => \%replyPair,
				'id'              => $id,
				'NGword'          => \@NGword,
				'NGuser'          => \@NGuser
		};

		return $config;

}

__END__

sub execReply{
		my ($bot,$myId,$line,$NG,$OK,$dry) = @_;
		return if $line->{'user'}->{'id'} == $myId; #自分自身にはリプライ不要
		my $text = $line->{'text'};
		return if  $text =~ /@/; #@が入っていたらリプライ不要
		return if &isWordExists($text,$NG); #Ngワードが入っていたらリプライ不要

		if($dry){
				print encode_utf8();
		}
		else{
				$bot->{'twit'}->update() if (&isWordExists($line,$OK));
		}
		return;

} 