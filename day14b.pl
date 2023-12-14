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
  return $map;
 }

sub cycle {
  my ($self) = @_;

  # Perform the cycle
  $self->rotate(0);
  $self->shift();		# North
  $self->rotate(1);
  $self->shift();		# West
  $self->rotate(1);
  $self->shift();		# South
  $self->rotate(1);
  $self->shift();		# East
  $self->rotate(1);
  $self->rotate(1);

  return $self;
 }

sub load {
  my ($self, $right) = @_;

  my $total = 0;
  for my $row (0 .. $self->{ max } - 1) {
    for my $col (0 .. $self->{ max } - 1) {
      my $score = $self->{ max } - $row;
      $total += $score if ($self->{ map }[$row][$col] eq 'O');
     }
   }

  return $total;
 }

sub shift {
  my ($self) = @_;
  for my $row (0 .. $self->{ max } - 1) {
    my $col = $self->{ max } - 1;
    while ($col > 0) {
      if (($self->{ map }[$row][$col] eq 'O')
       && ($self->{ map }[$row][$col-1] eq '.')) {
         $self->{ map }[$row][$col] =  '.';
         $self->{ map }[$row][$col-1] = 'O';
         $col = $self->{ max };
        }
       $col--;
      }
    }

  return $self;
 }

sub rotate {
  my ($self, $right) = @_;

  my $new = [];
  for my $row (0 .. $self->{ max } - 1) {
    for my $col (0 .. $self->{ max } - 1) {
      if ($right) {
        $new->[$row][$col] = $self->{ map }[$self->{ max } - $col - 1][$row];
       }
      else {
        $new->[$row][$col] = $self->{ map }[$col][$self->{ max } - $row - 1];
       }
     }
   }

  $self->{ map } = $new;

  return $self;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
	map => [],
  };
  bless $self, $class;

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $row (0 .. @lines - 1) {
    $self->{ map }[$row] = [ split( '', $lines[$row] ) ];
   }
  $self->{ max } = scalar( @{ $self->{ map } } );

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input14.txt';

my $map = Map->new( $input_file );

my %loads;
my $cycle = 0;
$loads{ $map->print() } = $cycle++;
my $loop = 0;

while (!$loop) {
  $map->cycle();
  my $print = $map->print();
  if ($loads{ $print }) {
    $loop = $cycle - $loads{ $print };
   }
  else {
    $loads{ $print } = $cycle++;
   }
 }

my $extras = (1_000_000_000 - $cycle) % $loop;
for my $i (1 .. $extras) {
  $map->cycle();
 }

say "The total sum of the load is ", $map->load();

exit;

