package Perinci::To::PackageBase::I18N::en;
use base 'Perinci::To::PackageBase::I18N';

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: English translation for Perinci::To::PackageBase
__DATA__
msgid  "Function"
msgstr "Function"

msgid  "Functions"
msgstr "Functions"

msgid  "General functions"
msgstr "General functions"

msgid  "Functions related to '%1'"
msgstr "Functions related to '%1'"

msgid  "Variable"
msgstr "Variable"

msgid  "Variables"
msgstr "Variables"

msgid  "General variables"
msgstr "General variables"

msgid  "Variables related to '%1'"
msgstr "Variables related to '%1'"

msgid  "Method"
msgstr "Method"

msgid  "Methods"
msgstr "Methods"

msgid  "General methods"
msgstr "General methods"

msgid  "Methods related to '%1'"
msgstr "Methods related to '%1'"

msgid  "Attribute"
msgstr "Attribute"

msgid  "Attributes"
msgstr "Attributes"

msgid  "General attributes"
msgstr "General attributes"

msgid  "Attributes related to '%1'"
msgstr "Attributes related to '%1'"

msgid  "Subpackages"
msgstr "Subpackages"

msgid  "Name"
msgstr "Name"

msgid  "Summary"
msgstr "Summary"

msgid  "Version"
msgstr "Version"

msgid  "Description"
msgstr "Description"

msgid  "Examples"
msgstr "Examples"

msgid  "See Also"
msgstr "See Also"

msgid  "Links"
msgstr "Links"

msgid  "Tags"
msgstr "Tags"

msgid  "Categories"
msgstr "Categories"

msgid  "Category"
msgstr "Category"

msgid  "This package does not have functions"
msgstr "This package does not have functions"

msgid  "This package does not have variables"
msgstr "This package does not have variables"

msgid  "This class does not add any method of its own"
msgstr "This class does not add any method of its own"

msgid  "This class does not add any attribute of its own"
msgstr "This class does not add any attribute of its own"

msgid  "Methods from superclass '%1'"
msgstr "Methods from superclass '%1'"

msgid  "Attributes from superclass '%1'"
msgstr "Attributes from superclass '%1'"

