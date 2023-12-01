#!/usr/bin/env perl
#
# For part b, I originally thought I could iterate over the digits and
# replace them, but 'eightwothree' would be eigh23 not 8wo3!
# But that is only for the first and last number! So 3oneight should
# still have an 8 at the end.
#

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my %digits = (
	'one' => 1,
	'two' => 2,
	'three' => 3,
	'four' => 4,
	'five' => 5,
	'six' => 6,
	'seven' => 7,
	'eight' => 8,
	'nine' => 9,
);

sub calibration_a {
  my ($line) = @_;

  my ($tens) = ($line =~ /^\D*(\d)/);
  my ($ones) = ($line =~ /(\d)\D*$/);

  return $tens * 10 + $ones;
 }

sub check_for_digit {
  my ($string) = @_;

  my $next = substr( $string, 0, 1 );
  if ($next ge '1' && $next le '9') {
    return $next;
   }

  for my $d (keys %digits) {
    my $num_len = length( $d );
    return $digits{ $d } if (length( $string ) >= $num_len && substr( $string, 0, $num_len ) eq $d);
   }

  return;
 }

sub calibration_b {
  my ($line) = @_;

  my $i = 0;
  my $tens = 0;
  while (!$tens && $i < length( $line )) {
    $tens = check_for_digit( substr( $line, $i ) );
    $i++;
   }
  die "Can't find tens digit for $line" unless ($tens);

  my $ones = 0;
  $i = length( $line ) - 1;
  while (!$ones && $i >= 0) {
    $ones = check_for_digit( substr( $line, $i ) );
    $i--;
   }
  die "Can't find ones digit for $line" unless ($ones);

  return $tens * 10 + $ones;
 }

my $input_file = $ARGV[0] || 'input01.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );
my $sum_a = 0;
my $sum_b = 0;
for my $line (@lines) {
  $sum_a += calibration_a( $line );
  $sum_b += calibration_b( $line );
 }

say "The calibration value sum for part a is $sum_a";
say "The calibration value sum for part b is $sum_b";

exit;
