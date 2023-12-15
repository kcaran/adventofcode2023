#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Dish;

sub hash {
  my ($string) = @_;

  my $hash = 0;

  for my $idx (0 .. length( $string ) - 1) {
    my $char = substr( $string, $idx, 1 );
    $hash += ord( $char );
    $hash *= 17;
    $hash = $hash % 256;
   }

  return $hash;
 }

sub power {
  my ($self) = @_;

  my $power = 0;

  for my $num (1 .. 256) {
    my $box = $self->{ boxes }[ $num - 1 ];
    my $slot = 1;
    for my $lens (sort { $box->{ lenses }{ $a }{ count } <=> $box->{ lenses }{ $b }{ count } } keys %{ $box->{ lenses } }) {
      $power += $num * $slot * $box->{ lenses }{ $lens }{ focal };
      $slot++;
     }
   }

  return $power;
 }

sub inst {
  my ($self, $inst) = @_;

  my ($label, $op, $focal) = ($inst =~ /^(\w+)([\-=])(\d*)$/);
  my $box = $self->{ boxes }[ hash( $label ) ];

  if ($op eq '-') {
    delete $box->{ lenses }{ $label };
   }
  elsif ($op eq '=') {
    if ($box->{ lenses }{ $label }) {
      $box->{ lenses }{ $label }{ focal } = $focal;
     }
    else {
      $box->{ count }++;
      $box->{ lenses }{ $label }{ focal } = $focal;
      $box->{ lenses }{ $label }{ count } = $box->{ count };
     }
   }
  else {
    die "Illegal instruction $inst";
   }

  return $self;
 }

sub new {
  my ($class) = @_;

  my $self = {
    boxes => [],
  };

  for my $i (0 .. 255) {
    $self->{ boxes }[$i] = { count => 0, lenses => {} };
   }

  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input15.txt';

my $sequence = Path::Tiny::path( $input_file )->slurp_utf8();
$sequence =~ s/\n$//;

my $dish = Dish->new();
for my $inst (split( ',', $sequence )) {
  $dish->inst( $inst );
 }

my $power = $dish->power();
say "The total power is $power";

exit;
