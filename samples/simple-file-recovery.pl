#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use lib './blib/arch/auto/Tsk';
use Tsk;
use Tsk::Fs::Iterator2;

# Overview: Looking for files that have the unallocated flag set,
# then retrieving their actual inode through TskFsName and finally
# recovering their contents

## using the flags of the TskFsName structure
## and the inode from TskFsName->getMetaAddr()

my $iter = Tsk::Fs::Iterator2->new("testdata/testimage001-deleted-file.001");
my $file_count = 0;
my $dir_count = 0;
while(my $file = $iter->next()) { 
    my $type = -1;
    if( ref($file) eq "Tsk::Fs::File") {
        my $name = $file->getName();
        my $flags = $name->getFlags;
        if($flags & $TSK_FS_NAME_FLAG_UNALLOC) {
            ## the inode returned by ->getMeta()->getAddr() is irrelevant(actually zero) 
            ## in this case because the file we're looking for is unallocated, however
            ## we can still retrieve it from the TskFsName data structure
            ##
            ## since the file is unallocated, its inode will be 0 and its metadata
            ## and size will also be inconclusive.
            my $inode = $name->getMetaAddr();

            my $filename = $file->getFileName();
            my $recovered_filename = "recovered-$filename";
            my $recovered_filepath = "/tmp/$recovered_filename";

            ## open file associated with the inode found
            my $inode_file = Tsk::Fs::File->new();

            ## get filesystem the iterator is iterating on
            my $fs_info = $iter->{tsk_fs_iterator}->{fs_info};
            $inode_file->open($fs_info,$inode_file,$inode);
            my $size = $inode_file->getSize();

            ## recover the file and save it to disk
            print "inode=$inode name=$filename size=$size\n";
            open my $fh,">",$recovered_filepath;
            print $fh $inode_file->read(0,$size);
            close $fh;
        };
    };
};

