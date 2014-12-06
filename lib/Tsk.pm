package Tsk;
use 5.012005;
use strict;
use warnings;
require Exporter;

=head1 NAME

Tsk - Perl bindings for Tsk (forensic analysis library). 

=head1 VERSION

Version 0.04

=head1 DESCRIPTION

Tsk is a module that provides Perl bindings for the sleuthkit toolkit.

It can be used for a variety of purposes:

=over

=item * filesystem crash recovery

=item * forensic analysis, investigations, incident response

=item * learning low-level filesystem (meta)data operations and data structures

=back

=head1 SYNOPSIS

See the tests in the C<t/> directory as well as the samples in C<samples>.

=head1 INSTALL

If you want to install using cpanm, make sure you allow for big timeouts
(the dependencies need to be built):

    cpanm --configure-timeout 3600 --build-timeout 3600 Tsk

=head1 SAMPLES

This distribution ships with code samples that illustrate sleuthkit use-cases:

=over

=item * C</samples/get-metadata-files.pl>

Extracts the metadata files $Mft, $LogFile, $UsnJrnl from an NTFS file system.

=item * C</samples/list-files-dirs.pl>

Opens a disk image and walks through the filesystem structure.

=item * C</samples/reading-file-in-batches.pl>

Opens a disk image nad reads a file in batches.

=item * C</samples/simple-file-recovery.pl>

Recovers a deleted file from a disk image.

=back

=head1 INSTALLATION

If you want to install using cpanm, make sure you allow for big timeouts
(the dependency has to be built):

    cpanm --configure-timeout 3600 --build-timeout 3600 Tsk

=head1 SEE ALSO

L<https://github.com/wsdookadr/Tsk-XS>

L<http://www.sleuthkit.org/>

L<http://github.com/sleuthkit/sleuthkit>

=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 PATCHES

Patches welcome 24/7

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

our @ISA = qw(Exporter);

our $TSK_VS_TYPE_DETECT       = 0x0000;
our $TSK_VS_PART_FLAG_META    = 0x0004;
our $TSK_VS_PART_FLAG_UNALLOC = 0x0002;

our $TSK_IMG_TYPE_DETECT      = 0x0000;

our $TSK_FS_META_TYPE_UNDEF = 0x0000;
our $TSK_FS_META_TYPE_REG   = 0x0001;   # Regular file
our $TSK_FS_META_TYPE_DIR   = 0x0002;   # Directory file
our $TSK_FS_META_TYPE_FIFO  = 0x0003;   # Named pipe (fifo)
our $TSK_FS_META_TYPE_CHR   = 0x0004;   # Character device
our $TSK_FS_META_TYPE_BLK   = 0x0005;   # Block device
our $TSK_FS_META_TYPE_LNK   = 0x0006;   # Symbolic link
our $TSK_FS_META_TYPE_SHAD  = 0x0007;   # SOLARIS ONLY
our $TSK_FS_META_TYPE_SOCK  = 0x0008;   # UNIX domain socket
our $TSK_FS_META_TYPE_WHT   = 0x0009;   # Whiteout
our $TSK_FS_META_TYPE_VIRT  = 0x000a;   # "Virtual File" created by TSK for file system areas

our $TSK_FS_NAME_FLAG_ALLOC   = 0x0001;
our $TSK_FS_NAME_FLAG_UNALLOC = 0x0002;

