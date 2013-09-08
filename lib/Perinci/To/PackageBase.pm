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
has _pa => (
    is => 'rw',
    lazy => 1,
    default => sub {
        require Perinci::Access;
        require Perinci::Access::Perl;
        my $pa = Perinci::Access->new;
        # slightly reduce startup overhead by avoiding to compile sah schemas
        my $pap = Perinci::Access::Perl->new(
            extra_wrapper_args => {
                validate_args => 0,
            },
        );
        $pa->{handlers}{pl} = $pap;
        delete $pa->{handlers}{''};
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
}

sub before_gen_doc {
    my ($self, %opts) = @_;
    $log->tracef("=> PackageBase's before_gen_doc(opts=%s)", \%opts);

    # initialize hash to store [intermediate] result
    $self->{_doc_res} = {};

    # let's retrieve the metadatas first

    my $res = $self->_pa->request(info=>$self->{url});
    $res->[0] == 200 or die "Can't info $self->{url}: $res->[0] - $res->[1]";
    $self->{_doc_info} = $res->[2];
    #$log->tracef("info=%s", $self->{_doc_info});

    die "url must be a package entity, not $self->{_doc_info}{type} ($self->{url})"
        unless $self->{_doc_info}{type} eq 'package';

    $res = $self->_pa->request(meta=>$self->{url});
    if ($res->[0] == 200) {
        $self->{_doc_meta} = $res->[2];
        $self->{_doc_orig_meta} = $res->[3]{orig_meta};
        #$log->tracef("meta=%s", $self->{_doc_meta});
        #$log->tracef("orig_meta=%s", $self->{_doc_orig_meta});
    }

    $res = $self->_pa->request(list=>$self->{url}, {detail=>1});
    $res->[0] == 200 or die "Can't list $self->{url}: $res->[0] - $res->[1]";
    $self->{_doc_children} = $res->[2];
    #$log->tracef("children=%s", $self->{_doc_children});

    $res = $self->_pa->request(child_metas=>$self->{url});
    $res->[0] == 200 or die "Can't child_metas $self->{url}: ".
        "$res->[0] - $res->[1]";
    $self->{_doc_child_metas} = $res->[2];
    $self->{_doc_child_orig_metas} = $res->[3]{orig_metas};
    #$log->tracef("child_metas=%s", $self->{_doc_child_metas});

}

# provide simple default implementation without any text wrapping. subclass such
# as Perinci::To::Text will use another implementation, one that supports text
# wrapping for example (provided by
# SHARYANTO::Role::Doc::Section::AddTextLines).
sub add_doc_lines {
    my $self = shift;
    my $opts;
    if (ref($_[0]) eq 'HASH') { $opts = shift }
    $opts //= {};

    my @lines = map { $_ . (/\n\z/s ? "" : "\n") }
        map {/\n/ ? split /\n/ : $_} @_;

    my $indent = $self->doc_indent_str x $self->doc_indent_level;
    push @{$self->doc_lines},
        map {"$indent$_"} @lines;
}

sub gen_doc_section_summary {
    my ($self) = @_;

    my ($name, $summary);

    my $modname;
    for ($modname) {
        $_ = $self->{_doc_info}{uri};
        s!^pl:/!!;
        s!/$!!;
        s!/!::!g;
    }

    if ($self->{_doc_meta}) {
        $name    = $self->langprop($self->{_doc_meta}, "name");
        $summary = $self->langprop($self->{_doc_meta}, "summary");
    }
    $name //= $modname;
    $summary = "";

    $self->{_doc_res}{name}    = $name;
    $self->{_doc_res}{summary} = $summary;
}

sub gen_doc_section_version {
}

sub gen_doc_section_description {
    my ($self) = @_;

    $self->{_doc_res}{description} = $self->{_doc_meta} ?
        $self->langprop($self->{_doc_meta}, "description") : undef;
}

sub gen_doc_section_functions {
    require Perinci::Sub::To::FuncBase;

    my ($self) = @_;

    # subclasses should override this method and provide the appropriate
    # Perinci::Sub::To::* object in _fgen.
    $self->{_doc_fgen} //= Perinci::Sub::To::FuncBase->new(
        _pa => $self->_pa, # to avoid multiple instances of pa objects
    );

    # list all functions
    my @func_uris = map { $_->{uri} }
        grep { $_->{type} eq 'function' } @{ $self->{_doc_children} // []};

    # generate doc for all functions
    my $fgen = $self->{_doc_fgen};
    $self->{_doc_res}{functions} = {};
    for my $furi (@func_uris) {
        $fgen->url($furi);
        if ($self->{_doc_child_metas}) {
            # avoid calling meta on furi again by fgen, since we have the meta
            # already in _child_metas.
            $fgen->{_doc_meta}      = $self->{_doc_child_metas}{$furi};
            $fgen->{_doc_orig_meta} = $self->{_doc_child_orig_metas}{$furi};
        }
        $fgen->gen_doc();
        $self->{_doc_res}{functions}{$furi} = $fgen->doc_lines;
    }
}

sub gen_doc_section_links {
}

1;
# ABSTRACT: Base class for Perinci::To::* package documentation generators

=for Pod::Coverage .+
