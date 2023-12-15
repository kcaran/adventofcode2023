#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Spring;

sub test {
  my ($self, $value) = @_;

  my $format = $self->{ format };
  for my $i (0 .. @{ $self->{ unknown } } - 1) {
    my $char = ($value & 1 << $i) ? '#' : '.';
      substr( $format, $self->{ unknown }[$i], 1 ) = $char;
   }

  return $format;
 }

sub arrange {
  my ($self) = @_;
  my $total = 0;

  for my $i (0 .. ((1 << @{ $self->{ unknown } }) - 1)) {
    my $format = $self->test( $i );
    my $springs = () = $format =~ /#/g;
    next unless ($springs == $self->{ count });
#say "$format", ($format =~ /$self->{ valid }/) ? " matches" : '';
    $total++ if ($format =~ /$self->{ valid }/);
   }

  return $total;
 }

sub new {
  my ($class, $input) = @_;

  my ($format, $groups) = split( /\s+/, $input );

  my $self = {
    format => $format,
    groups => [ split( ',', $groups ) ],
    unknown => [],
    valid => '(?:^|\.+)',
    count => 0,
    known => 0,
  };
  bless $self, $class;

  $self->{ known } = () = $format =~ /#/g;

  for my $i (0 .. length($format) - 1) {
    push @{ $self->{ unknown } }, $i if (substr( $format, $i, 1 ) eq '?');
   }

  for my $i (0 .. @{ $self->{ groups } } - 1) {
    $self->{ count } += $self->{ groups }[$i];
   }

  $self->{ valid } .= join( '\.+', map { sprintf "#{%d}", $_ } @{ $self->{ groups } } );
  $self->{ valid } .= '(?:\.+|$)',

  $self->{ test } = $format =~ s/\?/./rg;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input12.txt';

my $total = 0;
for my $line (Path::Tiny::path( $input_file )->lines( { chomp => 1 } )) {
  my $spring = Spring->new( $line );
  my $arrangements = $spring->arrange();
say "$arrangements - $spring->{ format }";
  $total += $arrangements;
 }

say "The total number of possible arrangements is $total";

exit;
