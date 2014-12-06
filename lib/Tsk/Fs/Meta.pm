package Tsk::Fs::Meta;
use 5.012005;
use strict;
use warnings;
use Tsk;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = @Tsk::EXPORT;

=head1 NAME

Tsk::Fs::Meta - File metadata structure

=head1 getSize()

Get file size (in bytes)

=head1 getType()

Get file type.

=head1 getFlags()

Get flags for this file for its allocation status etc.

=head1 getAddr()

Get address of the meta data structure for this file

=head1 getMTime()

Get last file content modification time (stored in number of seconds since Jan 1, 1970 UTC)

=head1 getMTimeNano()

Get nano-second resolution of modification time

=head1 getATime()

Get last file content accessed time (stored in number of seconds since Jan 1, 1970 UTC)

=head1 getATimeNano()

Get nano-second resolution of accessed time

=head1 getCTime()

Get last file / metadata status change time (stored in number of seconds since Jan 1, 1970 UTC)

=head1 getCTimeNano()

Get nano-second resolution of change time

=head1 getCrTime()

get created time (stored in number of seconds since Jan 1, 1970 UTC)

=head1 getCrTimeNano()

Get nano-second resolution of created time

=head1 getDTime()

Get linux deletion time

=head1 getDTimeNano()

Get nano-second resolution of deletion time

=head1 getBackUpTime()

Get HFS+ backup time

=head1 getBackUpTimeNano()

Get nano-second resolution of HFS+ backup time

=head1 BUGS

L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Tsk>

L<https://github.com/wsdookadr/Tsk-XS/issues>

=head1 AUTHOR

Stefan Petrea, C<< <stefan at garage-coding.com> >>

=cut

1;
