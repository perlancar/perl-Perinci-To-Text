package Perinci::To::Text;

use 5.010;
use Log::Any '$log';
use Moo;

extends 'Perinci::To::DocBase';

sub gen_summary {
    my ($self) = @_;

    my $name_summary = join(
        "",
        $self->_parse->{name} // "",
        ($self->_parse->{name} && $self->_parse->{summary} ? ' - ' : ''),
        $self->_parse->{summary} // ""
    );

    $self->add_lines(uc($self->loc("Name")), "");

    $self->inc_indent;
    $self->add_lines($name_summary);
    $self->dec_indent;
}

sub gen_description {
    my ($self) = @_;

    return unless $self->_parse->{description};

    $self->add_lines("", uc($self->loc("Description")), "");

    $self->inc_indent;
    $self->add_lines($self->_parse->{description});
    $self->dec_indent;
}

# version

1;
