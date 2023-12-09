#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

sub go {
  my ($self) = @_;

  my $pos = 'AAA';
  my $moves = 0;
  my @dirs = @{ $self->{ dir } };
  while ($pos ne 'ZZZ') {
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
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  my $dir = shift @lines;
  $self->{ dir } = [ split( '', $dir ) ];

  for my $line (@lines) {
    if ($line =~ /^(\w+)\s=\s\((\w+),\s(\w+)\)/) {
      $self->{ map }{ $1 } = [ $2, $3 ];
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input08.txt';

my $map = Map->new( $input_file );

my $moves = $map->go();

say "The number of moves is $moves";

exit;
