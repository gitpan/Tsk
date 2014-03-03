package Tsk;
use 5.012005;
use strict;
use warnings;
require Exporter;

=head1 NAME

Tsk - Perl bindings for Tsk (a library for disk image inspection). 

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

For now, see tests in ./t/ included with this distribution.

=head1 SEE ALSO

L<https://github.com/wsdookadr/Tsk-XS>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

our @ISA = qw(Exporter);

our $TSK_VS_TYPE_DETECT       = 0x0000;
our $TSK_VS_PART_FLAG_META    = 0x0004;
our $TSK_VS_PART_FLAG_UNALLOC = 0x0002;

our $TSK_IMG_TYPE_DETECT      = 0x0000;

our $TSK_FS_META_TYPE_DIR     = 0x0002;
our $TSK_FS_META_TYPE_REG     = 0x0001;

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

our $VERSION = '0.02';

our @EXPORT = qw{
                 $TSK_VS_TYPE_DETECT 
                 $TSK_VS_PART_FLAG_META
                 $TSK_VS_PART_FLAG_UNALLOC
                 $TSK_IMG_TYPE_DETECT

                 $TSK_FS_META_TYPE_DIR
                 $TSK_FS_META_TYPE_REG

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
