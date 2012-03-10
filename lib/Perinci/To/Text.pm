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

sub gen_version {
    my ($self) = @_;

    $self->add_lines("", uc($self->loc("Version")), "");

    $self->inc_indent;
    $self->add_lines($self->{_meta}{pkg_version} // '?');
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

sub _gen_function {
    my ($self, $url) = @_;
    my $p = $self->_parse->{functions}{$url};

    $self->add_lines(
        "+ " . $p->{name} . ' -> ' . $p->{human_ret},
        "");
    $self->inc_indent;

    $self->add_lines($p->{summary});
    $self->add_lines("", $p->{description}) if $p->{description};
    if (keys %{$p->{args}}) {
        $self->add_lines(
            "",
            $self->loc("Arguments") .
                ' (' . $self->loc("'*' denotes required arguments") . '):',
            "");
        my $i = 0;
        for my $name (sort keys %{$p->{args}}) {
            my $pa = $p->{args}{$name};
            $self->add_lines("") if $i++ > 0;
            $self->add_lines(
                "- " . $name . ($pa->{schema}[1]{req} ? '*' : '') .
                    ' => ' . $pa->{human_arg});
            if ($pa->{summary} || $p->{description}) {
                $self->inc_indent;
                $self->add_lines($pa->{summary}) if $pa->{summary};
                if ($pa->{description}) {
                    $self->add_lines("", $pa->{description});
                }
                $self->dec_indent;
            }
        }
    }
    $self->add_lines("", $self->loc("Return value") . ':');

    $self->dec_indent;
    $self->add_lines("");
}

sub gen_functions {
    my ($self) = @_;
    my $pff = $self->_parse->{functions};

    $self->add_lines("", uc($self->loc("Functions")), "");
    $self->inc_indent;

    # XXX categorize functions based on tags
    for my $url (sort keys %$pff) {
        my $p = $pff->{$url};
        $self->_gen_function($url);
    }

    $self->dec_indent;
}

1;
# ABSTRACT: Generate text documentation from Rinci metadata

=cut