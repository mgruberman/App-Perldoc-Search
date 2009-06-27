package App::Perldoc::Search;

=head1 NAME

App::Perldoc::Search - implementation for perldoc-search

=head1 SYNOPSIS

  App::Perldoc::Search->run( 'thing_to_search_for' )

  App::Perldoc::Search->run( '--help' )

  App::Perldoc::Search->run( '-G' => '\.pm', 'thing_to_search_for' )

=head1 DESCRIPTION

Implements the guts of the L<perldoc-search> script.

=head1 METHODS

=cut



use 5.006_000;
use strict;
use warnings;
require File::Find;
require Getopt::Long;
require Pod::Usage;
require IO::File;
require App::Perldoc::Search::_Parser;

our $VERSION = '0.03';



=head2 App::Perldoc::Search-E<lt>run( OPTIONS )

The main run loop. Handles all getopt parsing. See L<perldoc-script> for the options.

=cut

sub run {
    my ( $class, @argv ) = @_;

    # Read optional options.
    local *ARGV = \ @argv;
    my $file_match_rx = qr/\.p(?:od|mc?)$/;
    Getopt::Long::GetOptions(
        'G=s'   => sub { $file_match_rx = qr/$_[1]/ },
        'help'  => \ &_help )
      or _error_help();

    # Validate pattern.
    if ( ! @argv ) {
        _error_help( -exitval => 1 );
    }
    my $pattern = shift @ARGV;

    # Get search path
    my @search_path = @ARGV ? @ARGV : @INC;

    # Search all files.
    File::Find::find({
        follow_fast => 1,
        no_chdir => 1,
        wanted => sub {
            return if
                ! /$file_match_rx/
                || ! -f;

            # Open the documentation.
            my $fh = IO::File->new;
            $fh->open( $_ )
                or return; # TODO

            # Read the documentation.
            my $text;
            IO::Handle->input_record_separator( undef );
            $text = $fh->getline;

            # Try a fast match to avoid parsing.
            return if $text !~ $pattern;

            # Prepare for searching.
            my $searcher = App::Perldoc::Search::_Parser->new;
            $searcher->{pattern} = $pattern;

            # Search the document.
            IO::Handle->input_record_separator( "\n" );
            $fh->seek( 0, 0 );
            $searcher->parse_from_filehandle( $fh );
            return if ! $searcher->{matched};

            # Extract document name.
            my $name = $searcher->{name} || $_;

            # Report.
            print "$name\n"
                or warn "Can't write: $!";
        }},
        @search_path );

    return;
}



=head2 _help()

Prints the manual and exits

=cut

sub _help {
    Pod::Usage::pod2usage(
        -verbose => 2,
        -exitval => 0,
        -output  => \*STDOUT );
    # NOT REACHED
}

=head2 _error_help()

Prints the manual to STDERR and exits with 2.

=cut

sub _error_help {
    Pod::Usage::pod2usage(
        -verbose => 2,
        -exitval => 2,
        -output  => \*STDERR,
        @_ );
    # NOT REACHED
}




=head1 BUGS

Please report any bugs or feature requests to C<bug-App-Perldoc-Search
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Perldoc-Search>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.



=head1 SUPPORT

You can find documentation for this script and module with the --help
parameter and with perldoc.

  perldoc-search --help
  perldoc App::Perldoc::Search

You can also look for information at:

=over

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Perldoc-Search>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Perldoc-Search>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Perldoc-Search>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Perldoc-Search/>

=back



=head1 COPYRIGHT & LICENSE

Copyright 2009 Josh ben Jore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.



=head1 SOURCE AVAILABILITY

This source is in Github: L<git://github.com/jbenjore/app-perldoc-search.git>



=head1 AUTHOR

Josh ben Jore

q(Soviet Jesus's gift at Christmas of a blow-up doll to Debbie would always turn to be the most enigmatic);
