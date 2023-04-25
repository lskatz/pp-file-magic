#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

use List::Util qw/min max/;

my %magicLiteral = (
  '@'            => "fastq",
  'BZh'          => "bz",
  '\x1f\x8b'     => "gz",
  #'\x1f\x8b\x08' => "gz",
  '>'            => "fasta",
  '\x5c\x67\x31' => "bam",
  '#!'           => "script",
  'GIF87a'       => "gif",
  'GIF89a'       => "gif",
  '\x49\x49\x2a\x00' => 'tif',
  '\x4d\x4d\x00\x2a' => 'tiff',
  '\xff\xd8\xff\xe0\x00\x10\x4a\x46' => 'jpg',
  '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a' => 'png',
  '<svg'         => 'svg',
  '%PDF'         => 'pdf',
  'BM'           => 'bmp',
  '\xfd\x37\x7a\x58\x5a\x00' => 'xz',

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

