# $Id: pod.t,v 1.1.1.1 2002/11/06 03:45:17 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@files = File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}

use Test::More tests => scalar @files;
use Test::Pod;

foreach my $file ( @files )
	{
	pod_ok( $file );
	}
