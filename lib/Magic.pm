#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use List::Util qw/min max/;

my %magicLiteral = (
  '@'            => "fastq",
  'BZh'          => "bz",
  '\x1f\x8b\x08' => "gz",
  '>'            => "fasta",
  '\x5c\x67\x31' => "bam",
  '#!'           => "script",
);

my $maxMagicLength = max(map{length($_)} keys(%magicLiteral));

sub file{
    my ($file_path) = @_;
    open(my $fh, '<:raw', $file_path) or die "Could not open file '$file_path': $!";
    my $header = <$fh>;
    chomp($header);
    close($fh);

    my $maxLength = min(length($header), $maxMagicLength);

    for(my $length=length($header); $length > 0; $length--){
      my $headerSubstr = substr($header, 0, $length);
      if($magicLiteral{$headerSubstr}){
        return $magicLiteral{$headerSubstr};
      }
    }

    if($header =~ /^[\w\d]+\s*/){
      return "plaintext";
    }

    return "UNKNOWN";
}

