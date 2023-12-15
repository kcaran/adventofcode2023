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

sub test {
  my ($self, $col) = @_;

  my $num_cols = @{ $self->{ map }[0] };
  my $num_rows = @{ $self->{ map } };

  my $min = ($col > $num_cols / 2) ? $num_cols - $col : $col;

  for my $r (0 .. $num_rows - 1) {
    my $row = join( '', @{ $self->{ map }[$r] } );
    my $left = substr( $row, $col - $min, $min );
    my $right = substr( $row, $col, $min );
    return 0 unless ($left eq reverse $right);
   }

  return $col;
 }

sub reflect {
  my ($self) = @_;

  my $score = 0;
  for my $col (1 .. @{ $self->{ map }[0] } - 1) {
    my $test = $self->test( $col );
    say "Already $score ($col)" if ($score && $test);
    $score += $test;
   }

  # Now, test the rows
  $self->rotate(0);
  for my $row (1 .. @{ $self->{ map }[0] } - 1) {
    my $test = $self->test( $row );
    say "Already $score ($row)" if ($score > 100 && $test);
    $score += 100 * $self->test( $row );
   }

say "more than one $score" if ($score > 100 && $score % 100);
  return $score;
 }

sub rotate {
  my ($self, $right) = @_;

  my $new = [];
  my $num_cols = @{ $self->{ map }[0] };
  my $num_rows = @{ $self->{ map } };
  for my $row (0 .. $num_rows - 1) {
    for my $col (0 .. $num_cols - 1) {
      if ($right) {
        $new->[$col][$num_rows - $row - 1] = $self->{ map }[$row][$col];
       }
      else {
        $new->[$num_cols - $col - 1][$row] = $self->{ map }[$row][$col];
       }
     }
   }

  $self->{ map } = $new;
  return;
 }

sub new {
  my ($class, $input) = @_;

  my $self = {
	map => [],
  };
  bless $self, $class;

  my @lines = split( "\n", $input );
  for my $row (0 .. @lines - 1) {
    $self->{ map }[$row] = [ split( '', $lines[$row] ) ];
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input13.txt';

my $patterns = Path::Tiny::path( $input_file )->slurp_utf8();
$patterns =~ s/\n$//;

my $sum = 0;
for my $p (split( "\n\n", $patterns )) {
  my $mirrors = Map->new( $p );
  $sum += $mirrors->reflect();
 }

say "The total score for lines of reflection is $sum";

exit;

