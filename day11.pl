#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

sub print {
  my ($self) = @_;
  my $map = '';
  for my $row (0 .. @{ $self->{ map } } - 1) {
    $map .= join('', @{ $self->{ map }[$row] }) . "\n";
   }
  print $map;
 }

sub paths {
  my ($self, $empty) = @_;

  my $total = 0;
  for my $i (0 .. @{ $self->{ galaxies } } - 2) {
    for my $j ($i + 1 .. @{ $self->{ galaxies } } - 1) {
      my $g1 = $self->{ galaxies }[$i];
      my $g2 = $self->{ galaxies }[$j];
      my $dist = 0;
      my $row  = $g1->[0];
      while ($row != $g2->[0]) {
        $dist++;
        $dist += $empty if ($self->{ empty_rows }{ $row });
        $row += ($g1->[0] < $g2->[0]) ? 1 : -1;
       }

      my $col = $g1->[1];
      while ($col != $g2->[1]) {
        $dist++;
        $dist += $empty if ($self->{ empty_cols }{ $col });
        $col += ($g1->[1] < $g2->[1]) ? 1 : -1;
       }

      $total += $dist;
     }
   }

  return $total;
 }

#
# What is the best way to copy these rows? Copy the reference?
#
sub empty_cols {
  my ($self) = @_;

  my @empty_cols;
  my $col = 0;
  while ($col < @{ $self->{ map }[0] }) {
    my $row = 0;
    my $empty = 1;
    while ($empty && $row < @{ $self->{ map } }) {
      $empty = $self->{ map }[$row][$col] eq '.';
      $row++;
     }
    $self->{ empty_cols }{ $col } = 1 if ($empty);
    $col++;
   }

  return;
 }

#
# What is the best way to copy these rows? Copy the reference?
#
sub empty_rows {
  my ($self) = @_;

  for my $row (0 .. @{ $self->{ map } } - 1) {
    my $line = join( '', @{ $self->{ map }[$row] } );
    $self->{ empty_rows }{ $row } = 1 if ($line !~ /#/);
   }

  return;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
	map => [],
    galaxies => [],
  };
  bless $self, $class;

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $row (0 .. @lines - 1) {
    $self->{ map }[$row] = [ split( '', $lines[$row] ) ];
   }
  $self->empty_rows();
  $self->empty_cols();

  for my $row (0 .. @{ $self->{ map } } - 1) {
    my $line = $self->{ map }[ $row ];
    for my $col (0 .. @{ $line } - 1) {
      push @{ $self->{ galaxies } }, [ $row, $col ] if ($line->[$col] eq '#');
     }
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input11.txt';

my $map = Map->new( $input_file );

say "The part a total distance between galaxy pairs is ", $map->paths( 1 );

say "The part b total distance between galaxy pairs is ", $map->paths( 1000000 - 1 );
exit;

