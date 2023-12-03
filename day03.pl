#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Grid;

sub value {
  my ($self, $row, $start, $end) = @_;

  return '' if ($row < 0);
  return '' if ($row >= @{ $self->{ rows } });
  return '' if ($start < 0 && $end < 0);
  return '' if ($start >= $self->{ cols } && $end >= $self->{ cols });

  $start = 0 if ($start < 0);
  $end = $self->{ cols } - 1 if ($end >= $self->{ cols });

  return (substr( $self->{ rows }[$row], $start, $end - $start + 1 ), $start);
 }

sub check_gear {
  my ($self, $row, $start, $end) = @_;

  my ($substr, $pos) = $self->value( $row, $start, $end );
  if ($substr =~ /([^.0-9])/) {
    return ($1, $row, $pos + $-[1]);
   }

  return;
 }

#
# Is there a better way to return the output of a function only if
# it is defined?
#
sub symbol {
  my ($self, $row, $start, $end) = @_;

  my @symbol;

  @symbol = $self->check_gear( $row - 1, $start - 1, $end + 1 );
  return @symbol if (@symbol);

  @symbol = $self->check_gear( $row, $start - 1, $start - 1 );
  return @symbol if (@symbol);

  @symbol = $self->check_gear( $row, $end + 1, $end + 1 );
  return @symbol if (@symbol);

  @symbol = $self->check_gear( $row + 1, $start - 1, $end + 1 );
  return @symbol if (@symbol);

  return;
 }

sub gears {
  my ($self) = @_;

  # Find the numbers next to gears
  for my $r (0 .. @{ $self->{ rows } } - 1) {
    while ($self->{ rows }[$r] =~ /(\d+)/g) {
      # @- is the start of the match, @+ is the next character after
      my $num = $1;
      my $start = $-[1];
      my $end = $+[1] - 1;
      if (my @s = $self->symbol( $r, $start, $end )) {
        if ($s[0] eq '*') {
          say "$num @s ($r, $start, $end)";
          push @{ $self->{ gears }{ "$s[1],$s[2]" } }, $num;
         }
       }
     }
   }

  my $sum = 0;
  for my $gear (keys %{ $self->{ gears } }) {
    my @nums = @{ $self->{ gears }{ $gear } };
    next unless (@nums > 1);
    $sum += $nums[0] * $nums[1];
   }

  return $sum;
 }

sub parts {
  my ($self) = @_;

  my $sum = 0;
  for my $r (0 .. @{ $self->{ rows } } - 1) {
    while ($self->{ rows }[$r] =~ /(\d+)/g) {
      # @- is the start of the match, @+ is the next character after
      if (my $s = $self->symbol( $r, $-[1], $+[1] - 1)) {
        say "$s $r $1 at @- to @+";
        $sum += $1;
       }
     }
   }
  return $sum;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    rows => [],
  };

  $self->{ rows } = [ Path::Tiny::path( $input_file )->lines( { chomp => 1 } ) ];

  $self->{ cols } = length( $self->{ rows }[0] );

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input03.txt';

my $grid = Grid->new( $input_file );

say "The sum of the part numbers is ", $grid->parts();

say "The sum of the gears is ", $grid->gears();

exit;
