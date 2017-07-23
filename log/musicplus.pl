#! /usr/bin/perl -W
#
# Convert a DBF file from MusicPlus to a standard Rivendell log import
#
# (C) Copyright 2017 Fred Gleason <fredg@paravelsystems.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2 as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

use XBase;

if(scalar(@ARGV)!=2) {
    print "USAGE: musicplus.pl <src-file> <dst-file>\n";
    exit 1;
}

my $srcfile=$ARGV[0];
my $dstfile=$ARGV[1];
my $table = new XBase $srcfile or die XBase->errstr;
open(F,">",$dstfile) or die "Cannot open output file";
my $hour=0;
my $seconds=0;

for(my $i=0;$i<$table->last_record;$i++) {
    my @id=$table->get_record($i,("MM_DESC","MM_ARTIST","MM_MINUTES","MM_SECONDS","MM_HOUR","MM_SEQ_NO","MM_ID_CODE","MM_TRACK","BREAK"));
    if(length($id[1])>0) {
	my $len=60*$id[3]+$id[4];
	if($hour==$id[5]) {
	    $seconds+=$len;
	}
	else {
	    $seconds=0;
	    $hour=$id[5];
	}
	my $title=$id[1];
	my $cartnum=sprintf("%-15d",(substr $id[7],2,8).$id[8]);
	if((substr $title,0,11) eq "VOICE TRACK") {
	    $cartnum="TRACK          ";
	}
	printf(F"%02d:%02d:%02d  %s%-34s 00:%02d:%02d\n",
	       $hour,$seconds/60,$seconds % 60,$cartnum,
	       (substr $id[1],0,34),$id[3],$id[4]);
	if($id[9] ne "*") {
	    printf(F"%02d:%02d:%02d  BREAK          SPOT BREAK                         00:04:00\n",
		   $hour,$seconds/60,$seconds % 60,
		   $id[3],$id[4]);
	    
	}
    }
}
close(F);
