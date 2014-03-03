use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
use Devel::Peek;
use Devel::Symdump;
BEGIN { use_ok('Tsk::Fs::Info'); };
use Tsk::Fs::Dir;


my $h_namespace = { map { ($_ => 1) } (Devel::Symdump->functions("Tsk::Fs::Dir")) };
#print Dumper $h_namespace;
ok($h_namespace->{"Tsk::Fs::Dir::new"} == 1, "::new method present");
ok($h_namespace->{"Tsk::Fs::Dir::open"} == 1, "::open method present");
ok($h_namespace->{"Tsk::Fs::Dir::getSize"} == 1, "::getSize method present");
ok($h_namespace->{"Tsk::Fs::Dir::getFile"} == 1, "::getFile method present");
ok($h_namespace->{"Tsk::Fs::Dir::DESTROY"} == 1, "::DESTROY method present");


