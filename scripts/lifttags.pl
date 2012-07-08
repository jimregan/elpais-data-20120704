#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use HTML::DOM;
use Data::Dumper;
use Unicode::Escape;
use Encode;
use File::Find;
use Image::ExifTool qw(ImageInfo);
use Cwd;

#Path to spidered data
my $base = '';

open (my $lex, ">", "lexicalisations.nt");
open (my $ttp, ">", "tags-to-pages.nt");

sub dofile {
        my $file = $File::Find::name;
        my $base;
        
        return unless -f $file;
	my $info = ImageInfo($file, "MIMEType");
	return unless ($info->{'MIMEType'} eq 'text/html');
	grabtags($file);
}

sub grabtags {
	my $file = shift;

	my $dom = new HTML::DOM;

	$dom->parse_file($file);


	my $url = $file;
	$url =~ s/$base//;
	my @parts = split(/\//, $url);
	my $host = $parts[0] ne "" ? $parts[0] : $parts[1];

	$url = "http://$url";

	# Should have made that coffee... we don't need no stinking XPath
	for my $elem (@{$dom->getElementsByClassName('tags')}) {
		for my $child (@{$elem->getElementsByTagName('div')}) {
			next if ($child->className ne 'contenedor estirar');
			for my $ul (@{$child->getElementsByTagName('ul')}) {
				for my $li (@{$ul->getElementsByTagName('li')}) {
					for my $a (@{$li->getElementsByTagName('a')}) {
						next if ($a->attr('href') !~ m!/tag/!);
						my $taglink = 'http://' . $host . $a->attr('href');
						my $extag;
						if ($a->attr('title') =~ /Ver m.*s noticias de \[([^\]]*)\]/) {
							$extag = $1;
						} else {
							$extag = $a->attr('title');
						}
						my $esctag = Unicode::Escape::escape(encode("UTF-8", $extag));
						print $ttp "<$url> <http://purl.org/dc/terms/subject> <$taglink> .\n";
						print $lex "<$taglink> <http://lexvo.org/ontology#label> \"$esctag\" .\n";
						if ($a->firstChild->data ne $extag) {
							$esctag = Unicode::Escape::escape(encode("UTF-8", $$a->firstChild->data));
							print $lex "<$taglink> <http://lexvo.org/ontology#label> \"$esctag\" .\n";
						}
					}
				}
			}
		}
	}
}

find(\&dofile, cwd);


