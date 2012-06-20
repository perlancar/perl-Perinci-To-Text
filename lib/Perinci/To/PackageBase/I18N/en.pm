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

# tmp: Sah

msgid  "default"
msgstr "default"

msgid  "value in"
msgstr "value in"

msgid  "required"
msgstr "required"

msgid  "optional"
msgstr "optional"

msgid  "minimum"
msgstr "minimum"

msgid  "maximum"
msgstr "maximum"

msgid  "less than"
msgstr "less than"

msgid  "greater than"
msgstr "greater than"

msgid  "between %1 and %2"
msgstr "between %1 and %2"

msgid  "between %1 and %2 (exclusive)"
msgstr "between %1 and %2 (exclusive)"

# function

msgid  "Arguments"
msgstr "Arguments"

msgid  "General arguments"
msgstr "General arguments"

msgid  "Arguments related to '%1'"
msgstr "Arguments related to '%1'"

msgid  "'*' denotes required arguments"
msgstr "'*' denotes required arguments"

msgid  "Result"
msgstr "Result"

msgid  "Return value"
msgstr "Return value"

msgid  "Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information."
msgstr "Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information."

# function features

# OLD
#msgid  "This function supports undo operation. Please read 'The undo protocol' in Rinci::function specification."
#msgstr "This function supports undo operation. Please read 'The undo protocol' in Rinci::function specification."

# OLD
#msgid  "This function is declared as %1 (%2). Please read the '%1' feature in Rinci::function specification."
#msgid  "This function is declared as %1 (%2). Please read the '%1' feature in Rinci::function specification."

msgid  "This function supports reverse operation."
msgstr "This function supports reverse operation."

msgid  "This function supports undo operation."
msgstr "This function supports undo operation."

msgid  "This function supports dry-run operation."
msgstr "This function supports dry-run operation."

msgid  "This function is pure (produce no side effects)."
msgstr "This function is pure (produce no side effects)."

msgid  "This function is immutable (returns same result for same arguments)."
msgstr "This function is immutable (returns same result for same arguments)."

msgid  "This function is idempotent (repeated invocations with same arguments has the same effect as single invocation)."
msgstr "This function is idempotent (repeated invocations with same arguments has the same effect as single invocation)."

msgid  "This function requires transactions."
msgstr "This function requires transactions."

msgid  "This function can use transactions."
msgstr "This function can use transactions."

msgid  "This function can start a new transaction."
msgstr "This function can start a new transaction."

msgid  "This function can end (commit) transactions."
msgstr "This function can end (commit) transactions."

# test multiline

msgid  ""
"Line 1"
"Line 2"
msgstr ""
"Line 1"
"Line 2"
