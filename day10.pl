#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

my %move_cmd = (
	'|' => \&move_pipe,
	'-' => \&move_dash,
	'L' => \&move_l,
	'J' => \&move_j,
	'7' => \&move_7,
	'F' => \&move_f,
 );

sub move_dash {
  my ($pos, $prev) = @_;

  if ($prev->[1] < $pos->[1]) {
    $pos->[1]++;
   }
  else {
    $pos->[1]--;
   }

  return $pos;
 }

sub move_pipe {
  my ($pos, $prev) = @_;

  if ($prev->[0] < $pos->[0]) {
    $pos->[0]++;
   }
  else {
    $pos->[0]--;
   }

  return $pos;
 }

sub move_l {
  my ($pos, $prev) = @_;

  if ($prev->[0] < $pos->[0]) {
    $pos->[1]++;
   }
  else {
    $pos->[0]--;
   }

  return $pos;
 }

sub move_j {
  my ($pos, $prev) = @_;

  if ($prev->[0] < $pos->[0]) {
    $pos->[1]--;
   }
  else {
    $pos->[0]--;
   }

  return $pos;
 }

sub move_7 {
  my ($pos, $prev) = @_;

  if ($prev->[0] > $pos->[0]) {
    $pos->[1]--;
   }
  else {
    $pos->[0]++;
   }

  return $pos;
 }

sub move_f {
  my ($pos, $prev) = @_;

  if ($prev->[0] > $pos->[0]) {
    $pos->[1]++;
   }
  else {
    $pos->[0]++;
   }

  return $pos;
 }

sub print {
  my ($self) = @_;
  my $map = '';
  for my $row (0 .. $self->{ max_row }) {
    $map .= join('', @{ $self->{ map }[$row] }) . "\n";
   }
  print $map;
 }

sub start {
  my ($self) = @_;
  my ($row, $col) = @{ $self->{ start } };
  my @next;
  if ($row > 0 && $self->{ map }[$row - 1][$col] ne '.' && $self->{ map }[$row - 1][$col] =~ /[F7\|]/) {
    push @next, [ $row - 1, $col ];
   }
  if ($col > 0 && $self->{ map }[$row][$col - 1] ne '.' && $self->{ map }[$row][$col - 1] =~ /[FL\-]/) {
    push @next, [ $row, $col - 1 ];
   }
  if ($row < $self->{ max_row } && $self->{ map }[$row + 1][$col] ne '.' && $self->{ map }[$row + 1][$col] =~ /[LJ\|]/) {
    push @next, [ $row + 1, $col ];
   }
  if ($col < $self->{ max_col } && $self->{ map }[$row][$col + 1] ne '.' && $self->{ map }[$row][$col + 1] =~ /[J7\-]/) {
    push @next, [ $row, $col + 1 ];
   }
  die "Not the right amount of starts" if (@next != 2);
  $self->{ pos0 } = $next[0];
  $self->{ pos1 } = $next[1];
  $self->{ prev0 } = [ $row, $col ];
  $self->{ prev1 } = [ $row, $col ];
  $self->{ visited }{ "$row,$col" } = 1;
  $self->{ visited }{ "$next[0]->[0],$next[0]->[1]" } = 1;
  $self->{ visited }{ "$next[1]->[0],$next[1]->[1]" } = 1;
  $self->{ moves }++;

  return;
 }

sub next_flows {
  my ($self, $row, $col) = @_;

  my $m = $self->{ map };
  my @flows;
  if (($m->[$row - 1][$col] eq '.')
   || ($m->[$row - 1][$col] eq '7' && $m->[$row - 1][$col + 1] eq 'F')
   || ($m->[$row - 1][$col] eq 'F' && $m->[$row - 1][$col - 1 ] eq '7')
   || ($m->[$row - 1][$col] eq '|' && $m->[$row - 1][$col - 1 ] eq '|')
   || ($m->[$row - 1][$col] eq '|' && $m->[$row - 1][$col + 1 ] eq '|')
      ) {
    push @flows, [ $row - 1, $col ];
   }
  if (($m->[$row + 1][$col] eq '.')
   || ($m->[$row + 1][$col] eq '7' && $m->[$row - 1][$col + 1] eq 'F')
   || ($m->[$row + 1][$col] eq 'F' && $m->[$row - 1][$col - 1 ] eq '7')) {
    push @flows, [ $row + 1, $col ];
   }
 }

sub is_enclosed {
  my ($self, $row, $col) = @_;

  return 0 if ($row == 0 || $col == 0 || $row == $self->{ max_row } || $col == $self->{ max_col });
  return 0 if ($self->{ map }[$row][$col] ne '.');

  return 1;
 }

sub enclosed {
  my ($self) = @_;

  my $enclosed = 0;
  for my $row (0 .. $self->{ max_row }) {
    for my $col (0 .. $self->{ max_col }) {
      $enclosed++ if ($self->is_enclosed( $row, $col ));
     }
   }

  return $enclosed;
 }

sub move {
  my ($self) = @_;

  if ($self->{ moves } == 0) {
    return $self->start();
   }

  my $pos = [ @{ $self->{ pos0 } } ];
  my $move = $self->{ map }[ $pos->[0] ][ $pos->[1] ];
  &{ $move_cmd{ $move } }( $self->{ pos0 }, $self->{ prev0 } );
  $self->{ prev0 } = $pos;
  $self->{ visited }{ "$self->{ pos0 }[0],$self->{ pos0 }[1]" } = 1;

  $pos = [ @{ $self->{ pos1 } } ];
  $move = $self->{ map }[ $pos->[0] ][ $pos->[1] ];
  &{ $move_cmd{ $move } }( $self->{ pos1 }, $self->{ prev1 } );
  $self->{ prev1 } = $pos;
  $self->{ visited }{ "$self->{ pos1 }[0],$self->{ pos1 }[1]" } = 1;

  $self->{ moves }++;

  return $self->{ pos0 }[0] == $self->{ pos1 }[0]
				&& $self->{ pos0 }[1] == $self->{ pos1 }[1];
 }

sub clear {
  my ($self) = @_;

  for my $row (0 .. $self->{ max_row }) {
    for my $col (0 .. $self->{ max_col }) {
      $self->{ map }[$row][$col] = '.' unless ($self->{ visited }{ "$row,$col" });
     }
   }
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
	pos0 => [],
    prev0 => [],
	pos1 => [],
    prev1 => [],
    visited => {},
    moves => 0,
  };
  bless $self, $class;

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $row (0 .. @lines - 1) {
    if ((my $start = index( $lines[$row], 'S' )) >= 0) {
      $self->{ start } = [$row, $start];
     }
    $self->{ map }[$row] = [ split( '', $lines[$row] ) ];
   }
  $self->{ pos0 } = [ @{ $self->{ start } } ];
  $self->{ pos1 } = [ @{ $self->{ start } } ];
  $self->{ max_row } = @lines - 1;
  $self->{ max_col } = length( $lines[0] ) - 1;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input10.txt';

my $map = Map->new( $input_file );
while (!$map->move()) {}
$map->clear();

say "The farthest number of moves is $map->{ moves }";
say "The number of enclosed tiles is ", $map->enclosed();

exit;

