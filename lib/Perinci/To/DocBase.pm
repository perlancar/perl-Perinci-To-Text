package Perinci::To::DocBase;

use 5.010;
use Log::Any '$log';
use Moo;

has url => (is=>'rw');
has sections => (is=>'rw');
has function_sections => (is => 'rw');
#has method_sections => (is => 'rw');
has lang => (is => 'rw');
has fallback_lang => (is => 'rw');
has mark_fallback_text => (is => 'rw', default=>sub{1});
has _pa => (is => 'rw'); # store Perinci::Access object
has _lines => (is => 'rw'); # store final result, array
has _parse => (is => 'rw'); # store parsed items, hash
has loc_class => (
    is => 'rw',
    default => sub {
        my $self = shift;
        ref($self) . '::I18N';
    },
); # store name of localize (project) class
has lh => (
    is => 'rw',
    lazy => 1,
    default => sub {
        require Module::Load;

        my $self = shift;
        Module::Load::load($self->loc_class);
        my $obj = $self->loc_class->new;
        my $lh = $obj->get_handle($self->lang)
            or die "Can't determine language";
        $lh;
    },
); # store localize handle
has _indent_level => (is => 'rw');
has indent => (is => 'rw', default => sub{"  "}); # indent character

# VERSION

sub BUILD {
    require Perinci::Access;
    require SHARYANTO::Package::Util;

    my ($self, $args) = @_;
    #$self->{url} or die "Please specify url";
    $self->{_pa} //= Perinci::Access->new;
    $self->{sections} //= [
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
    $self->{method_sections} //= $self->{function_sections};
    if (!defined($self->{lang}) && $ENV{LANG}) {
        my $l = $ENV{LANG}; $l =~ s/\W.*//;
        $self->{lang} = $l;
    }
    if (!defined($self->{lang}) && $ENV{LANGUAGE}) {
        my $l = $ENV{LANGUAGE}; $l =~ s/\W.*//;
        $self->{lang} = $l;
    }
    $self->{lang} //= "en_US";
    $self->{fallback_lang} //= "en_US";
}

