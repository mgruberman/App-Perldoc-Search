#!perl
use Test::More tests => 2;
use strict;
use warnings;

use File::Spec::Functions qw( catfile );
use File::Basename qw( dirname );

my $search = catfile( dirname( $0 ), '../scripts/perldoc-search');

# Try searching for Module::Build
my $mbuild = `$^X -Mblib $search Module::Build`;
like( $mbuild, qr/^Module::Build/m, 'Found Module::Build' );

# echo -n 'Try searching for something that probably doesn'\''t exist' | md5
# dc098fbcf3f9bf8ba7898addba4591cb
my $md5 = `$^X -Mblib dc098fbcf3f9bf8ba7898addba4591cb`;
is( $md5, '', q(Didn't find my unlikely md5sum) );