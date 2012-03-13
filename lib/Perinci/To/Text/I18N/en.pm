package Perinci::To::Text::I18N::en;
use parent qw(Perinci::To::Text::I18N Perinci::To::DocBase::I18N::en);

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: English translation for Perinci::To::Text
__DATA__
