package Tsk::Fs::Iterator;
use 5.012005;
use strict;
use warnings;
use Tsk;
use Tsk::Stack;
use Tsk::Fs::File;
use Tsk::Fs::Dir ;
use Tsk::Fs::Info ;
use Tsk::Img::Info ;

use Tsk::Vs::Info;
#use Tsk::Vs::PartInfo;
use Carp;

=head1 NAME

Tsk::Fs::Iterator - File iterator over files in a disk image

=head1 DESCRIPTION

This module allows for easy traversal of the a filesystem.

=head1 SYNOPSIS

    use Tsk::Fs::Iterator;
    my $iter = Tsk::Fs::Iterator->new("./testdata/testimage001.001", 65536);
    while(my $f = $iter->next() ) {
        print $f->{name}."\n";
    };

=head1 new(path, offset)

The constructor receives two parameters. The path to the image on disk and an offset indicating
where the volume to be read starts.

=cut

sub new {
    my ($class, $image, $offset) = @_;
    croak "[ERR] image path invalid"   if !defined($image)  || !-f $image;
    croak "[ERR] offset not provided"  if !defined($offset) || ! $offset =~ /^\d+$/;
    my $h = {
        fstack     => [],
        dstack     => [],
        inumstack  => undef,
        fs_info    => undef,
        img_info   => undef,
        image_path => $image,
    };
    my $self = bless $h,$class;

    my ($img_info,$fs_info);
    my $inumstack = Tsk::Stack->new();
    $img_info = Tsk::Img::Info->new();
    $img_info->open($image,$TSK_IMG_TYPE_DETECT,0);
    $fs_info = Tsk::Fs::Info->new();
    #$fs_info->open($img_info, 65536, $TSK_FS_TYPE_DETECT);

    $fs_info->open($img_info, $offset, $TSK_FS_TYPE_DETECT);
    $self->{fs_info} = $fs_info;
    $self->{img_info} = $img_info;
    $self->{inumstack} = $inumstack;
    $self->init_stacks;
    return $self;
}


=head1 INumToDir($fs_info)

Takes an inode number as a parameter and returns a Tsk::Fs::Dir structure.

=cut

sub INumToDir {
    my ($self,$dir_inum) = @_;
    my $fs_dir = Tsk::Fs::Dir->new();
    $fs_dir->open($self->{fs_info},$dir_inum);
    return $fs_dir;
};

=head2 get_separated(Tsk::Fs::File)

Gets a TskFsFile as a parameter. It expects the file to point to a directory node on the disk.
Returns two separated arrayrefs, one with files contained in $tsk_fs_file, and one with directories contained in $tsk_fs_file .

=cut

sub get_separated {
    my ($self,$x) = @_;
    my @dirs  ;
    my @files ;

    my ($fs_dir,$fs_dir_sz,$prevpath);
    #print "addr=$x->{addr}\n";
    $fs_dir = $self->INumToDir($x->{addr});
    $fs_dir_sz = $fs_dir->getSize();
    $prevpath = $x->{path};

    for(my $i=0;$i<$fs_dir_sz;$i++) {
        my $fs_file = $fs_dir->getFile($i);
        my $fs_meta = $fs_file->getMeta();
        my $fs_name = $fs_file->getName();
        my $name;
        if($fs_meta) {
            my $type = $fs_meta->getType();
            if($fs_name) {
                $name = $fs_name->getName();
            };
            if($name =~ /^\$/ || $name eq "." || $name eq "..") {
                $fs_file->close;
                next;
            };
            my $path = "$prevpath/$name";
            if($type == $TSK_FS_META_TYPE_DIR) {
                my $addr = $fs_meta->getAddr();
                push @dirs, {
                    name    => $name,
                    fs_meta => $fs_meta,
                    fs_file => $fs_file,
                    addr    => $addr,
                    path    => $path,
                };
            } else {
                push @files, {
                    name    => $name,
                    fs_meta => $fs_meta,
                    fs_file => $fs_file,
                    path    => $prevpath,
                };
            };
        };
    };
    return (\@dirs,\@files);
};

=head1 init_stacks()

Initializes stacks. Puts the root directory on the directory stack.

=cut

sub init_stacks {
    my ($self) = @_;
    my $dstack = $self->{dstack};
    my $rootINum = $self->{fs_info}->getRootINum();
    my $root_dir = $self->INumToDir($rootINum);
    push  @$dstack, {
        fs_dir  => undef,
        fs_file => undef,
        fs_meta => undef,
        name    => "",
        path    => "",
        addr    => $rootINum,
    };
};

=head1 next()

Returns next Tsk::Fs::File object.

=cut

sub next {
    my ($self) = @_;
    my $fstack = $self->{fstack};
    my $dstack = $self->{dstack};
    croak "[ERR] not initialized" if !defined($self->{fs_info}) || !defined($self->{inumstack});

    my $inumstack = $self->{inumstack};

    if(@$fstack > 0) {
        my $newFile = pop(@$fstack);
        return $newFile;
    };

    if(@$dstack > 0) {
        my $newDir = pop(@$dstack);
        $inumstack->push($newDir->{addr});
        my ($dirs, $newFiles) = $self->get_separated($newDir);
        my @newDirs = grep { $inumstack->find($_->{addr}) == 0 } @$dirs;
        push @$dstack,@newDirs   if @newDirs   > 0;
        push @$fstack,@$newFiles if @$newFiles > 0;
        return $newDir;
    };
    return undef;
}

sub DESTROY {
    my ($self) = @_;
    $self->{fs_info}->close;
}

=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

1;
