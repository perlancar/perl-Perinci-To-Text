package Perinci::To::Text::AddDocLinesRole;

use 5.010;
use Log::Any '$log';
use Moo::Role;

# VERSION

has wrap => (is => 'rw', default => sub {1});

sub add_doc_lines {
    my $self = shift;
    my $opts;
    if (ref($_[0]) eq 'HASH') { $opts = shift }
    $opts //= {};

    my @lines = map { $_ . (/\n\z/s ? "" : "\n") }
        map {/\n/ ? split /\n/ : $_} @_;

    my $indent = $self->indent x $self->indent_level;
    my $wrap = $opts->{wrap} // $self->wrap;

    if ($wrap) {
        require Text::Wrap;

        # split into paragraphs, merge each paragraph text into a single line
        # first
        my @para;
        my $i = 0;
        my ($start, $type);
        $type = '';
        #$log->warnf("lines=%s", \@lines);
        for (@lines) {
            if (/^\s*$/) {
                if (defined($start) && $type ne 'blank') {
                    push @para, [$type, [@lines[$start..$i-1]]];
                    undef $start;
                }
                $start //= $i;
                $type = 'blank';
            } elsif (/^\s{4,}\S+/ && (!$i || $type eq 'verbatim' ||
                         (@para && $para[-1][0] eq 'blank'))) {
                if (defined($start) && $type ne 'verbatim') {
                    push @para, [$type, [@lines[$start..$i-1]]];
                    undef $start;
                }
                $start //= $i;
                $type = 'verbatim';
            } else {
                if (defined($start) && $type ne 'normal') {
                    push @para, [$type, [@lines[$start..$i-1]]];
                    undef $start;
                }
                $start //= $i;
                $type = 'normal';
            }
            #$log->warnf("i=%d, lines=%s, start=%s, type=%s",
            #            $i, $_, $start, $type);
            $i++;
        }
        if (@para && $para[-1][0] eq $type) {
            push @{ $para[-1][1] }, [$type, [@lines[$start..$i-1]]];
        } else {
            push @para, [$type, [@lines[$start..$i-1]]];
        }
        #$log->warnf("para=%s", \@para);

        for my $para (@para) {
            if ($para->[0] eq 'blank') {
                push @{$self->doc_lines}, @{$para->[1]};
            } else {
                if ($para->[0] eq 'normal') {
                    for (@{$para->[1]}) {
                        s/\n/ /g;
                    }
                    $para->[1] = [join("", @{$para->[1]}) . "\n"];
                }
                #$log->warnf("para=%s", $para);
                push @{$self->doc_lines},
                    Text::Wrap::wrap($indent, $indent, @{$para->[1]});
            }
        }
    } else {
        push @{$self->doc_lines},
            map {"$indent$_"} @lines;
    }
}

1;

# ABSTRACT: Role which provides add_doc_lines() with text wrapping

=head1 DESCRIPTION

This role provides C<add_doc_lines()> which wraps the lines. This method is
separated from L<Perinci::To::Text> so other modules can use it (e.g.
L<Perinci::CmdLine>, which also generates help/usage message).

To change width of columns, set C<$Text::Wrap::columns>.


=head1 ATTRIBUTES

=head2 wrap => BOOL (default 1)

Whether to do text wrapping.


=head1 METHODS

=head2 $o->add_doc_lines([$opts, ]@lines)

=cut