### $TSK_FS_TYPE_*
our $TSK_FS_TYPE_DETECT         = 0x00000000;
our $TSK_FS_TYPE_NTFS           = 0x00000001;
our $TSK_FS_TYPE_NTFS_DETECT    = 0x00000001;
our $TSK_FS_TYPE_FAT12          = 0x00000002;
our $TSK_FS_TYPE_FAT16          = 0x00000004;
our $TSK_FS_TYPE_FAT32          = 0x00000008;
our $TSK_FS_TYPE_FAT_DETECT     = 0x0000000e;
our $TSK_FS_TYPE_FFS1           = 0x00000010;
our $TSK_FS_TYPE_FFS1B          = 0x00000020;
our $TSK_FS_TYPE_FFS2           = 0x00000040;
our $TSK_FS_TYPE_FFS_DETECT     = 0x00000070;
our $TSK_FS_TYPE_EXT2           = 0x00000080;
our $TSK_FS_TYPE_EXT3           = 0x00000100;
our $TSK_FS_TYPE_EXT_DETECT     = 0x00002180;
our $TSK_FS_TYPE_SWAP           = 0x00000200;
our $TSK_FS_TYPE_SWAP_DETECT    = 0x00000200;
our $TSK_FS_TYPE_RAW            = 0x00000400;
our $TSK_FS_TYPE_RAW_DETECT     = 0x00000400;
our $TSK_FS_TYPE_ISO9660        = 0x00000800;
our $TSK_FS_TYPE_ISO9660_DETECT = 0x00000800;
our $TSK_FS_TYPE_HFS            = 0x00001000;
our $TSK_FS_TYPE_HFS_DETECT     = 0x00001000;
our $TSK_FS_TYPE_EXT4           = 0x00002000;
our $TSK_FS_TYPE_YAFFS2         = 0x00004000;
our $TSK_FS_TYPE_YAFFS2_DETECT  = 0x00004000;
our $TSK_FS_TYPE_UNSUPP         = 0xffffffff;

our $TSK_FS_META_FLAG_ALLOC   = 0x01;
our $TSK_FS_META_FLAG_UNALLOC = 0x02;
our $TSK_FS_META_FLAG_USED    = 0x04;
our $TSK_FS_META_FLAG_UNUSED  = 0x08;
our $TSK_FS_META_FLAG_COMP    = 0x10;
our $TSK_FS_META_FLAG_ORPHAN  = 0x20;

our $TSK_FS_FILE_READ_FLAG_NONE  = 0x00;
our $TSK_FS_FILE_READ_FLAG_SLACK = 0x01;
our $TSK_FS_FILE_READ_FLAG_NOID  = 0x02;


## according to http://msdn.microsoft.com/library/cc781134(v=ws.10).aspx
## (or https://web.archive.org/web/20141204142750/http://msdn.microsoft.com/library/cc781134(v=ws.10).aspx )
## these are the metadata files stored on the MFT
our $NTFS_INODE_MFT     = 0;
our $NTFS_INODE_MFTMIRR = 1;
our $NTFS_INODE_LOGFILE = 2;
our $NTFS_INODE_VOLUME  = 3;
our $NTFS_INODE_ATTRDEF = 4;
our $NTFS_INODE_BITMAP  = 6;
our $NTFS_INODE_BOOT    = 7;
our $NTFS_INODE_BADCLUS = 8;
our $NTFS_INODE_SECURE  = 9;
our $NTFS_INODE_UPCASE  = 10;
our $NTFS_INODE_EXTEND  = 11;

our $TSK_FS_ATTR_TYPE_NOT_FOUND     = 0x00;
our $TSK_FS_ATTR_TYPE_DEFAULT       = 0x01;
our $TSK_FS_ATTR_TYPE_NTFS_SI       = 0x10;
our $TSK_FS_ATTR_TYPE_NTFS_ATTRLIST = 0x20;
our $TSK_FS_ATTR_TYPE_NTFS_FNAME    = 0x30;
our $TSK_FS_ATTR_TYPE_NTFS_VVER     = 0x40;
our $TSK_FS_ATTR_TYPE_NTFS_OBJID    = 0x40;
our $TSK_FS_ATTR_TYPE_NTFS_SEC      = 0x50;
our $TSK_FS_ATTR_TYPE_NTFS_VNAME    = 0x60;
our $TSK_FS_ATTR_TYPE_NTFS_VINFO    = 0x70;
our $TSK_FS_ATTR_TYPE_NTFS_DATA     = 0x80;
our $TSK_FS_ATTR_TYPE_NTFS_IDXROOT  = 0x90;
our $TSK_FS_ATTR_TYPE_NTFS_IDXALLOC = 0xA0;
our $TSK_FS_ATTR_TYPE_NTFS_BITMAP   = 0xB0;
our $TSK_FS_ATTR_TYPE_NTFS_SYMLNK   = 0xC0;
our $TSK_FS_ATTR_TYPE_NTFS_REPARSE  = 0xC0;
our $TSK_FS_ATTR_TYPE_NTFS_EAINFO   = 0xD0;
our $TSK_FS_ATTR_TYPE_NTFS_EA       = 0xE0;
our $TSK_FS_ATTR_TYPE_NTFS_PROP     = 0xF0;
our $TSK_FS_ATTR_TYPE_NTFS_LOG      = 0x100;
our $TSK_FS_ATTR_TYPE_UNIX_INDIR    = 0x1001;
our $TSK_FS_ATTR_TYPE_UNIX_EXTENT   = 0x1002;
our $TSK_FS_ATTR_TYPE_HFS_DEFAULT   = 0x01;
our $TSK_FS_ATTR_TYPE_HFS_DATA      = 0x1100;
our $TSK_FS_ATTR_TYPE_HFS_RSRC      = 0x1101;
our $TSK_FS_ATTR_TYPE_HFS_EXT_ATTR  = 0x1102;
our $TSK_FS_ATTR_TYPE_HFS_COMP_REC  = 0x1103;

