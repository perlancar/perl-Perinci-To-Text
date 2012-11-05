package Perinci::To::PackageBase;

use 5.010;
use Data::Dump::OneLine qw(dump1);
use Log::Any '$log';
use Moo;
use Perinci::Object;
use Perinci::ToUtil;

with 'SHARYANTO::Role::Doc::Section';
with 'SHARYANTO::Role::I18N';
with 'SHARYANTO::Role::I18NRinci';

has url => (is=>'rw');
has function_sections => (is => 'rw');
#has method_sections => (is => 'rw');
has _pa => (
    is => 'rw',
    lazy => 1,
    default => sub {
        require Perinci::Access;
        require Perinci::Access::InProcess;
        my $pa = Perinci::Access->new;
        # slightly reduce startup overhead by avoiding to compile sah schemas
        my $pai = Perinci::Access::InProcess->new(
            extra_wrapper_args => {
                validate_args => 0,
                compile => 0,
            },
        );
        $pa->{handlers}{pl} = $pai;
        $pa;
    },
); # store Perinci::Access object

# VERSION

sub BUILD {
    my ($self, $args) = @_;

    $self->{url} or die "Please specify url";
    $self->{doc_sections} //= [
        'summary',
        'version',
        'description',
        'functions',
        'links',
    ];
    $self->{function_sections} //= [
        'summary',
        'description',
        'arguments',
        'result',
        'examples',
        'links',
    ];
    #$self->{method_sections} //= $self->{function_sections};
}

sub add_doc_lines {
    my $self = shift;
    my $opts;
    if (ref($_[0]) eq 'HASH') { $opts = shift }
    $opts //= {};

    my @lines = map { $_ . (/\n\z/s ? "" : "\n") }
        map {/\n/ ? split /\n/ : $_} @_;

    my $indent = $self->indent x $self->indent_level;
    push @{$self->doc_lines},
        map {"$indent$_"} @lines;
}

sub add_function_section_before {
    my ($self, $name, $before) = @_;
    my $ss = $self->function_sections;
    return unless $ss;
    my $i = 0;
    my $added;
    while ($i < @$ss && defined($before)) {
        if ($ss->[$i] eq $before) {
            my $pos = $i;
            splice @$ss, $pos, 0, $name;
            $added++;
            last;
        }
        $i++;
    }
    unshift @$ss, $name unless $added;
}

sub add_function_section_after {
    my ($self, $name, $after) = @_;
    my $ss = $self->function_sections;
    return unless $ss;
    my $i = 0;
    my $added;
    while ($i < @$ss && defined($after)) {
        if ($ss->[$i] eq $after) {
            my $pos = $i+1;
            splice @$ss, $pos, 0, $name;
            $added++;
            last;
        }
        $i++;
    }
    push @$ss, $name unless $added;
}

sub delete_function_section {
    my ($self, $name) = @_;
    my $ss = $self->function_sections;
    return unless $ss;
    my $i = 0;
    while ($i < @$ss) {
        if ($ss->[$i] eq $name) {
            splice @$ss, $i, 1;
        } else {
            $i++;
        }
    }
}

sub doc_parse_summary {
    my ($self) = @_;

    my ($name, $summary);

    my $modname;
    for ($modname) {
        $_ = $self->{_info}{uri};
        s!^pm:/!!;
        s!/$!!;
        s!/!::!g;
    }

    if ($self->{_meta}) {
        $name    = $self->langprop($self->{_meta}, "name");
        $summary = $self->langprop($self->{_meta}, "summary");
    }
    $name //= $modname;
    $summary = "";

    $self->doc_parse->{name}    = $name;
    $self->doc_parse->{summary} = $summary;
}

sub doc_gen_summary {}

sub doc_parse_version {
    # already in meta's entity_version
}

sub doc_gen_version {}

sub doc_parse_description {
    my ($self) = @_;

    $self->doc_parse->{description} = $self->{_meta} ?
        $self->langprop($self->{_meta}, "description") : undef;
}

sub doc_gen_description {}

sub fdoc_parse_summary {
    my ($self) = @_;
    my $p = $self->doc_parse->{functions}{ $self->{_furl} };

    my $name = $self->langprop($self->{_fmeta}, "name");
    if (!$name) {
        $self->{_furl} =~ m!.+/(.+)!;
        $name = $1;
    }
    my $summary = $self->langprop($self->{_fmeta}, "summary");
    $p->{name}    = $name;
    $p->{summary} = $summary;
}

sub fdoc_gen_summary {}

sub fdoc_parse_description {}

sub fdoc_gen_description {}

sub fdoc_parse_links {}

sub fdoc_gen_links {}

