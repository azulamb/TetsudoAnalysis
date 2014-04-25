#!/usr/bin/perl

use strict;
use warnings;

#http://w3land.mlit.go.jp/ksj/jpgis/datalist/KsjTmplt-N02-v1_1.html
&Analysis( 'N02-08.xml', 'station.csv', ',' );

sub Analysis()
{
  my ( $file, $output, $split ) = ( @_ );

  my %st;
  my %cv;

  if ( open( FILE, $file ) )
  {
    my $key = '';
    my $mode = '';
    my $line;
    while ( <FILE> )
    {
      $line = $_;
      if ( $line =~ /\t\<jps\:GM\_Point id\=\"(n\_[0-9]+)\"\>/ )
      {
        $key = $1;
        $mode = 'GMP';
      } elsif ( $line =~ /\t\<ksj\:EB03 / )
      {
        $mode = 'EB';
      } elsif ( $line =~ /\t\<jps\:GM\_Curve id\=\"(c\_[0-9]+)">/ )
      {
        $mode = $1;
        $key = $mode;
      } elsif ( $line =~ /\t\<GM\_PointRef\.point idref\=\"(n\_[0-9]+)\"\/>/ )
      {
        push( @{ $cv{ $key } }, $1 );
      }

      if ( $mode eq 'GMP' )
      {
        if ( $line =~ /\<DirectPosition\.coordinate\>([0-9\.]+) ([0-9\.]+)\<\/DirectPosition\.coordinate\>/ )
        {
          ( $st{ $key }{ 'y' }, $st{ $key }{ 'x' } ) = ( $1, $2 );
        }
      } elsif ( $mode eq 'EB' )
      {
        if ( $line =~ /\<ksj\:LOC idref\=\"(c\_[0-9]+)\"\/\>/ )
        {
          $key = $1;
        } elsif ( $line =~ /\<ksj\:STN\>(.+)\<\/ksj\:STN\>/ )
        {
          my $name = $1;
          foreach ( @{ $cv{ $key } } )
          {
            $st{ $_ }{ 'name' } = $name;
          }
        } elsif ( $line =~ /\<ksj\:LIN\>(.+)\<\/ksj\:LIN\>/ )
        {
          my $name = $1;
          foreach ( @{ $cv{ $key } } )
          {
            $st{ $_ }{ 'line' } = $name;
          }
        }
      }

      if ( $line =~ /\t\<\/jps\:GM\_Point\>/ )
      {
        $mode = '';
      }elsif ( $line =~ /\t\<\/ksj\:EB03\>/)
      {
        $mode = '';
      }
    }
  }

  open( FILE, "> $output" );
  foreach( keys( %st ) )
  {
    if ( exists( $st{ $_ }{ 'name' } ) )
    {
      print FILE join( $split, sprintf( "%.5f", $st{ $_ }{ 'y' } ), sprintf( "%.5f", $st{ $_ }{ 'x' }) , $st{ $_ }{ 'name' }, $st{ $_ }{ 'line' } ) . "\n";
    }
  }
  close( FILE );

}
