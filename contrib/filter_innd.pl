# $Id: filter_innd.pl,v 1.6 2010/01/05 12:01:13 jochen Exp $
# Copyright (c) 2004-2005 Jochen Striepe <t-prot@tolot.escape.de>
#
# This file is provided as an example how t-prot can be used for
# Perl filtering with INN2. It is NOT meant for production use.
# Read the README.perl_hook coming with your version of INN2, and
# adapt the script to your needs.
#
# Please see t-prot's man page for command line parameter details.
#
# Requirements/Bugs: mktemp(1) should be quite widely spread by
# now -- if it is not installed on your system, get the sources
# from Debian Linux or OpenBSD. Of course, rm(1) is POSIX and will
# be present on any reasonably Unix-like system.
# The script should not be run on any heavy-duty machines -- the
# writes to /tmp will be costly when many articles are committed
# at the same time. Sadly, there seems to be no really clean,
# portable, and standard way to realize a two-way pipe with perl.
# Please point me to some documentation if I am wrong. Thank you. :)
#
# License: This file is part of the t-prot package and therefore
# available under the same conditions. See t-prot's man page for
# details.
# The whole idea is robbed from Martin Dietze -- see his version at
#   http://www.fh-wedel.de/pub/fh-wedel/staff/herbert/linux/
# Please note that there is no code copied from there, so the files
# in the t-prot package are *not* available under the terms of the
# GPL.

sub filter_art {
	my $rval = "" ; # Assume we'll accept. Cannot be `0'

# Here we only filter local.* news groups. Another useful idea is to
# filter just locally submitted articles:
#	if (index($hdr{'Path'}, '!')<0) {
	if ($hdr{'Newsgroups'} =~ /^local\./) {
		my $foo = $hdr{'__BODY__'};
		$foo =~ s/\r\n/\n/gs;

# Note that here might be a security problem lurking. The directory
# used for temporary files should not be writable for anyone but the
# user INN runs as. As mentioned above, this example file is NOT
# meant for production use.
		open(TMP, '/usr/bin/mktemp -q /tmp/INN2/tmp.XXXXXX | tr -d \'\n\'|')
			|| return '';
		my $f = <TMP>;
		close TMP;

		open(OUT, ">$f")
			|| return '';
		print OUT $foo;
		close OUT;

		open(IN, "/usr/bin/t-prot -m -t -p --body --check=ratio -i $f|")
			|| goto FINISH;
		$rval = <IN>;
		close IN;

		FINISH: unlink($f);
	}

	$rval ;
}

sub filter_mode {
}

sub filter_messageid {
    $rval = '';
    $rval;
}

