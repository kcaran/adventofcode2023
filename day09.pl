#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Sensor;

sub next {
  my ($self) = @_;

  for my $i (reverse( 0 .. @{ $self->{ values } } - 2 )) {
    my $curr = $self->{ values }[$i];
    my $prev = $self->{ values }[$i+1];
    push @{ $curr }, ($curr->[-1] + $prev->[-1]);
   }

  return $self->{ values }[0][-1];
 }

sub prev {
  my ($self) = @_;

  for my $i (reverse( 0 .. @{ $self->{ values } } - 2 )) {
    my $curr = $self->{ values }[$i];
    my $prev = $self->{ values }[$i+1];
    unshift @{ $curr }, ($curr->[0] - $prev->[0]);
   }

  return $self->{ values }[0][0];
 }

sub diffs {
  my ($self, @values) = @_;
  my @diffs;

  for my $i (0 .. @values - 2) {
    push @diffs, ($values[$i + 1] - $values[$i]);
   }

  return @diffs;
 }

sub new {
  my ($class, $input) = @_;

  my $self = {
    values => [],
  };
  bless $self, $class;

  my @values = split( /\s+/, $input );
  push @{ $self->{ values } }, [ @values ];
  while (join( '', @values ) !~ /^0+$/) {
    @values = $self->diffs( @values );
    push @{ $self->{ values } }, [ @values ];
   }


  return $self;
 }
}

my $input_file = $ARGV[0] || 'input09.txt';

my $end_sum;
my $beg_sum;
for my $line (Path::Tiny::path( $input_file )->lines( { chomp => 1 } )) {
  my $sensor = Sensor->new( $line );
  $end_sum += $sensor->next();
  $beg_sum += $sensor->prev();
 }

say "The sum the extrapolated end values is $end_sum";
say "The sum the extrapolated beginning values is $beg_sum";

exit;