sub add_section_before {
    my ($self, $name, $before) = @_;
    my $ss = $self->sections;
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

sub add_section_after {
    my ($self, $name, $after) = @_;
    my $ss = $self->sections;
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

sub delete_section {
    my ($self, $name) = @_;
    my $ss = $self->sections;
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

# return single-line dump of data structure, e.g. "[1, 2, 3]" (no trailing
# newlines either).
sub dump_data_sl {
    require Data::Dump::OneLine;

    my ($self, $data) = @_;
    Data::Dump::OneLine::dump1($data);
}

# return a pretty dump of data structure
sub dump_data {
    require Data::Dump;

    my ($self, $data) = @_;
    Data::Dump::dump($data);
}

sub add_lines {
    my $self = shift;
    my $opts;
    if (ref($_[0]) eq 'HASH') { $opts = shift }
    $opts //= {};

    my @lines = map { $_ . (/\n\z/s ? "" : "\n") }
        map {/\n/ ? split /\n/ : $_} @_;

    my $indent = $self->indent x $self->_indent_level;
    push @{$self->_lines},
        map {"$indent$_"} @lines;
}

sub inc_indent {
    my ($self, $n) = @_;
    $n //= 1;
    $self->{_indent_level} += $n;
}

sub dec_indent {
    my ($self, $n) = @_;
    $n //= 1;
    $self->{_indent_level} -= $n;
    die "BUG: Negative indent level" unless $self->{_indent_level} >=0;
}

sub loc {
    my ($self, @args) = @_;
    $self->lh->maketext(@args);
}

sub _trim_blank_lines {
    my $self = shift;
    local $_ = shift;
    return $_ unless defined;
    s/\A(?:\n\s*)+//;
    s/(?:\n\s*){2,}\z/\n/;
    $_;
}

# get text from property of appropriate language. XXX should be moved to
# Perinci-Object later.
sub _get_langprop {
    my ($self, $meta, $prop, $opts) = @_;
    $opts    //= {};
    my $lang   = $self->{lang};
    my $mlang  = $meta->{default_lang} // "en_US";
    my $fblang = $self->{fallback_lang};

    my $v;
    my $x; # x = exists
    if ($lang eq $mlang) {
        $x = exists $meta->{$prop};
        $v = $meta->{$prop};
    } else {
        my $k = "$prop.alt.lang.$lang";
        $x = exists $meta->{$k};
        $v = $meta->{$k};
    }
    $v = $self->_trim_blank_lines($v);
    return $v if $x;

    if ($fblang ne $lang) {
        if ($fblang eq $mlang) {
            $v = $meta->{$prop};
        } else {
            my $k = "$prop.alt.lang.$fblang";
            $v = $meta->{$k};
        }
        $v = $self->_trim_blank_lines($v);
        if (defined($v) && $self->mark_fallback_text) {
            my $has_nl = $v =~ s/\n\z//;
            $v = "{$fblang $v}" . ($has_nl ? "\n" : "");
        }
    }
    $v;
}

sub parse_summary {
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
        $name = $self->_get_langprop($self->{_meta}, "name");
        $summary = $self->_get_langprop($self->{_meta}, "summary");
    }
    $name //= $modname;
    $summary = "";

    $self->{_parse}{name}    = $name;
    $self->{_parse}{summary} = $summary;
}

sub gen_summary {}

sub parse_version {
    # already in meta's pkg_version
}

sub gen_version {}

sub parse_description {
    my ($self) = @_;

    $self->{_parse}{description} = $self->{_meta} ?
        $self->_get_langprop($self->{_meta}, "description",
                             {trim_blank_lines=>1}) : undef;
}

sub gen_description {}

sub fparse_summary {
    my ($self) = @_;
    my $p = $self->_parse->{functions}{ $self->{_furl} };

    my $name = $self->_get_langprop($self->{_fmeta}, "name");
    if (!$name) {
        $self->{_furl} =~ m!.+/(.+)!;
        $name = $1;
    }
    my $summary = $self->_get_langprop($self->{_fmeta}, "summary");
    $p->{name}    = $name;
    $p->{summary} = $summary;
}

sub fgen_summary {}

sub fparse_description {
}

sub fgen_description {}

# XXX generate human-readable short description of schema, this will be
# handled in the future by Sah itself (using the human compiler)
sub _sah2human {
    require Data::Sah;
    require List::MoreUtils;

    my ($self, $s) = @_;
    if ($s->[0] eq 'any') {
        my @alts    = map {Data::Sah::normalize_schema($_)}
            @{$s->[1]{of} // []};
        my @types   = map {$_->[0]} @alts;
        @types      = sort List::MoreUtils::uniq(@types);
        return join("|", @types) || 'any';
    } else {
        return $s->[0];
    }
}

sub fparse_arguments {
    my ($self) = @_;
    my $p     = $self->_parse->{functions}{ $self->{_furl} };
    my $fmeta = $self->{_fmeta};

    my $aa = $fmeta->{args_as};
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
        $pa->{human_arg} = $self->_sah2human($s);
        if (defined $s->[1]{default}) {
            $pa->{human_arg_default} = $self->dump_data_sl($s->[1]{default});
        }
        $pa->{summary}     = $self->_get_langprop($arg, 'summary');
        $pa->{description} = $self->_get_langprop($arg, 'description',
                                              {trim_blank_lines=>1});
    }
}

sub fgen_arguments {}

sub fparse_examples {
}

sub fgen_examples {}

sub fparse_result {
    my ($self) = @_;
    my $p     = $self->_parse->{functions}{ $self->{_furl} };
    my $fmeta = $self->{_fmeta};

    $p->{res_schema} = $fmeta->{result} ? $fmeta->{result}{schema} : undef;
    $p->{res_schema} //= [any => {}];
    $p->{human_res} = $self->_sah2human($p->{res_schema});

    if ($fmeta->{result_naked}) {
        $p->{human_ret} = $p->{human_res};
    } else {
        $p->{human_ret} = '[status, msg, result, meta]';
    }

    $p->{summary}     = $self->_get_langprop($fmeta, "summary");
    $p->{description} = $self->_get_langprop($fmeta, "description");
}

sub fgen_result {}

sub fparse_links {
}

sub fgen_links {}

sub _parse_function {
    my ($self, $url) = @_;

    my $fmeta;
    my $found;
    {
        if ($self->{_child_metas}) {
            if ($fmeta = $self->{_child_metas}{$url}) {
                $found++;
                last;
            }
        }

        my $res = $self->_pa->request(meta => $url);
        $res->[0] == 200 or die "Can't meta $self->{url}: ".
            "$res->[0] - $res->[1]";
        $fmeta = $res->[2];
        $found++;
        last;
    }
    die "BUG: Didn't find function metadata" unless $found;
    $self->{_furl} = $url;
    $self->{_fmeta} = $fmeta;

    $self->_parse->{functions}{$url} = {meta=>$fmeta};
    for my $s (@{ $self->function_sections // [] }) {
        my $meth = "fparse_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
    }
}

sub _gen_function {
    my ($self, $url, %opts) = @_;
    $log->tracef("-> _gen_function(url=%s, opts=%s)", $url, \%opts);

    my $p = $self->_parse->{functions}{$url};
    for my $s (@{ $self->function_sections // [] }) {
        my $meth = "fgen_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
    }
}

sub parse_functions {
    my ($self) = @_;

    for my $e (@{ $self->{_children} }) {
        next unless $e->{type} eq 'function';
        $self->_parse_function($e->{uri});
    }
}

sub gen_functions {
    my ($self) = @_;

    for my $e (@{ $self->{_children} }) {
        next unless $e->{type} eq 'function';
        $self->_gen_function($e->{uri});
    }
}

sub parse_links {
}

sub gen_links {}

sub generate {
    my ($self, %opts) = @_;
    $log->tracef("-> generate(opts=%s), lang=%s", \%opts, $self->lang);

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
        #$log->tracef("meta=%s", $self->{_meta});
    }

    $res = $self->_pa->request(list=>$self->{url}, {detail=>1});
    $res->[0] == 200 or die "Can't list $self->{url}: $res->[0] - $res->[1]";
    $self->{_children} = $res->[2];
    #$log->tracef("children=%s", $self->{_children});

    $res = $self->_pa->request(child_metas=>$self->{url});
    $res->[0] == 200 or die "Can't child_metas $self->{url}: ".
        "$res->[0] - $res->[1]";
    $self->{_child_metas} = $res->[2];
    #$log->tracef("child_metas=%s", $self->{_child_metas});

    $self->_lines([]);
    $self->_indent_level(0);
    $self->_parse({});
    for my $s (@{ $self->sections // [] }) {
        my $meth = "parse_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
        $meth = "gen_$s";
        $log->tracef("=> $meth()");
        $self->$meth;
    }

    $log->tracef("<- generate()");
    join("", @{ $self->_lines });
}

1;
#ABSTRACT: Base class for class that generates documentation from Rinci metadata

=for Pod::Coverate ^section_ ^parse_

=head1 DESCRIPTION

DocBase is the base class for classes that produce documentation from Rinci
metadata. It provides i18n class using L<Locale::Maketext>
(L<Perinci::To::DocBase::I18N>) and you can access the language handle at
$self->lh.

To generate a documentation, first you provide a list of section names in
C<sections>. Then you run C<generate()>, which will call C<parse_SECTION> and
C<gen_SECTION> methods for each section consecutively. C<parse_*> is supposed to
parse information from the metadata into a form readily usable in $self->_parse
hash. C<gen_*> is supposed to generate the actual section in the final
documentation format, by calling C<add_lines> to add text. The base class
provides many of the C<parse_*> methods but provides none of the C<gen_*>
methods, which must be supplied by subclasses like L<Perinci::To::Text>,
L<Perinci::To::POD>, L<Perinci::To::HTML>. Finally all the added lines is
concatenated together and returned.

=cut
