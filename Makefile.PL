# $Id: Makefile.PL,v 1.4 2002/12/05 19:02:29 comdog Exp $
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
	{
	my($self, $perl, $tests) = @_;

	return qq|\t$perl "-MTest::Manifest" | .
		qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
		qq|'\$(INST_ARCHLIB)')"\n|;
	}

WriteMakefile
	(
	'NAME'           => 'Pod::LaTeX::TPR',
	'ABSTRACT'       => 'translate POD for The Perl Review',
	'VERSION_FROM'   => 'lib/TPR.pm',

	'PREREQ_PM' => {
		'Pod::LaTeX'      => '0.54',
		'Test::Manifest'  => '0.9',
		'Test::More'      => '0',
		'Test::Pod'       => '0.90',
		'Test::Prereq'    => '0.18',
		},

	'PM' => {
		'lib/TPR.pm'     => '$(INST_LIBDIR)/TPR.pm',
		},

	'MAN3PODS' => {
		'lib/TPR.pm'    => '$(INST_MAN3DIR)/Pod::LaTeX::TPR.3',
		},

		clean  => { FILES => 'Pod-LaTeX-TPR-*' },
	);

