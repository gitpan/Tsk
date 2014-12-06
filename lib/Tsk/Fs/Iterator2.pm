package Tsk::Fs::Iterator2;
use 5.012005;
use strict;
use warnings;
use Tsk;
use Tsk::Stack;
use Tsk::Fs::File;
use Tsk::Fs::Dir;
use Tsk::Fs::Info ;
use Tsk::Fs::Iterator;
use Tsk::Img::Info ;
use Tsk::Vs::Info;
use Carp;
our $VERSION = '0.041';
=head1 NAME

Tsk::Fs::Iterator2 - File iterator over all files/directories in all volumes of a disk image

=head1 DESCRIPTION

This module allows for easy traversal of all volumes in a disk image.

=head1 SYNOPSIS

    use Tsk::Fs::Iterator2;
    my $iter = Tsk::Fs::Iterator2->new("disk-image.dsk");
    while(my $f = $iter->next() ) {
        print $f->getFileName()."\n";
    };

=cut


sub new {
    my ($self,$image) = @_;
    my $h = bless {
        tsk_fs_iterator => undef,
        volume_offsets  => undef,
        image_path      => $image
    },$self;

    croak "[ERR] image path invalid" if !-f $image;
    $h->find_volumes;
    $h->next_volume;
    return $h;
};

=head1 next_volume()

Switches processing on the next volume (used internally by next and next_node).

=cut

sub next_volume {
    my ($self) = @_;
    my $offset = pop @{$self->{volume_offsets}};
    if(!$offset) {
        return undef;
    };
    my $fs_iter = Tsk::Fs::Iterator->new($self->{image_path}, $offset);
    delete $self->{tsk_fs_iterator};
    $self->{tsk_fs_iterator} = $fs_iter;
};

=head1 next_node 

Returns the next Tsk::Fs::File object.

=cut

sub next_node {
    my ($self) = @_;
    my $iter = $self->{tsk_fs_iterator};
    my $i = $iter->next();
    while(!$iter->done && !defined($i)){
        $i = $iter->next();
    };
    if($iter->done) {
        if(!$self->next_volume) {
            return undef;
        } else {
            $i = $iter->next;
        };
    };
    return $i;
};

=head1 next()

Alias for next_node.

=cut

sub next {
    my ($self) = @_;
    return $self->next_node;
};

=head1 find_volumes()

Finds the volumes inside the disk image.

=cut

sub find_volumes {
    my ($self) = @_;
    my $img_info = Tsk::Img::Info->new();
    $img_info->open($self->{image_path},$TSK_IMG_TYPE_DETECT,0);

    my $vs_info = Tsk::Vs::Info->new();

    my @volume_offsets = ();
    if( ($vs_info->open($img_info,0, $TSK_VS_TYPE_DETECT)) == 1) {

    } else {
        my $partCount = $vs_info->getPartCount();
        for(my $i = 0; $i < $partCount ; $i++) {
            my $vs_part = $vs_info->getPart($i);
            my $flags = $vs_part->getFlags();
            next if $flags & $TSK_VS_PART_FLAG_META;
            next if $flags & $TSK_VS_PART_FLAG_UNALLOC;
            my $offset = $vs_part->getStart() * $vs_info->getBlockSize();
            push @volume_offsets, $offset;
        };
    };
    $self->{volume_offsets} = \@volume_offsets;
};


=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

1;
