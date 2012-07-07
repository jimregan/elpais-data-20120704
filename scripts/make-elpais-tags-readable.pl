#!/usr/bin/perl

use warnings;
use strict;

while (<>) {
	chomp;
	next if (/\/fecha\//);
	my @a = split/\//;
	my @b = map(ucfirst, split/_/, $a[$#a]);
	my @tmp = @b;
	shift @tmp;
	my @first = map { substr $_, 0, 1 } @tmp;
	print "$_\t";
	if (lc(join '', @first) eq lc($b[0])) {
		print join ' ', @tmp; print "\n";
	} else {
		print join ' ', @b; print "\n";
	}

}
