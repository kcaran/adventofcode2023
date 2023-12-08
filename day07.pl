#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

# Rank cards in hex
my %rank = (
	A => 'F',
	K => 'E',
	Q => 'D',
	J => 'C',
	T => 'B',
	9 => 'A',
	8 => 9,
	7 => 8,
	6 => 7,
	5 => 6,
	4 => 5,
	3 => 4,
	2 => 3,
	1 => 2,
);

{ package Card;

sub has_of_kind {
  my ($self, $num) = @_;

  my @ranks = ();
  for my $r (keys %{ $self->{ ranks } }) {
    push @ranks, $r if ($self->{ ranks }{ $r } == $num);
   }

  return @ranks;
 }

#
# Note: sorting is based on original hand, *not* poker rankings!
#
sub hand {
  my ($self) = @_;

  $self->{ strength } = 1;
  $self->{ trips } = 0;
  $self->{ pairs } = 0;

  for my $card (sort { $self->{ ranks }{ $b } <=> $self->{ ranks }{ $a } || hex( $rank{ $b } ) <=> hex( $rank{ $a } ) } (keys %{ $self->{ ranks } })) {
    my $num = $self->{ ranks }{ $card };
    $self->{ strength } = 7 if ($num == 5);
    $self->{ strength } = 6 if ($num == 4);
    $self->{ trips } = 1 if ($num == 3);
    $self->{ pairs }++ if ($num == 2);
   }
  $self->{ strength } = 2 if ($self->{ pairs } == 1);
  $self->{ strength } = 3 if ($self->{ pairs } == 2);
  $self->{ strength } = 4 if ($self->{ trips });
  $self->{ strength } = 5 if ($self->{ trips } && $self->{ pairs });

  return;
 }

sub wild {
  my ($self) = @_;

  $self->{ strength } = 1;
  $self->{ trips } = 0;
  $self->{ pairs } = 0;
  my $has_wilds = $self->{ ranks }{ J } || 0;

  # Update rank of wild jacks
  $self->{ cards } =~ s/C/1/g;

  # Account for 5(!) wild cards
  if ($has_wilds == 5) {
    $self->{ strength } = 7;
    return;
   }

  delete $self->{ ranks }{ J };

  for my $card (sort { $self->{ ranks }{ $b } <=> $self->{ ranks }{ $a } || hex( $rank{ $b } ) <=> hex( $rank{ $a } ) } (keys %{ $self->{ ranks } })) {
    if ($has_wilds) {
      $self->{ ranks }{ $card } += $has_wilds;
      $has_wilds = 0;
     }
    my $num = $self->{ ranks }{ $card };

    $self->{ strength } = 7 if ($num == 5);
    $self->{ strength } = 6 if ($num == 4);
    $self->{ trips } = 1 if ($num == 3);
    $self->{ pairs }++ if ($num == 2);
   }
  $self->{ strength } = 2 if ($self->{ pairs } == 1);
  $self->{ strength } = 3 if ($self->{ pairs } == 2);
  $self->{ strength } = 4 if ($self->{ trips });
  $self->{ strength } = 5 if ($self->{ trips } && $self->{ pairs });

  return;
 }

sub new {
  my ($class, $input) = @_;

  my ($cards, $bid) = split( /\s+/, $input );
  my $self = {
    bid => $bid,
  };

  my @cards = split( '', $cards );
  $self->{ cards } = join( '', map { $rank{ $_ } } @cards );
  for my $c (@cards) {
    $self->{ ranks }{ $c }++;
   }
  bless $self, $class;

  $self->hand();

  return $self;
 }
}

sub count_score {
  my (@cards) = @_;

  @cards = sort { $a->{ strength } <=> $b->{ strength } || hex( $a->{ cards } ) <=> hex( $b->{ cards } ) } @cards;

  my $score = 0;
  for my $i (1 .. @cards) {
say "$i $cards[$i - 1]->{ bid } $cards[$i - 1]{ cards }";
    $score += $i * $cards[$i - 1]->{ bid };
   }
  return $score;
 }

my $input_file = $ARGV[0] || 'input07.txt';

my @cards;
for my $line (Path::Tiny::path( $input_file )->lines( { chomp => 1 } )) {
  push @cards, Card->new( $line );
 }

my $score = 0;
$score = count_score( @cards );
say "The total winnings in part a is $score";

# Update strengths based on wild cards
# Reading comprehension FTW - Jacks are now weakest!
for my $card (@cards) {
  $card->wild();
 }

$score = count_score( @cards );
say "The total winnings with wild cards is $score";


exit;
