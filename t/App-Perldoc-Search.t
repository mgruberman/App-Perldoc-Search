#!perl
use Test::More tests => 4;
use strict;

search_ok( 'run', qr/^IPC::Run/m, 'Found IPC::Run' );

# echo -n 'Try searching for something that probably doesn'\''t exist' | md5
# dc098fbcf3f9bf8ba7898addba4591cb
search_ok( 'dc098fbcf3f9bf8ba7898addba4591cb', qr/^$/, "Couldn't find dc098fbcf3f9bf8ba7898addba4591cb" );


sub search_ok {
    my ( $phrase, $expected, $test_name ) = @_;

    my $stdout = `$^X -Mblib bin/perldoc-search $phrase`;

    is( $?, 0, "Didn't die" );
    like( $stdout, $expected, $test_name );

    return;
}
