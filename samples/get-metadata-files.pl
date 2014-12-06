#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use lib './blib/arch/auto/Tsk';
use Carp;
use Tsk;
use Tsk::Img::Info;
use Tsk::Fs::Info;
use Tsk::Fs::File;

## Overview: Using Tsk(sleuthkit Perl bindings) 
##           to extract metadata files from an NTFS image

my $path_to_disk_image = ($ARGV[0] || "testdata/win7big.raw");
my $img_info = Tsk::Img::Info->new();
my $vs_info = Tsk::Vs::Info->new();
$img_info->open($path_to_disk_image,$TSK_IMG_TYPE_DETECT,0);
my $vs_retval = $vs_info->open($img_info,0, $TSK_VS_TYPE_DETECT);
croak "[ERROR] volume system cannot be opened" if $vs_retval == 1;

## get start offsets for each file system in the image
my @fs_offsets = ();
my $partCount = $vs_info->getPartCount();
for(my $i = 0; $i < $partCount ; $i++) {
    my $vs_part = $vs_info->getPart($i);
    my $flags = $vs_part->getFlags();
    next if $flags & $TSK_VS_PART_FLAG_META;
    next if $flags & $TSK_VS_PART_FLAG_UNALLOC;
    push @fs_offsets, ($vs_part->getStart() * $vs_info->getBlockSize());
}

## iterate over each file system in the image
for my $start_offset (@fs_offsets) {
    my $fs_info = Tsk::Fs::Info->new();
    $fs_info->open($img_info,$start_offset, $TSK_FS_TYPE_DETECT);
    my $file;
    my $output_path_mft     = "/tmp/mft_$start_offset.raw";
    my $output_path_logfile = "/tmp/logfile_$start_offset.raw";
    my $output_path_usn     = "/tmp/usn_$start_offset.raw";

    print "[X] Extracting MFT\n";
    print "==================\n";
    $file = Tsk::Fs::File->new();
    $file->open($fs_info,$file,$NTFS_INODE_MFT);
    for(my $attr_idx=0;$attr_idx<$file->getAttrSize();$attr_idx++) {
        my $attr = $file->getAttr($attr_idx);
        my $attr_type = $attr->getType();
        my $attr_size = $attr->getSize();
        next unless $attr_type == $TSK_FS_ATTR_TYPE_NTFS_DATA;
        my $mft_contents = $attr->read(0,$attr_size);
        open my $fh, ">" , $output_path_mft;
        print $fh $mft_contents;
        close $fh;
    };
    $file->close();

    print "[X] Extracting LogFile\n";
    print "======================\n";
    $file = Tsk::Fs::File->new();
    $file->open($fs_info,$file,$NTFS_INODE_LOGFILE);
    for(my $attr_idx=0;$attr_idx<$file->getAttrSize();$attr_idx++) {
        my $attr = $file->getAttr($attr_idx);
        my $attr_type = $attr->getType();
        my $attr_size = $attr->getSize();
        next unless $attr_type == $TSK_FS_ATTR_TYPE_NTFS_DATA;
        my $mft_contents = $attr->read(0,$attr_size);
        open my $fh, ">" , $output_path_logfile;
        print $fh $mft_contents;
        close $fh;
    };
    $file->close();

    print "[X] Extracting UsnJrnl\n";
    print "======================\n";
    my $extend_dir = Tsk::Fs::Dir->new();
    $extend_dir->open($fs_info,$NTFS_INODE_EXTEND);
    my $extend_dir_files = $extend_dir->getSize();
    for(my $file_idx=0; $file_idx < $extend_dir_files; $file_idx++) {
        my $file = $extend_dir->getFile($file_idx);
        my $file_name = $file->getName()->getName();
        next unless ($file_name && $file_name eq "\$UsnJrnl");
        for(my $attr_idx=0;$attr_idx<$file->getAttrSize();$attr_idx++) {
            my $attr = $file->getAttr($attr_idx);
            my $attr_type = $attr->getType();
            my $attr_size = $attr->getSize();
            my $attr_name = $attr->getName();
            next unless ($attr_name && $attr_name eq "\$J");
            my $usn_contents = $attr->read(0,$attr_size);
            open my $fh, ">" , $output_path_usn;
            print $fh $usn_contents;
            close $fh;
        }
    }
    $extend_dir->close();
}

