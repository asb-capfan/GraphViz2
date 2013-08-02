#!/usr/bin/env perl

use strict;
use warnings;

use strict;
use utf8;
use warnings;
use warnings  qw(FATAL utf8);    # Fatalize encoding glitches.
use open      qw(:std :utf8);    # Undeclared streams in UTF-8.
use charnames qw(:full :short);  # Unneeded in v5.16.

use Capture::Tiny 'capture';

use File::Slurp; # For write_file().
use File::Spec;

use GraphViz2::Utils;

# ------------------------------------------------

sub format_output
{
	my($format, @output) = @_;

push @output, <<EOS;

perl -Ilib scripts/generate.demo.pl $format
EOS

	write_file("scripts/generate.$format.sh", @output);

} # End of format_output;

# ------------------------------------------------

my(%script) = GraphViz2::Utils -> new -> get_scripts;
my($width)  = 0;

for (keys %script)
{
	$width = length($_) if (length($_) > $width);
}

my(@output) = <<'EOS';
#!/bin/bash

DIR=/tmp

if [ -z $DBI_DSN ]; then
	echo Warning: DBI_DSN not set for scripts/dbi.schema.pl.
fi

EOS

my($offset);

for my $format (qw/png svg/)
{
	next if ($format eq 'png');

	for my $key (sort keys %script)
	{
		$offset = ' ' x ($width - length($key) );

		push @output, "perl -Ilib scripts/$key.pl $offset$format > \$DIR/$key.log\n";
	}

	# Warning: Do no pass in \@output, since format_output() patches @output.

	format_output($format, @output);
}