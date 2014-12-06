package Tsk::Fs::Iterator;
use 5.012005;
use strict;
use warnings;
use Tsk;
use Tsk::Stack;
use Tsk::Fs::File;
use Tsk::Fs::Dir;
use Tsk::Fs::Info;
use Tsk::Img::Info;
use Tsk::Vs::Info;
#use Tsk::Vs::PartInfo;
use Carp;

our $VERSION = '0.041';
$Carp::Verbose = 1;

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

The constructor receives two parameters. The path to the image on disk
and an offset indicating where the volume to be read starts.

=cut

sub new {
    my ($class, $image, $offset) = @_;
    croak "[ERR] image path invalid"   if !defined($image)  || !-f $image;
    croak "[ERR] offset not provided"  if !defined($offset) || ! $offset =~ /^\d+$/;
    my $h = {
        fdstack    => [],
        pathstack  => [],
        inumstack  => undef,
        fs_info    => undef,
        img_info   => undef,
        image_path => $image,
    };
    my $self = bless $h,$class;

    my ($img_info,$fs_info);
    $img_info = Tsk::Img::Info->new();
    $img_info->open($image,$TSK_IMG_TYPE_DETECT,0);
    $fs_info = Tsk::Fs::Info->new();

    $fs_info->open($img_info, $offset, $TSK_FS_TYPE_DETECT);
    $self->{fs_info} = $fs_info;
    $self->{img_info} = $img_info;
    $self->init_stacks;
    return $self;
}

=head1 get_addr($obj)

Takes as parameter either a Tsk::Fs::Dir or a Tsk::Fs:File and returns
the meta address.

=cut

sub get_addr {
    my ($obj) = @_;
    my $robj = ref($obj);
    if(     $robj eq 'Tsk::Fs::Dir') {
        return $obj->getMetaAddr;
    } elsif($robj eq 'Tsk::Fs::File') {
        return $obj->getMeta->getAddr;
    };

    return undef;
};

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

Gets a TskFsFile as a parameter. It expects the file to point to a
directory node on the disk.  Returns two separated arrayrefs, one with
files contained in $tsk_fs_file, and one with directories contained in
$tsk_fs_file .

=cut

sub get_separated {
    my ($self,$x) = @_;
    my @dirs  ;
    my @files ;

    my ($fs_dir,$fs_dir_sz,$prevpath);
    $fs_dir = $self->INumToDir(get_addr($x));
    if(!defined($fs_dir)) {
        return undef;
    };
    $fs_dir_sz = $fs_dir->getSize();

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
            if($name eq "." || $name eq "..") {
                $fs_file->close;
                next;
            };
            if(     $type == $TSK_FS_META_TYPE_DIR) {
                my $new_fs_dir = $self->INumToDir(get_addr($fs_file));
                push @dirs, $new_fs_dir;
            } elsif($type == $TSK_FS_META_TYPE_REG) {
                push @files,$fs_file;
            } else {
                ## other TSK_FS_META_TYPE_* (see lib/Tsk.pm for other values of $type)
                push @files,$fs_file;
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
    my $inumstack = Tsk::Stack->new();
    my $fdstack = $self->{fdstack};
    my $rootINum = $self->{fs_info}->getRootINum();
    my $root_dir = $self->INumToDir($rootINum);
    push  @$fdstack, $root_dir;
    $self->{inumstack} = $inumstack;
}

sub done {
    my ($self) = @_;
    my $fdstack = $self->{fdstack};
    return @$fdstack == 0;
}

=head1 next()

Returns the next Tsk::Fs::File object.

=cut

sub next {
    my ($self) = @_;
    my $fdstack = $self->{fdstack};
    croak "[ERR] not initialized" 
        if !defined($self->{fs_info}) || 
           !defined($self->{inumstack});

    my $inumstack = $self->{inumstack};

    if(@$fdstack > 0) {
        my $f = pop(@$fdstack);

        if(ref($f) eq "Tsk::Fs::Dir") {
            ## first time this directory is seen
            if( $inumstack->find(get_addr($f)) == 0) {
                ## put the directory back on the stack as it will
                ## be popped one last time after all of its contents
                ## will be processed
                push @$fdstack, $f;
                my $temp_fs_file = Tsk::Fs::File->new();
                $temp_fs_file->open($self->{fs_info},$temp_fs_file,$f->getMetaAddr());
                my $dirname = $temp_fs_file->getFileName();
                #print "getFsFile => ".$f->getFsFile->getName->getName ."\n";
                $self->enter_dir_hook($dirname);
                undef $temp_fs_file;
            } else {
                ## this is the 2nd time we see the directory on the stack
                ## and this means we've traversed all of its contents
                ## and now it's time to pop it off definitively
                $self->exit_dir_hook();
                return $f;
            }
            $inumstack->push(get_addr($f));
            my ($dirs, $files) = $self->get_separated($f);
            ## directories that haven't been visited before
            my @newDirs  = grep { $inumstack->find(get_addr($_)) == 0 } @$dirs;
            ## files contained in the current directory
            my @newFiles = @$files;
            push @$fdstack,@newDirs;
            push @$fdstack,@newFiles;
            return $f;
        } elsif(ref($f) eq "Tsk::Fs::File" ) {
            return $f;
        };

    };
    return undef;
}

sub enter_dir_hook {
    my ($self, $name) = @_;
    push @{$self->{pathstack}}, $name;
}

sub exit_dir_hook {
    my ($self) = @_;
    pop @{$self->{pathstack}};
}

sub get_current_path {
    my ($self) = @_;
    return join("/", @{ $self->{pathstack} });
}

sub DESTROY {
    my ($self) = @_;
    my $fdstack = $self->{fdstack};
    while(@$fdstack){ pop(@$fdstack); };
    $self->{fs_info}->close;
}
=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

1;
