#!/usr/bin/perl

use strict;
use warnings;

our $LISTMAX = 8;

&Analysis( 'station.csv', 'station2.csv', ',' );

sub Analysis()
{
  my ( $file, $out, $split ) = ( @_ );
  my @list = &Load( $file, $split );

  my %st;

  foreach ( @list )
  {
    if ( exists( $st{ ${ $_ }{ 'name' } } ) )
    {
      ++$st{ ${ $_ }{ 'name' } }->{ 'c' };
      $st{ ${ $_ }{ 'name' } }->{ 'x' } += ${ $_ }{ 'x' };
      $st{ ${ $_ }{ 'name' } }->{ 'y' } += ${ $_ }{ 'y' };
    } else
    {
      $st{ ${ $_ }{ 'name' } } = { 'c' => 1, 'x' => ${ $_ }{ 'x' }, 'y' => ${ $_ }{ 'y' } };
    }
  }

  open( FILE, "> $out" );
  foreach ( keys( %st ) )
  {
    $st{ $_ }->{ 'x' } /= $st{ $_ }->{ 'c' };
    $st{ $_ }->{ 'y' } /= $st{ $_ }->{ 'c' };
    printf FILE join( $split, sprintf( "%.5f", $st{ $_ }->{ 'y' } ), sprintf( "%.5f", $st{ $_ }->{ 'x' } ), $_ ) . ",\n";
  }
  close( FILE );
}

sub Load()
{
  my ( $file, $split ) = ( @_ );

  my @list = ();

  unless ( open( FILE, $file ) ) { return @list; }

  my $id = 0;
  while( <FILE> )
  {
    my $line = $_;
    if ( $line =~ /$split/ )
    {
      chomp( $line );
      my( $y, $x, $name ) = split( /$split/, $line );
      push( @list, { 'id' => $id++, 'x' => $x, 'y' => $y, 'name' => $name } );
    }
  }
  close( FILE );

  return @list;
}
