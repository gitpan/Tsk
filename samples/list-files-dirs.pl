#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use lib './blib/arch/auto/Tsk';
use Tsk;
use Tsk::Fs::Iterator2;
use Devel::Peek;
## Overview: This sample illustrates traversing
## every directory and file in the filesystem
my $iter = Tsk::Fs::Iterator2->new("testdata/testimage001.001");
my $file_count = 0;
my $dir_count = 0;
while(my $file = $iter->next()) { 
    my $type = -1;
    if( ref($file) eq "Tsk::Fs::File") {
        my $ctime = 0;
        my $inode = 0;
        $ctime = $file->getMeta()->getCTime();
        $type = $file->getMeta()->getType();
        $inode = $file->getMeta()->getAddr();
        my $fullpath = $iter->{tsk_fs_iterator}->get_current_path();
        $fullpath .= "/".$file->getFileName();
        print "FILE inode=$inode path=$fullpath\n";
    } elsif (ref($file) eq "Tsk::Fs::Dir" ) {
        my $fullpath = $iter->{tsk_fs_iterator}->get_current_path();
        print "DIR $fullpath\n";
        $type = $file->getFsFile()->getMeta()->getType();
    } else {
    };
    if($type > 0) {
        $dir_count++  if $type == $TSK_FS_META_TYPE_DIR;
        $file_count++ if $type == $TSK_FS_META_TYPE_REG;
    };
};

print "file_count => $file_count \n";
print "dir_count => $dir_count \n";
