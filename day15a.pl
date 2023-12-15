#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

sub hash {
  my ($string) = @_;

  my $hash = 0;

  for my $idx (0 .. length( $string ) - 1) {
    my $char = substr( $string, $idx, 1 );
    $hash += ord( $char );
    $hash *= 17;
    $hash = $hash % 256;
   }

  return $hash;
 }

hash( 'HASH' );

my $input_file = $ARGV[0] || 'input15.txt';

my $total = 0;
my $sequence = Path::Tiny::path( $input_file )->slurp_utf8();
$sequence =~ s/\n$//;

for my $inst (split( ',', $sequence )) {
  my $hash = hash( $inst );
say "$inst $hash";
  $total += $hash;
 }

say "The total HASH value is $total";

exit;
