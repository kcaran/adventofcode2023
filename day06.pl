#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Race;

sub distance {
  my ($self, $time) = @_;

  return ($self->{ time } - $time) * $time;
 }

sub score {
  my ($self) = @_;

  my $min = 1;
  while ($self->distance( $min ) <= $self->{ record }) {
    $min++;
   }

  my $max = $self->{ time } - 1;
  while ($self->distance( $max ) <= $self->{ record }) {
    $max--;
   }

  return ($max - $min + 1);
 }

sub new {
  my ($class, $time, $record) = @_;

  my $self = {
    time => $time,
    record => $record,
  };

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input06.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8();
my ($time_list) = $input =~ /Time:\s+(.*?)$/sm;
my @times = split( /\s+/, $time_list );
my ($record_list) = $input =~ /Distance:\s+(.*?)$/sm;
my @records = split( /\s+/, $record_list );

my $score = 1;
for my $i (0 .. @times - 1) {
  my $race = Race->new( $times[$i], $records[$i] );
  $score = $score * $race->score();
 }

say "The margin of error for part a is $score";

$time_list =~ s/\s+//g;
$record_list =~ s/\s+//g;
my $race_b = Race->new( $time_list, $record_list );
say "The margin of error for part b is ", $race_b->score();

exit;
