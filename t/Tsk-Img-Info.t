use strict;
use warnings;
#use Devel::Peek;
use Test::More qw/no_plan/;
use Data::Dumper;
BEGIN { use_ok('Tsk::Img::Info'); };
use Tsk::Img::Info;

my $o = Tsk::Img::Info->new();
#Dump($o);
$o->getPointer();
my $path = "testdata/testimage001.001";
$o->open($path,$TSK_IMG_TYPE_DETECT,0);
ok(defined($o),"Tsk::Img::Info object is defined");
#$o->perl_method("test");
#print Dumper $o;

