use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
use Digest::MD5 qw/md5_hex/;
BEGIN { use_ok('Tsk::Fs::Iterator') };


#65536
#105906176

my $path = "testdata/testimage001.001";
my $o = Tsk::Fs::Iterator->new($path, 65536);
my @file_list;
while(my $f = $o->next()) {
    push @file_list,"$f->{path}/$f->{name}";
    #print "$f->{path}/$f->{name}\n";
};

my @sorted_file_list = sort { $a cmp $b } @file_list;
my $md5_file_list = md5_hex(join("||",@sorted_file_list));
is($md5_file_list , "4aec1a061bb37a8770907654eeb254a0", "MD5 of file list looks good");

