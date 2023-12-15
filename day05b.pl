#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

sub next {
  my ($self, $seed, $round) = @_;

  my $location = $seed;

  for my $map (@{ $self->{ convert }[$round] }) {
    if ($seed >= $map->[1] && $seed <= $map->[1] + $map->[2]) {
      return $map->[0] + ($seed - $map->[1]);
     }
   }

  return $location;
 }

sub plant {
  my ($self, $seed) = @_;

  for my $round (0 .. @{ $self->{ convert } } - 1) {
    $seed = $self->next( $seed, $round );
   }

  return $seed;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    convert => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );

  my $map = [];
  while (@lines) {
    my $line = shift( @lines );
    next unless $line;

    if ($line =~ /^seeds:\s+(.*?)\s*$/) {
      $self->{ seeds } = [ split( /\s+/, $1 ) ];
      #$self->{ seeds } = { split( /\s+/, $1 ) };
     }
    elsif ($line =~ /map:/) {
      push @{ $self->{ convert } }, $map if (@{ $map });
      $map = [];
     }
    else {
      push @{ $map }, [ split( /\s+/, $line ) ];
     }
   }
  push @{ $self->{ convert } }, $map if (@{ $map });

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input05.txt';

my $map = Map->new( $input_file );

my $location;
for my $seed (@{ $map->{ seeds } }) {
  my $loc = $map->plant( $seed );
  $location = $loc if (!$location || $loc < $location);
 }


say "The lowest location number is $location";

exit;
