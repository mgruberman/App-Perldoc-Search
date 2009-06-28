#!perl
use Test::More tests => 4;
use strict;
use warnings;

use File::Spec::Functions qw( catfile );
use File::Basename qw( dirname );
sub search_ok;

my $search = catfile( dirname( $0 ), '../script/perldoc-search');

search_ok 'add_build_element', qr/^Module::Build/m, 'Found Module::Build';

# echo -n 'Try searching for something that probably doesn'\''t exist' | md5
# dc098fbcf3f9bf8ba7898addba4591cb
search_ok 'dc098fbcf3f9bf8ba7898addba4591cb', qr/^$/, "Couldn't find dc098fbcf3f9bf8ba7898addba4591cb";


sub search_ok {
  my ( $phrase, $expected, $test_name ) = @_;
  my $cmd = "$^X -Mblib $search $phrase";
  my $result = `$cmd`;
  is( $?, 0, "$test_name: $cmd" );
  like( $result, $expected, $test_name );
}
