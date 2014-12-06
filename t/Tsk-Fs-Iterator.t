use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
use Digest::MD5 qw/md5_hex/;
BEGIN { use_ok('Tsk::Fs::Iterator') };
{
    #######################################################################################
    # Iterate through all the files, get the file list, sort it, MD5 it, and check the MD5
    #######################################################################################
    my $path = "testdata/testimage001.001";
    my $o = Tsk::Fs::Iterator->new($path,65536);
    my @file_list;
    while(my $f = $o->next()) {
        next unless ref($f) eq "Tsk::Fs::File";
        push @file_list,$f->getFileName();
    };
    my @sorted_file_list = sort { $a cmp $b } @file_list;
    my $md5_file_list = md5_hex(join("||",@sorted_file_list));
    is($md5_file_list , "323906991835a2074dd619fa103c0225", "MD5 of file list looks good");
};