our $TSK_FS_BLOCK_FLAG_UNUSED  = 0x0000;
our $TSK_FS_BLOCK_FLAG_ALLOC   = 0x0001;
our $TSK_FS_BLOCK_FLAG_UNALLOC = 0x0002;
our $TSK_FS_BLOCK_FLAG_CONT    = 0x0004;
our $TSK_FS_BLOCK_FLAG_META    = 0x0008;
our $TSK_FS_BLOCK_FLAG_BAD     = 0x0010;
our $TSK_FS_BLOCK_FLAG_RAW     = 0x0020;
our $TSK_FS_BLOCK_FLAG_SPARSE  = 0x0040;
our $TSK_FS_BLOCK_FLAG_COMP    = 0x0080;
our $TSK_FS_BLOCK_FLAG_RES     = 0x0100;
our $TSK_FS_BLOCK_FLAG_AONLY   = 0x0200;


our $VERSION = '0.04';

our @EXPORT = qw{
                 $TSK_VS_TYPE_DETECT 
                 $TSK_VS_PART_FLAG_META
                 $TSK_VS_PART_FLAG_UNALLOC
                 $TSK_IMG_TYPE_DETECT

                 $TSK_FS_META_TYPE_UNDEF
                 $TSK_FS_META_TYPE_REG
                 $TSK_FS_META_TYPE_DIR
                 $TSK_FS_META_TYPE_FIFO
                 $TSK_FS_META_TYPE_CHR
                 $TSK_FS_META_TYPE_BLK
                 $TSK_FS_META_TYPE_LNK
                 $TSK_FS_META_TYPE_SHAD
                 $TSK_FS_META_TYPE_SOCK
                 $TSK_FS_META_TYPE_WHT
                 $TSK_FS_META_TYPE_VIRT


                 $TSK_FS_NAME_FLAG_ALLOC
                 $TSK_FS_NAME_FLAG_UNALLOC

                 $TSK_FS_TYPE_DETECT         
                 $TSK_FS_TYPE_NTFS           
                 $TSK_FS_TYPE_NTFS_DETECT    
                 $TSK_FS_TYPE_FAT12          
                 $TSK_FS_TYPE_FAT16          
                 $TSK_FS_TYPE_FAT32          
                 $TSK_FS_TYPE_FAT_DETECT     
                 $TSK_FS_TYPE_FFS1           
                 $TSK_FS_TYPE_FFS1B          
                 $TSK_FS_TYPE_FFS2           
                 $TSK_FS_TYPE_FFS_DETECT     
                 $TSK_FS_TYPE_EXT2           
                 $TSK_FS_TYPE_EXT3           
                 $TSK_FS_TYPE_EXT_DETECT     
                 $TSK_FS_TYPE_SWAP           
                 $TSK_FS_TYPE_SWAP_DETECT    
                 $TSK_FS_TYPE_RAW            
                 $TSK_FS_TYPE_RAW_DETECT     
                 $TSK_FS_TYPE_ISO9660        
                 $TSK_FS_TYPE_ISO9660_DETECT 
                 $TSK_FS_TYPE_HFS            
                 $TSK_FS_TYPE_HFS_DETECT     
                 $TSK_FS_TYPE_EXT4           
                 $TSK_FS_TYPE_YAFFS2         
                 $TSK_FS_TYPE_YAFFS2_DETECT  
                 $TSK_FS_TYPE_UNSUPP         

                 $TSK_FS_META_FLAG_ALLOC  
                 $TSK_FS_META_FLAG_UNALLOC
                 $TSK_FS_META_FLAG_USED   
                 $TSK_FS_META_FLAG_UNUSED 
                 $TSK_FS_META_FLAG_COMP   
                 $TSK_FS_META_FLAG_ORPHAN 

                 $TSK_FS_FILE_READ_FLAG_NONE  
                 $TSK_FS_FILE_READ_FLAG_SLACK 
                 $TSK_FS_FILE_READ_FLAG_NOID  

                 $NTFS_INODE_MFT     
                 $NTFS_INODE_MFTMIRR 
                 $NTFS_INODE_LOGFILE 
                 $NTFS_INODE_VOLUME  
                 $NTFS_INODE_ATTRDEF 
                 $NTFS_INODE_BITMAP  
                 $NTFS_INODE_BOOT    
                 $NTFS_INODE_BADCLUS 
                 $NTFS_INODE_SECURE  
                 $NTFS_INODE_UPCASE  
                 $NTFS_INODE_EXTEND  

                 $TSK_FS_ATTR_TYPE_NOT_FOUND    
                 $TSK_FS_ATTR_TYPE_DEFAULT      
                 $TSK_FS_ATTR_TYPE_NTFS_SI      
                 $TSK_FS_ATTR_TYPE_NTFS_ATTRLIST
                 $TSK_FS_ATTR_TYPE_NTFS_FNAME   
                 $TSK_FS_ATTR_TYPE_NTFS_VVER    
                 $TSK_FS_ATTR_TYPE_NTFS_OBJID   
                 $TSK_FS_ATTR_TYPE_NTFS_SEC     
                 $TSK_FS_ATTR_TYPE_NTFS_VNAME   
                 $TSK_FS_ATTR_TYPE_NTFS_VINFO   
                 $TSK_FS_ATTR_TYPE_NTFS_DATA    
                 $TSK_FS_ATTR_TYPE_NTFS_IDXROOT 
                 $TSK_FS_ATTR_TYPE_NTFS_IDXALLOC
                 $TSK_FS_ATTR_TYPE_NTFS_BITMAP  
                 $TSK_FS_ATTR_TYPE_NTFS_SYMLNK  
                 $TSK_FS_ATTR_TYPE_NTFS_REPARSE 
                 $TSK_FS_ATTR_TYPE_NTFS_EAINFO  
                 $TSK_FS_ATTR_TYPE_NTFS_EA      
                 $TSK_FS_ATTR_TYPE_NTFS_PROP    
                 $TSK_FS_ATTR_TYPE_NTFS_LOG     
                 $TSK_FS_ATTR_TYPE_UNIX_INDIR   
                 $TSK_FS_ATTR_TYPE_UNIX_EXTENT  
                 $TSK_FS_ATTR_TYPE_HFS_DEFAULT  
                 $TSK_FS_ATTR_TYPE_HFS_DATA     
                 $TSK_FS_ATTR_TYPE_HFS_RSRC     
                 $TSK_FS_ATTR_TYPE_HFS_EXT_ATTR 
                 $TSK_FS_ATTR_TYPE_HFS_COMP_REC 

                 $TSK_FS_BLOCK_FLAG_UNUSED
                 $TSK_FS_BLOCK_FLAG_ALLOC
                 $TSK_FS_BLOCK_FLAG_UNALLOC
                 $TSK_FS_BLOCK_FLAG_CONT
                 $TSK_FS_BLOCK_FLAG_META
                 $TSK_FS_BLOCK_FLAG_BAD
                 $TSK_FS_BLOCK_FLAG_RAW
                 $TSK_FS_BLOCK_FLAG_SPARSE
                 $TSK_FS_BLOCK_FLAG_COMP
                 $TSK_FS_BLOCK_FLAG_RES
                 $TSK_FS_BLOCK_FLAG_AONLY

                 describe_flag
                };


sub describe_flag {
    my ($flag,$pattern) = @_;
    my @relevant_flags = grep { $_ =~ $pattern } @EXPORT;
    my @flags_on ;
    my @flags_off;
    for my $f (@relevant_flags) {
        if( $flag & eval($f) ) {
            push @flags_on , $f;
        } else {
            push @flags_off, $f;
        };
    };
    return @flags_on;
};



require XSLoader;
XSLoader::load('Tsk', $VERSION);

1;
