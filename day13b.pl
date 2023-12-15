#!/usr/bin/env perl
#
# I struggled with the smudging. I thought this would work:
#
# my $smudge = \$self->{ map }[$row][$col];
# $$smudge = ($$smudge eq '.') ? '#' : '.';
#
# but the reference did not match the data structure
#

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
  my ($self, $old_row, $old_col) = @_;

  my $score = 0;
  for my $col (1 .. @{ $self->{ map }[0] } - 1) {
    next if ($col eq $old_col);
    my $test = $self->test( $col );
    say "Already col $score $old_col ($col)" if ($score && $test);
    $score += $self->test( $col );
   }

  # Now, test the rows
  $self->rotate(0);
  for my $row (1 .. @{ $self->{ map }[0] } - 1) {
    next if ($row eq $old_row);
    my $test = $self->test( $row );
    say "Already row $score $old_row ($row)" if ($score > 100 && $test);
    $score += 100 * $self->test( $row );
   }

  $self->rotate(1);

  return $score;
 }

sub smudge {
  my ($self) = @_;

  my $num_cols = @{ $self->{ map }[0] };
  my $num_rows = @{ $self->{ map } };
  my $old_score = $self->reflect( 0, 0 );
  my $old_row = int($old_score/100);
  my $old_col = $old_score % 100;
  my ($srow, $scol) = (0, 0);
  $self->{ map }[$srow][$scol] = ($self->{ map }[$srow][$scol] eq '.') ? '#' : '.';

  for my $row (0 .. $num_rows - 1) {
    for my $col (0 .. $num_cols - 1) {
      # Revert old mirror
      $self->{ map }[$srow][$scol] = ($self->{ map }[$srow][$scol] eq '.') ? '#' : '.';
      ($srow, $scol) = ($row, $col);
      $self->{ map }[$srow][$scol] = ($self->{ map }[$srow][$scol] eq '.') ? '#' : '.';
      my $score = $self->reflect( $old_row, $old_col );
say "$row, $col, $score" if ($score);
      return $score if ($score);
     }
   }

  return;
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
  $sum += $mirrors->smudge();
 }

say "The total score for lines of reflection is $sum";

exit;

