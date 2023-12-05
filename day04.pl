#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Card;

sub matches {
  my ($self) = @_;

  my $count = 0;
  my %winners = %{ $self->{ winners } };
  for my $num (@{ $self->{ numbers } }) {
    if ($winners{ $num }) {
      $count++;
      $winners{ $num } = 0;
     }
   }

  return $count;
 }

sub score {
  my ($self) = @_;

  my $count = $self->matches();
  return ($count > 0) ? (2 ** ($count - 1)) : 0;
 }

sub new {
  my ($class, $input) = @_;

  my $self = {
  };

  my ($id, $winners, $numbers) = $input =~ /^Card\s+(\d+):\s+(\d[^|]+\d)\s+\|\s+(.*)$/;
  $self->{ id } = $id;
  $self->{ winners } = { map { $_ => 1 } split( /\s+/, $winners ) };
  $self->{ numbers } = [ split( /\s+/, $numbers ) ];

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input04.txt';
my @cards;
for my $card_input (path( $input_file )->lines( { chomp => 1 } )) {
  push @cards, [ Card->new( $card_input ), 1 ];
 }

# Part a
my $score = 0;
for my $card (@cards) {
  my $card_score = $card->[0]->score();
  $score += $card_score;
 }

say "The total score for part a is $score";

# Part b
for my $i (0 .. @cards - 1) {
  my $matches = $cards[$i]->[0]->matches();
  my $num_cards = $cards[$i]->[1];

  # Add to total for additional cards
  for my $n (1 .. $matches) {
    $cards[$i + $n]->[1] += $num_cards;
   }
 }

$score = 0;
for my $card (@cards) {
  $score += $card->[1];
 }

say "The total score for part b is $score";


exit;
