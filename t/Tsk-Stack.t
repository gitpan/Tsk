use strict;
use warnings;
use Devel::Peek;
use Test::More qw/no_plan/;
use Data::Dumper;
BEGIN { use_ok('Tsk::Stack'); };
use Tsk::Stack;

my $o = Tsk::Stack->new();
my $a = 1;
my $b = 1;
# Throw in the stack Fibonacci numbers from F_3 to F_12 in the Stack
for(1..10) {
    ($a,$b) = ($b,($a+$b));
    $o->push($b);
};

# Check if stack contains some of the numbers, and check for other
# numbers which should not be in the stack
my $found_34 = $o->find(34);
my $found_35 = $o->find(35);
my $found_36 = $o->find(36);
my $found_55 = $o->find(55);
ok( $found_34,"Stack contains 34");
ok(!$found_35,"Stack does not contain 35");
ok(!$found_36,"Stack does not contain 36");
ok( $found_55,"Stack contains 55");
ok($o->top()==10,"Stack contains 10 elements");
ok($o->length()==64,"Stack has 64 allocated spots at the moment");
for(1..64) {
    ($a,$b) = ($b,($a+$b));
    $o->push($b);
};
print "Adding 64 more elements to the stack\n";
ok($o->top()==74,"Stack contains 74 elements");
ok($o->length()==128,"Stack has 128 allocated spots at the moment");


