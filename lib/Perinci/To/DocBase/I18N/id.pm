package Perinci::To::DocBase::I18N::id;
use base 'Perinci::To::DocBase::I18N';

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

# VERSION

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: Indonesian translation for Perinci::To::DocBase
__DATA__
msgid  "Function"
msgstr "Fungsi"

msgid  "Functions"
msgstr "Fungsi"

msgid  "General functions"
msgstr "Fungsi umum"

msgid  "Functions related to '%1'"
msgstr "Fungsi yang berkaitan dengan '%1'"

msgid  "Variable"
msgstr "Variabel"

msgid  "Variables"
msgstr "Variabel"

msgid  "General variables"
msgstr "Variabel umum"

msgid  "Variables related to '%1'"
msgstr "Variabel yang berkaitan dengan '%1'"

msgid  "Method"
msgstr "Metode"

msgid  "Methods"
msgstr "Metode"

msgid  "General methods"
msgstr "Metode umum"

msgid  "Methods related to '%1'"
msgstr "Metode yang berkaitan dengan '%1'"

msgid  "Attribute"
msgstr "Atribut"

msgid  "Attributes"
msgstr "Atribut"

msgid  "General attributes"
msgstr "Atribut umum"

msgid  "Attributes related to '%1'"
msgstr "Atribut yang berkaitan dengan '%1'"

msgid  "Subpackages"
msgstr "Subpaket"

msgid  "Name"
msgstr "Nama"

msgid  "Version"
msgstr "Versi"

msgid  "Summary"
msgstr "Ringkasan"

msgid  "Description"
msgstr "Deskripsi"

msgid  "Examples"
msgstr "Contoh"

msgid  "See Also"
msgstr "Lihat Juga"

msgid  "Links"
msgstr "Tautan"

msgid  "Tags"
msgstr "Tag"

msgid  "Categories"
msgstr "Kategori"

msgid  "Category"
msgstr "Kategori"

msgid  "This package does not have functions"
msgstr "Paket ini tidak memiliki fungsi"

msgid  "This package does not have variables"
msgstr "Paket ini tidak memiliki variabel"

msgid  "This class does not add any method of its own"
msgstr "Kelas ini tidak menambahkan metode apa-apa"

msgid  "This class does not add any attribute of its own"
msgstr "Kelas ini tidak menambahkan atribut apa-apa"

msgid  "Methods from superclass '%1'"
msgstr "Metode dari kelas induk '%1'"

msgid  "Attributes from superclass '%1'"
msgstr "Atribut dari kelas induk '%1'"

# tmp: Sah

msgid  "default"
msgstr "bawaan"

msgid  "value in"
msgstr "nilai antara"

msgid  "required"
msgstr "wajib"

msgid  "optional"
msgstr "opsional"

msgid  "minimum"
msgstr "minimum"

msgid  "maximum"
msgstr "maksimum"

msgid  "less than"
msgstr "kurang dari"

msgid  "greater than"
msgstr "lebih dari"

msgid  "between %1 and %2"
msgstr "antara %1 dan %2"

msgid  "between %1 and %2 (exclusive)"
msgstr "antara %1 dan %2 (tidak termasuk ujung)"

# function

msgid  "Arguments"
msgstr "Argumen"

msgid  "General arguments"
msgstr "Argumen umum"

msgid  "Arguments related to '%1'"
msgstr "Argumen yang berkaitan dengan '%1'"

msgid  "'*' denotes required arguments"
msgstr "'*' menandakan argumen wajib"

msgid  "Result"
msgstr "Hasil"

msgid  "Return value"
msgstr "Nilai kembali"

msgid  "Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information."
msgstr "Mengembalikan hasil terbungkus (larik). Elemen pertama (status) adalah bilangan bulat berisi kode status HTTP (200 berarti OK, 4xx kesalahan di pemanggil, 5xx kesalahan di fungsi). Elemen kedua (msg) adalah string berisi pesan kesalahan, atau 'OK' jika status 200. Elemen ketiga (result) bersifat opsional, berisi hasil yang diinginkan. Elemen keempat (meta) disebut metadata hasil, bersifat opsional, berupa hash informasi tambahan."

# function features

msgid  "This function supports undo operation. Please read 'The undo protocol' in Rinci::function specification."
msgstr "Fungsi ini mendukung operasi undo (pembatalan). Silakan baca 'The undo protocol' di spesifikasi Rinci::function."

msgid  "This function is declared as %1 (%2). Please read the '%1' feature in Rinci::function specification."
msgid  "Fungsi ini dideklarasikan %1 (%2). Silakan baca fitur '%1' di spesifikasi Rinci::function."

