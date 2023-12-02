#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Game;

sub test_valid {
  my ($self) = @_;

  my $valid = 1;
  my $max = { red => 12, green => 13, blue => 14 };
  for my $r (@{ $self->{ rounds } }) {
    for my $c (keys %{ $max }) {
      next unless ($r->{ $c });
      $valid = 0 if ($r->{ $c } > $max->{ $c });
      last if (!$valid);
     }
    last if (!$valid);
   }

  return $valid;
 }

sub power {
  my ($self) = @_;

  my $power = 1;
  for my $c (keys %{ $self->{ min_cubes } }) {
    $power *= $self->{ min_cubes }{ $c };
   }

  return $power;
 }

sub new {
  my ($class, $line) = @_;

  my $self = {
    rounds => [],
    min_cubes => { red => 0, green => 0, blue => 0 },
  };

  $line =~ s/^Game\s+(\d+):\s+//;
  $self->{ id } = $1;
  for my $r (split( /;\s*/, $line )) {
    my $round = {};
    for my $cubes (split( /,\s*/, $r )) {
      my ($count, $color) = ($cubes =~ /\s*(\d+)\s+(\S+)/);
      $round->{ $color } = $count;
      if ($self->{ min_cubes }{ $color } < $count) {
        $self->{ min_cubes }{ $color } = $count;
       }
     }
    push @{ $self->{ rounds } }, $round;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input02.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );
my @games;
for my $l (@lines) {
  push @games, Game->new( $l );
 }

my $valid_sum = 0;
my $power_sum = 0;
for my $g (@games) {
  $valid_sum += $g->{ id } if ($g->test_valid());
  $power_sum += $g->power();
 }

say "The sum of valid games is $valid_sum";
say "The power sum of all games is $power_sum";

exit;
