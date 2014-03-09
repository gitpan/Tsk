package Tsk::Exp;
use 5.012005;
use strict;
use warnings;
use lib "./lib";
use Tsk;
require Exporter;

our @ISA = qw(Exporter);
our $VERSION = '0.03';

sub new {
    my ($class) = @_;
    my $obj = {};
    return bless $obj,$class;
};


1;
