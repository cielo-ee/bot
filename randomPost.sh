#!/bin/sh
#. /home/syu/.bashrc
eval $(perl -I$HOME/local/lib/perl5 -Mlocal::lib=$HOME/local)
cd /home/syu/mion_bot/
./mion_bot.pl
