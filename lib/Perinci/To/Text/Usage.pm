package Perinci::To::Text::Usage;

use 5.010;
use Log::Any '$log';
use Moo;

extends 'Perinci::To::DocBase';

sub gen_summary {
    my ($self) = @_;

    # XXX set name from cmdline's program_name (in parse_summary)

    $self->add_result(
        $self->_parse->{name} // "",
        ($self->_parse->{name} && $self->_parse->{summary} ? ' - ' : ''),
        $self->_parse->{summary} // "",
        "\n\n");
}

1;

__END__
    my $args  = $sub_spec->{args} // {};
    my $rargs = $sub_spec->{required_args};
    $args = { map {$_ => _parse_schema($args->{$_})} keys %$args };
    my $has_cat = grep { $_->{clause_sets}[0]{arg_category} }
        values %$args;
    my $prev_cat;
    my $noted_star_req;
    for my $name (sort {
        (($args->{$a}{clause_sets}[0]{arg_category} // "") cmp
             ($args->{$b}{clause_sets}[0]{arg_category} // "")) ||
                 (($args->{$a}{clause_sets}[0]{arg_pos} // 9999) <=>
                      ($args->{$b}{clause_sets}[0]{arg_pos} // 9999)) ||
                          ($a cmp $b) } keys %$args) {
        my $arg = $args->{$name};
        my $ah0 = $arg->{clause_sets}[0];

        my $cat = $ah0->{arg_category} // "";
        if (!defined($prev_cat) || $prev_cat ne $cat) {
            $usage .= "\n" if defined($prev_cat);
            $usage .= ($cat ? ucfirst("$cat options") :
                           ($has_cat ? "General options" :
                                ($args{options_name} ?
                                     "$args{options_name} options" :
                                         "Options")));
            $usage .= " (* denotes required options)"
                unless $noted_star_req++;
            $usage .= ":\n";
            $prev_cat = $cat;
        }

        my $arg_desc = "";

        if ($arg->{type} eq 'any') {
            my @schemas = map {_parse_schema($_)} @{$ah0->{of}};
            my @types   = map {$_->{type}} @schemas;
            @types      = sort List::MoreUtils::uniq(@types);
            $arg_desc  .= "[" . join("|", @types) . "]";
        } else {
            $arg_desc  .= "[" . $arg->{type} . "]";
        }

        my $o = $ah0->{arg_pos};
        my $g = $ah0->{arg_greedy};

        $arg_desc .= " $ah0->{summary}" if $ah0->{summary};
        $arg_desc .= " (one of: ".
            Data::Dump::Partial::dumpp($ah0->{in}).")"
                  if defined($ah0->{in});
        $arg_desc .= " (default: ".
            Data::Dump::Partial::dumpp($ah0->{default}).")"
                  if defined($ah0->{default});

        my $aliases = $ah0->{arg_aliases};
        if ($aliases) {
            $arg_desc .= "\n";
            for (sort keys %$aliases) {
                my $alinfo = $aliases->{$_};
                $arg_desc .= join(
                    "",
                    "      ",
                    (length == 1 ? "-$_" : "--$_"), " ",
                    $alinfo->{summary} ? $alinfo->{summary} :
                        "is alias for '$name'",
                    "\n"
                );
            }
        }

        my $desc = $ah0->{description};
        if ($desc) {
            $desc =~ s/^\n+//; $desc =~ s/\n+$//;
            # XXX format/rewrap
            $desc =~ s/^/      /mg;
            $arg_desc .= "\n$desc\n";
        }

        $usage .= sprintf("  --%-25s %s\n",
                          $name . ($ah0->{req} ? "*" : "") .
                              (defined($o) ? " [or arg ".($o+1).
                                  ($g ? "-last":"")."]" : ""),
                          $arg_desc);
    }

    if ($sub_spec->{cmdline_examples}) {
        $usage .= "\nExamples:\n\n";
        my $cmd = $args{command_name} // $0;
        for my $ex (@{ $sub_spec->{cmdline_examples} }) {
            $usage .= " % $cmd $ex->{cmd}\n";
            my $desc = $ex->{description};
            if ($desc) {
                $desc =~ s/^\n+//; $desc =~ s/\n+$//;
                $usage .= "\n$desc\n\n";
            }
        }
    }

    [200, "OK", $usage];
}

1;
# ABSTRACT: Generate usage/help message from sub spec
__END__

=head1 SYNOPSIS

 use Sub::Spec::To::Text::Usage qw(spec_to_usage);
 my $text = spec_to_usage(spec=>$spec, ...);


=head1 DESCRIPTION


=head1 FUNCTIONS

None are exported, but they are exportable.

=cut
