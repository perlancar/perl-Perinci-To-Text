package Perinci::To::DocBase;

use 5.010;
use Log::Any '$log';
use Moo;

# VERSION

has url => (is=>'rw');
has sections => (is=>'rw');
has function_sections => (is => 'rw');
has method_sections => (is => 'rw');
has lang => (is => 'rw');
has fallback_lang => (is => 'rw');
has _pa => (is => 'rw'); # store Perinci::Access object
has _result => (is => 'rw'); # store final result, array
has _parse => (is => 'rw'); # store parsed items, hash
has _lh => (is => 'rw'); # store localize handle

sub BUILD {
    require Module::Load;
    require Perinci::Access;
    require SHARYANTO::Package::Util;

    my ($self, $args) = @_;
    $self->{url} or die "Please specify url";
    $self->{_pa} //= Perinci::Access->new;
    $self->{sections} //= [
        'summary',
        'description',
        'functions',
        #'methods',
    ];
    $self->{function_sections} //= [
        'summary',
        'description',
        'arguments',
        'examples',
        'links',
    ];
    $self->{method_sections} //= $self->{function_sections};
    $self->{lang} //= "en_US";
    $self->{fallback_lang} //= "en_US";

    my $class = ref($self) . '::I18N';
    $class = __PACKAGE__.'::I18N'
        unless SHARYANTO::Package::Util::package_exists($class);
    Module::Load::load $class;
    $self->{_loc_class} = $class;
    $self->{_loc_obj}   = $class->new;
    $self->{_lh}        = $self->{_loc_obj}->get_handle($self->lang)
        or die "Can't determine language";
}

#sub add_section {
#    my ($self, $name, $after) = @_;
#}

#sub delete_section {
#    my ($self, $name) = @_;
#}

sub add_result {
    my ($self, @e) = @_;
    push @{$self->_result}, @e;
}

# get text from property of appropriate language. XXX should be moved to
# Perinci-Object later.
sub _get_langprop {
    my ($self, $meta, $prop) = @_;
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
    return $v if $x;

    if ($fblang ne $lang) {
        if ($fblang eq $mlang) {
            $v = $meta->{$prop};
        } else {
            my $k = "$prop.alt.lang.$fblang";
            $v = $meta->{$k};
        }
    }
    $v;
}

sub parse_summary {
    my ($self) = @_;

    my $name    = $self->_get_langprop($self->{_meta}, "name");
    if (!$name) {
        $name = $self->{_info}{uri};
        $name =~ s!^pm:/!!;
        $name =~ s!/$!!;
        $name =~ s!/!::!g;
    }
    my $summary = $self->_get_langprop($self->{_meta}, "summary");

    $self->{_parse}{name} = $name;
    $self->{_parse}{summary} = $summary;
}

sub gen_summary {}

sub parse_description {
}

sub gen_description {}

sub parse_functions {
    my ($self) = @_;
}

sub gen_functions {}

sub parse_links {
}

sub gen_links {}

sub fparse_summary {
}

sub fgen_summary {}

sub fparse_description {
}

sub fgen_description {}

sub fparse_arguments {
}

sub fgen_arguments {}

sub fparse_examples {
}

sub fgen_examples {}

sub fparse_links {
}

sub fgen_links {}

sub generate_function {
    my ($self, $name, %opts) = @_;
    $log->tracef("-> generate_function(name=%s, opts=%s)", $name, \%opts);

    $self->{_parse}{function} = {};

    $log->tracef("<- generate_function()");
}

sub generate {
    my ($self, %opts) = @_;
    $log->tracef("-> generate(opts=%s)", \%opts);

    # let's retrieve the metadatas first

    my $res = $self->_pa->request(info=>$self->{url});
    $res->[0] == 200 or die "Can't info $self->{url}: $res->[0] - $res->[1]";
    $self->{_info} = $res->[2];
    #$log->tracef("info=%s", $self->{_info});

    $res = $self->_pa->request(meta=>$self->{url});
    $res->[0] == 200 or die "Can't meta $self->{url}: $res->[0] - $res->[1]";
    $self->{_meta} = $res->[2];
    #$log->tracef("meta=%s", $self->{_meta});

    $res = $self->_pa->request(list=>$self->{url}, {detail=>1});
    $res->[0] == 200 or die "Can't list $self->{url}: $res->[0] - $res->[1]";
    $self->{_children} = $res->[2];
    #$log->tracef("entities=%s", $self->{_entities});

    $res = $self->_pa->request(child_metas=>$self->{url});
    $res->[0] == 200 or die "Can't child_metas $self->{url}: ".
        "$res->[0] - $res->[1]";
    $self->{_child_metas} = $res->[2];
    #$log->tracef("child_metas=%s", $self->{_child_metas});

    $self->_result([]);
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
    join("", @{ $self->_result });
}

1;
#ABSTRACT: Base class for class that generates documentation from Rinci metadata

=for Pod::Coverate ^section_ ^parse_

=head1 DESCRIPTION

DocBase is the base class for classes that produce documentation from Rinci
metadata. It provides i18n class using L<Locale::Maketext>
(L<Perinci::To::DocBase::I18N>) and you can access the language handle at
$self->_lh.

To generate a documentation, first you provide a list of section names in
C<sections>. Then you run C<generate()>, which will call C<parse_SECTION> and
C<gen_SECTION> methods for each section consecutively. C<parse_*> is supposed to
parse information from the metadata into a form readily usable in $self->_parse
hash. C<gen_*> is supposed to generate the actual section in the final
documentation format, into $self->_result array. The base class provides many of
the C<parse_*> methods but provides none of the C<gen_*> methods, which must be
supplied by subclasses like L<Perinci::To::Text>, L<Perinci::To::POD>,
L<Perinci::To::HTML>. Finally strings in $self->_result is concatenated together
and returned.

=cut
