package Perinci::To::Text;

use 5.010001;
use Log::Any '$log';
use Moo;

extends 'Perinci::To::PackageBase';
with    'SHARYANTO::Role::Doc::Section::AddTextLines';

# VERSION

sub BUILD {
    my ($self, $args) = @_;
}

sub gen_doc_section_summary {
    my ($self) = @_;

    $self->SUPER::gen_doc_section_summary;

    my $name_summary = join(
        "",
        $self->{_res}{name} // "",
        ($self->{_res}{name} && $self->{_res}{summary} ? ' - ' : ''),
        $self->{_res}{summary} // ""
    );

    $self->add_doc_lines(uc($self->loc("Name")), "");

    $self->inc_doc_indent;
    $self->add_doc_lines($name_summary);
    $self->dec_doc_indent;
}

sub gen_doc_section_version {
    my ($self) = @_;
    $self->add_doc_lines("", uc($self->loc("Version")), "");

    $self->inc_doc_indent;
    $self->add_doc_lines($self->{_meta}{entity_version} // '?');
    $self->dec_doc_indent;
}

sub gen_doc_section_description {
    my ($self) = @_;

    $self->SUPER::gen_doc_section_description;
    return unless $self->{_res}{description};

    $self->add_doc_lines("", uc($self->loc("Description")), "");

    $self->inc_doc_indent;
    $self->add_doc_lines($self->{_res}{description});
    $self->dec_doc_indent;
}

sub gen_doc_section_functions {
    require Perinci::Sub::To::Text;

    my ($self) = @_;

    $self->{_fgen} //= Perinci::Sub::To::Text->new(
        _pa => $self->_pa, # to avoid multiple instances of pa objects
    );

    $self->add_doc_lines("", uc($self->loc("Functions")), "");
    $self->SUPER::gen_doc_section_functions;
    for my $furi (sort keys %{ $self->{_res}{functions} }) {
        my $fname;
        for ($fname) { $_ = $furi; s!.+/!! }
        for (@{ $self->{_res}{functions}{$furi} }) {
            chomp;
            $self->add_doc_lines({wrap=>0}, $_);
        }
        $self->add_doc_lines('');
    }
}

1;
# ABSTRACT: Generate text documentation for a package from Rinci metadata

=for Pod::Coverage .+

=head1 SYNOPSIS

 use Perinci::To::POD;
 my $doc = Perinci::To::Text->new(url => "/Some/Module/");
 say $doc->gen_doc;

You can also try the L<peri-pkg-doc> script (included in the L<Perinci::To::POD>
distribution) with the C<--format text> option:

 % peri-pkg-doc --format text /Some/Module/

To generate documentation for a single function, see L<Perinci::Sub::To::Text>
or the provided command-line script L<peri-func-doc>.

To generate a usage-like help message for a single function, you can try the
L<peri-func-usage> from the L<Perinci::CmdLine> distribution.

=cut
