package Tsk::Fs::File;
use 5.012005;
use strict;
use warnings;
use Tsk;
require Exporter;

our $VERSION = '0.041';
our @ISA = qw(Exporter);
our @EXPORT = @Tsk::EXPORT;

=head1 NAME

Tsk::Fs::File - Sleuthkit File object

=head1 SYNOPSIS

    use Tsk;
    my $file = Tsk::Fs::File->new();

=head1 new()

The constructor receives no parameters and creates a TskFsFile object.

=head1 getMeta()

Returns a L<Tsk::Fs::Meta> object with metadata associated with the file

=head1 open(Tsk::Fs::Info a_fs_info,Tsk::Fs::File a_fs_file,a_addr)

Returns a 0 on success and 1 on error. Opens a file that is present the disk image. 
Takes 3 parameters, the first indicating the filesystem TskFsInfo object,
the second is a L<Tsk::Fs::File> object, and the third is the inode of the file.

=head1 getSize()

Returns the size of the file in bytes.

=head1 read(offset, len)

Reads C<len> bytes starting at C<offset> and returns them.

=head1 getName()

Returns a L<TskFsName> data structure containing metadata about the file.

=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

1;
