#!perl

use 5.010;
use strict;
use warnings;

use Test::More 0.96;

use Perinci::To::Text;

my $doc = Perinci::To::Text->new(url => '/Perinci/Examples/');

$doc->sections([qw/a b c/]);
$doc->add_section_before('j', 'a');
is_deeply($doc->sections, [qw/j a b c/], 'add_section_before (1)')
    or diag explain $doc->sections;
$doc->add_section_before('k', 'a');
is_deeply($doc->sections, [qw/j k a b c/], 'add_section_before (2)')
    or diag explain $doc->sections;
$doc->add_section_before('l', 'z');
is_deeply($doc->sections, [qw/l j k a b c/], 'add_section_before (3)')
    or diag explain $doc->sections;

$doc->sections([qw/a b c/]);
$doc->add_section_after('j', 'c');
is_deeply($doc->sections, [qw/a b c j/], 'add_section_after (1)')
    or diag explain $doc->sections;
$doc->add_section_after('k', 'c');
is_deeply($doc->sections, [qw/a b c k j/], 'add_section_after (2)')
    or diag explain $doc->sections;
$doc->add_section_after('l', 'z');
is_deeply($doc->sections, [qw/a b c k j l/], 'add_section_after (3)')
    or diag explain $doc->sections;

$doc->function_sections([qw/a b c/]);
$doc->add_function_section_before('j', 'a');
is_deeply($doc->function_sections, [qw/j a b c/], 'add_function_section_before (1)')
    or diag explain $doc->function_sections;
$doc->add_function_section_before('k', 'a');
is_deeply($doc->function_sections, [qw/j k a b c/], 'add_function_section_before (2)')
    or diag explain $doc->function_sections;
$doc->add_function_section_before('l', 'z');
is_deeply($doc->function_sections, [qw/l j k a b c/], 'add_function_section_before (3)')
    or diag explain $doc->function_sections;

$doc->function_sections([qw/a b c/]);
$doc->add_function_section_after('j', 'c');
is_deeply($doc->function_sections, [qw/a b c j/], 'add_function_section_after (1)')
    or diag explain $doc->function_sections;
$doc->add_function_section_after('k', 'c');
is_deeply($doc->function_sections, [qw/a b c k j/], 'add_function_section_after (2)')
    or diag explain $doc->function_sections;
$doc->add_function_section_after('l', 'z');
is_deeply($doc->function_sections, [qw/a b c k j l/], 'add_function_section_after (3)')
    or diag explain $doc->function_sections;

$doc->sections([qw/a b c/]);
$doc->delete_section('a');
is_deeply($doc->sections, [qw/b c/], 'delete_section (1)');
$doc->delete_section('c');
is_deeply($doc->sections, [qw/b/], 'delete_section (2)');
$doc->delete_section('a');
is_deeply($doc->sections, [qw/b/], 'delete_section (3)');

$doc->function_sections([qw/a b c/]);
$doc->delete_function_section('a');
is_deeply($doc->function_sections, [qw/b c/], 'delete_function_section (1)');
$doc->delete_function_section('c');
is_deeply($doc->function_sections, [qw/b/], 'delete_function_section (2)');
$doc->delete_function_section('a');
is_deeply($doc->function_sections, [qw/b/], 'delete_function_section (3)');

done_testing();
