use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
use Devel::Peek;
use Tsk::Img::Info;
use Tsk::Fs::Info;
use Tsk::Fs::Dir;
use Tsk::Fs::File;
use Tsk::Stack;
use Digest::MD5 qw/md5_hex/;
use Devel::Symdump;

my $raw_image_path = "testdata/testimage001.001";
my $aff_image_path = "testdata/testimage001.aff";
my $ewf_image_path = "testdata/testimage001.E01";
my $t2 = "testdata/testimage001.E012";

sub open_image {
    my $img_info = Tsk::Img::Info->new();
    $img_info->open($_[0],$TSK_IMG_TYPE_DETECT,0);
}

ok(!open_image($raw_image_path),"Raw image format opened"    );
ok(!open_image($aff_image_path),"AFF image format opened"    );
ok(!open_image($ewf_image_path),"EWF image format opened"    );
ok( open_image($t2),"Non-existing image test(negative test)" );

