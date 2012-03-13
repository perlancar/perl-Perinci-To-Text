package Perinci::To::Text::I18N::id;
use parent qw(Perinci::To::Text::I18N Perinci::To::DocBase::I18N::id);

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: Indonesian translation for Perinci::To::Text
__DATA__
