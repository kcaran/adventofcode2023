#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Math::Utils qw( lcm );
use Path::Tiny;

{ package Map;

sub go {
  my ($self, $start) = @_;

  my $pos = $start;
  my $moves = 0;
  my @dirs = @{ $self->{ dir } };
  while (substr( $pos, 2, 1 ) ne 'Z') {
    my $next = (shift @dirs eq 'R') ? 1 : 0;
    $pos = $self->{ map }{ $pos }[$next];
    @dirs = @{ $self->{ dir } } unless (@dirs);
    $moves++;
   }

  return $moves;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    starts => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  my $dir = shift @lines;
  $self->{ dir } = [ split( '', $dir ) ];

  for my $line (@lines) {
    if ($line =~ /^(\w+)\s=\s\((\w+),\s(\w+)\)/) {
      $self->{ map }{ $1 } = [ $2, $3 ];
      push @{ $self->{ starts } }, $1 if (substr( $1, 2, 1 ) eq 'A');
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input08.txt';

my $map = Map->new( $input_file );

# Find the least common denominator for all the possible paths
my @moves;
for my $path (@{ $map->{ starts } }) {
   push @moves, $map->go( $path );
  }

say "The number of moves is ", lcm( @moves );

exit;
