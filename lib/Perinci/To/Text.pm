package Perinci::To::Text;

use 5.010001;
use Log::Any '$log';
use Moo;

extends 'Perinci::To::PackageBase';
with    'Perinci::To::Text::AddDocLinesRole';

# VERSION

sub BUILD {
    my ($self, $args) = @_;
}

sub doc_gen_summary {
    my ($self) = @_;

    my $name_summary = join(
        "",
        $self->doc_parse->{name} // "",
        ($self->doc_parse->{name} && $self->doc_parse->{summary} ? ' - ' : ''),
        $self->doc_parse->{summary} // ""
    );

    $self->add_doc_lines(uc($self->loc("Name")), "");

    $self->inc_indent;
    $self->add_doc_lines($name_summary);
    $self->dec_indent;
}

sub doc_gen_version {
    my ($self) = @_;

    $self->add_doc_lines("", uc($self->loc("Version")), "");

    $self->inc_indent;
    $self->add_doc_lines($self->{_meta}{entity_version} // '?');
    $self->dec_indent;
}

sub doc_gen_description {
    my ($self) = @_;

    return unless $self->doc_parse->{description};

    $self->add_doc_lines("", uc($self->loc("Description")), "");

    $self->inc_indent;
    $self->add_doc_lines($self->doc_parse->{description});
    $self->dec_indent;
}

sub _fdoc_gen {
    my ($self, $url) = @_;
    my $p = $self->doc_parse->{functions}{$url};

    $self->add_doc_lines(
        "+ " . $p->{name} . $p->{perl_args} . ' -> ' . $p->{human_ret},
    );
    $self->inc_indent;

    $self->add_doc_lines("", $p->{summary}) if $p->{summary};
    $self->add_doc_lines("", $p->{description}) if $p->{description};
    if (keys %{$p->{args}}) {
        $self->add_doc_lines(
            "",
            $self->loc("Arguments") .
                ' (' . $self->loc("'*' denotes required arguments") . '):',
            "");
        my $i = 0;
        my $arg_has_ct;
        for my $name (sort keys %{$p->{args}}) {
            my $prev_arg_has_ct = $arg_has_ct;
            $arg_has_ct = 0;
            my $pa = $p->{args}{$name};
            $self->add_doc_lines("") if $i++ > 0 && $prev_arg_has_ct;
            $self->add_doc_lines(join(
                "",
                "- ", $name, ($pa->{req} ? '*' : ''), ' => ',
                $pa->{human_arg},
                (defined($pa->{human_arg_default}) ?
                     " (" . $self->loc("default") .
                         ": $pa->{human_arg_default})" : "")
            ));
            if ($pa->{summary} || $p->{description}) {
                $arg_has_ct++;
                $self->inc_indent;
                $self->add_doc_lines("", $pa->{summary}) if $pa->{summary};
                if ($pa->{description}) {
                    $self->add_doc_lines("", $pa->{description});
                }
                $self->dec_indent;
            }
        }
    }

    if ($p->{meta}{dies_on_error}) {
        $self->add_doc_lines("", $self->loc(
            "This function dies on error."), "");
    }

    $self->add_doc_lines("", $self->loc("Return value") . ':', "");
    $self->inc_indent;
    my $rn = $p->{orig_meta}{result_naked} // $p->{meta}{result_naked};
    $self->add_doc_lines($self->loc(join(
        "",
        "Returns an enveloped result (an array). ",
        "First element (status) is an integer containing HTTP status code ",
        "(200 means OK, 4xx caller error, 5xx function error). Second element ",
        "(msg) is a string containing error message, or 'OK' if status is ",
        "200. Third element (result) is optional, the actual result. Fourth ",
        "element (meta) is called result metadata and is optional, a hash ",
        "that contains extra information.")))
        unless $rn;
    $self->dec_indent;

    $self->dec_indent;
    $self->add_doc_lines("");

    # test
    #$self->add_doc_lines({wrap=>0}, "Line 1\nLine 2\n");
}

sub doc_gen_functions {
    my ($self) = @_;
    my $pff = $self->doc_parse->{functions};

    $self->add_doc_lines("", uc($self->loc("Functions")), "");
    $self->inc_indent;

    # XXX categorize functions based on tags
    for my $url (sort keys %$pff) {
        my $p = $pff->{$url};
        $self->_fdoc_gen($url);
    }

    $self->dec_indent;
}

1;
# ABSTRACT: Generate text documentation from Rinci package metadata

=for Pod::Coverage .+

=head1 SYNOPSIS

 use Perinci::To::POD;

 # to generate text documentation for the whole module
 my $doc = Perinci::To::Text->new(url => "/Some/Module/");
 say $doc->generate_doc;

You can also try the L<peri-doc> script (included in the L<Perinci::To::POD>
distribution) with the C<--format text> option:

 % peri-doc --format text Some::Module

To generate a usage-like help message for a single function only, you can try
L<Perinci::CmdLine>, using it like this:

 my $cmd = Perinci::CmdLine->new(url => "/Some/Module/func");
 $cmd->run_help; # will print help text

=cut
