# $Id: TPR.pm,v 1.1.1.1 2002/11/06 03:45:17 comdog Exp $
package Pod::LaTeX::TPR;

use Pod::LaTeX;
use base qw(Pod::LaTeX);
use vars qw($VERSION);

$VERSION = 0.05;

=head1 NAME

Pod::LaTeX::TPR - Translate POD for The Perl Review

=head1 SYNOPSIS

	# same constructor for Pod::LaTeX
	my $parser = Pod::LaTeX::TPR->new( ... );
	
	# same methods for Pod::LaTeX
	
=head1 DESCRIPTION

The Pod::LaTeX module does a good job of translating POD to
LaTeX in the general case, but I wanted something different
for I<The Perl Review>.  This module overrides some of the
methods in Pod::LaTeX to get just what I want.  You can
do the same thing to get what you want by following this
example.

I also added some custom interior sequences (those XE<lt>E<gt>
things.)  

=over 4

=item FE<lt>this is a footnoteE<gt>

This turns into C<\footnote{this is a footnote}>

=item RE<lt>chapter1E<gt>

This turns into C<\ref{chapter1}>

=back

=head1 SEE ALSO

L<Pod::LaTeX>, L<Pod::Parser>

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	https://sourceforge.net/projects/brian-d-foy/
	
If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, brian d foy, All rights reserved

You may use this package under the same terms as Perl itself.

=cut

sub head
	{
	my $self = shift;
	my $num = shift;
	my $paragraph = shift;
	my $parobj = shift;
	
	return if $self->{_CURRENT_HEAD1} =~ /^(?:NAME|SYNOPSIS|AUTHOR)/i;
		
	my $level = $self->Head1Level() - 1 + $num;
	
	if ($num > $#Pod::LaTeX::LatexSections) 
		{
		my $line = $parobj->file_line;
		my $file = $self->input_file;
		warn "Heading level too large ($level) for LaTeX at line $line of file $file\n";
		$level = $#LatexSections;
		}

	$paragraph = 'References' if $self->{_CURRENT_HEAD1} eq 'SEE ALSO';
	
	return if $paragraph eq 'DESCRIPTION';
	
	$self->_output("\\" . $Pod::LaTeX::LatexSections[$level] . "{$paragraph}");
	}
	
sub textblock 
	{
	my $self = shift;
	my ($paragraph, $line_num, $parobj) = @_;

	if ($self->{_dont_modify_any_para} || $self->{_dont_modify_next_para}) 
		{
		$self->_output($paragraph);
		$self->{_dont_modify_next_para} = 0;
		return;
		} 
	
	$paragraph = $self->_replace_special_chars($paragraph);
	
	my $expansion = $self->interpolate($paragraph, $line_num);
	$expansion =~ s/\s+$//;
	
	
	if( $self->{_CURRENT_HEAD1} =~ /^NAME/i ) 
		{
		$paragraph =~ s/^\s+|\s+$//;
		
		$self->{_CURRENT_HEAD1} = '_NAME';
	
		$self->_output(<<"LATEX");
\\title{$expansion}
\\author{%%author%%}

\\begin{document}

\\maketitle

LATEX
		}
	elsif( $self->{_CURRENT_HEAD1} =~ /^SYNOPSIS/i ) 
		{
		$self->_output(<<"LATEX");
\\begin{abstract}
$expansion
\\end{abstract}

LATEX
		}
	elsif(  $self->{_CURRENT_HEAD1} =~ /^AUTHOR/i )
		{
		$self->{_MY_AUTHOR} = $expansion;
		} 
	else
		{
		$self->_output("\n\n$expansion\n\n");
		}
	}
	
sub command 
	{
	my $self = shift;
	my ($command, $paragraph, $line_num, $parobj) = @_;
	
	return if $command eq 'pod';
	
	$paragraph = $self->_replace_special_chars($paragraph);
	
	$paragraph = $self->interpolate($paragraph, $line_num);
	
	$paragraph =~ s/\s+$//;
	
	   if( $command eq 'over'  ) { $self->begin_list($paragraph, $line_num) } 
	elsif( $command eq 'item'  ) { $self->add_item($paragraph, $line_num)   } 
	elsif( $command eq 'back'  ) { $self->end_list($line_num)               }
	elsif( $command eq 'head1' ) {
		$self->{_CURRENT_HEAD1} = $paragraph;
		$self->head(1, $paragraph, $parobj);
		} 
	elsif( $command =~ m/head(\d)/ ) { $self->head($1, $paragraph, $parobj) } 
	elsif( $command eq 'begin' ) {
		if ($paragraph =~ /^latex/i) 
			{ $self->{_dont_modify_any_para} = 1 } 
		else { $self->{_suppress_all_para} = 1 }
		} 
	elsif( $command eq 'for' ) {
		if ($paragraph =~ /^latex/i) 
			{
			$self->{_dont_modify_next_para} = 1;
			} 
		else 
			{
			$self->{_suppress_next_para} = 1
			}
		} 
	elsif( $command eq 'end' ) 
		{
		$self->{_suppress_all_para} = 0;
		$self->{_dont_modify_any_para} = 0;
		}
	else { warn "[$command] not recognised at line $line_num\n" }
	}
	
sub end_pod 
	{
	my $self = shift;
		
	$self->_output( $self->UserPostamble );
	}

sub interior_sequence
	{
	my $self = shift;
	
	my $command  = shift;
	my $argument = shift;
	
	return do {
		if( $command eq 'F' )
			{
			"\\footnote\{$argument\}"
			}
		elsif( $command eq 'R' )
			{
			"\\ref\{$argument\}"
			}
		else
			{
			$self->SUPER::interior_sequence( $command, $argument, @_ );
			}
		
		};
	}

1;