sub fdoc_parse_arguments {
    my ($self) = @_;
    my $p      = $self->doc_parse->{functions}{ $self->{_furl} };
    my $fmeta  = $self->{_fmeta};
    my $fometa = $self->{_fometa};

    my $aa = $fometa->{args_as} // $fmeta->{args_as} // 'hash';
    my $paa;
    if ($aa eq 'hash') {
        $paa = '(%args)';
    } elsif ($aa eq 'hashref') {
        $paa = '(\%args)';
    } elsif ($aa eq 'array') {
        $paa = '(@args)';
    } elsif ($aa eq 'arrayref') {
        $paa = '(\@args)';
    } else {
        die "BUG: Unknown value of args_as '$aa'";
    }
    $p->{perl_args} = $paa;

    my $args  = $fmeta->{args} // {};
    $p->{args} = {};
    for my $name (keys %$args) {
        my $arg = $args->{$name};
        $arg->{default_lang} //= $fmeta->{default_lang};
        $arg->{schema} //= ['any'=>{}];
        my $s = $arg->{schema};
        my $pa = $p->{args}{$name} = {schema=>$s};
        $pa->{human_arg} = Perinci::ToUtil::sah2human_short($s);
        if (defined $s->[1]{default}) {
            $pa->{human_arg_default} = dump1($s->[1]{default});
        }
        $pa->{summary}     = $self->langprop($arg, 'summary');
        $pa->{description} = $self->langprop($arg, 'description');
        $pa->{arg}         = $arg;
        $pa->{req}         = $arg->{req}; # for convenience
        #$pa->{pos}         = $arg->{pos}; # already available in 'arg'
    }
}

sub fdoc_gen_arguments {}

sub fdoc_parse_examples {
}

sub fdoc_gen_examples {}

sub fdoc_parse_result {
    my ($self) = @_;
    my $p      = $self->doc_parse->{functions}{ $self->{_furl} };
    my $fmeta  = $self->{_fmeta};
    my $fometa = $self->{_fometa};

    $p->{res_schema} = $fmeta->{result} ? $fmeta->{result}{schema} : undef;
    $p->{res_schema} //= [any => {}];
    $p->{human_res} = Perinci::ToUtil::sah2human_short($p->{res_schema});

    my $rn = $fometa->{result_naked} // $fmeta->{result_naked};
    if ($rn) {
        $p->{human_ret} = $p->{human_res};
    } else {
        $p->{human_ret} = '[status, msg, result, meta]';
    }

    $p->{summary}     = $self->langprop($fmeta, "summary");
    $p->{description} = $self->langprop($fmeta, "description");
}

sub fdoc_gen_result {}

sub _fdoc_parse {
    my ($self, $url) = @_;
    $log->tracef("=> _fdoc_parse(url=%s)", $url);

    my $fmeta;
    my $fometa;
    my $found;
    {
        if ($self->{_child_metas}) {
            if ($fmeta = $self->{_child_metas}{$url}) {
                $fometa = $self->{_child_orig_metas}{$url};
                $found++;
                last;
            }
        }

        my $res = $self->_pa->request(meta => $url);
        $res->[0] == 200 or die "Can't meta $self->{url}: ".
            "$res->[0] - $res->[1]";
        $fmeta  = $res->[2];
        $fometa = $res->[3]{orig_meta};
        $found++;
        last;
    }
    die "BUG: Didn't find function metadata" unless $found;
    $self->{_furl} = $url;
    $self->{_fmeta} = $fmeta;
    $self->{_fometa} = $fometa;

    $self->doc_parse->{functions}{$url} = {meta=>$fmeta, orig_meta=>$fometa};
    for my $s (@{ $self->function_sections // [] }) {
        my $meth = "fdoc_parse_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
    }
}

sub _fdoc_gen {
    my ($self, $url, %opts) = @_;
    $log->tracef("=> _fdoc_gen(url=%s, opts=%s)", $url, \%opts);

    my $p = $self->doc_parse->{functions}{$url};
    for my $s (@{ $self->function_sections // [] }) {
        my $meth = "fdoc_gen_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
    }
}

sub doc_parse_functions {
    my ($self) = @_;

    for my $e (@{ $self->{_children} }) {
        next unless $e->{type} eq 'function';
        $self->_fdoc_parse($e->{uri});
    }
}

sub doc_gen_functions {
    my ($self) = @_;

    for my $e (@{ $self->{_children} }) {
        next unless $e->{type} eq 'function';
        $self->_fdoc_gen($e->{uri});
    }
}

sub doc_parse_links {
}

sub doc_gen_links {}

sub before_generate_doc {
    my ($self, %opts) = @_;
    $log->tracef("=> PackageBase's before_generate_doc(opts=%s)", \%opts);

    # let's retrieve the metadatas first

    my $res = $self->_pa->request(info=>$self->{url});
    $res->[0] == 200 or die "Can't info $self->{url}: $res->[0] - $res->[1]";
    $self->{_info} = $res->[2];
    #$log->tracef("info=%s", $self->{_info});

    die "url must be a package entity, not $self->{_info}{type} ($self->{url})"
        unless $self->{_info}{type} eq 'package';

    $res = $self->_pa->request(meta=>$self->{url});
    if ($res->[0] == 200) {
        $self->{_meta} = $res->[2];
        $self->{_orig_meta} = $res->[3]{orig_meta};
        #$log->tracef("meta=%s", $self->{_meta});
        #$log->tracef("orig_meta=%s", $self->{_orig_meta});
    }

    $res = $self->_pa->request(list=>$self->{url}, {detail=>1});
    $res->[0] == 200 or die "Can't list $self->{url}: $res->[0] - $res->[1]";
    $self->{_children} = $res->[2];
    #$log->tracef("children=%s", $self->{_children});

    $res = $self->_pa->request(child_metas=>$self->{url});
    $res->[0] == 200 or die "Can't child_metas $self->{url}: ".
        "$res->[0] - $res->[1]";
    $self->{_child_metas} = $res->[2];
    $self->{_child_orig_metas} = $res->[3]{orig_metas};
    #$log->tracef("child_metas=%s", $self->{_child_metas});

}

1;
# ABSTRACT: Base class for Perinci::To::* package documentation generators
