# $Id: load.t,v 1.2 2004/09/16 22:43:24 comdog Exp $
BEGIN {
	@classes = qw(Pod::LaTeX::TPR);
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! Could not compile $class" unless use_ok( $class );
	}
