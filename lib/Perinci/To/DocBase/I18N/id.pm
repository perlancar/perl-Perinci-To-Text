package Perinci::To::DocBase::I18N::id;
use base 'Perinci::To::DocBase::I18N';

use Locale::Maketext::Lexicon::Gettext;
our %Lexicon = %{ Locale::Maketext::Lexicon::Gettext->parse(<DATA>) };

#use Data::Dump; dd \%Lexicon;

1;
# ABSTRACT: Indonesian translation for Perinci::To::* document generators
__DATA__
msgid  "Functions"
msgstr "Fungsi"

msgid  "Variables"
msgstr "Variabel"

msgid  "Name"
msgstr "Nama"

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

### Text::Usage
msgid  "Show version"
msgstr "Tampilkan versi"

msgid  "Display this help message"
msgstr "Tampilkan pesan bantuan ini"

msgid  "List available subcommands"
msgstr "Daftar subperintah yang ada"

### POD

msgid  "This module has L<Rinci> metadata"
msgid  "Modul ini dilengkapi metadata L<Rinci>"

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

msgid  "'*' denotes required arguments"
msgstr "'*' menandakan argumen wajib"

msgid  "Result"
msgstr "Hasil"

msgid  "Return value"
msgstr "Nilai kembali"

msgid  "Returns an enveloped result (an array). First element ($status) is HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element ($msg) is error message, or 'OK' if status is 200. Third element ($result) is the actual result. Fourth element ($meta) is called result metadata and is optional, hash that contains extra information."
msgid  "Mengembalikan hasil terbungkus (larik). Elemen pertama ($status) berisi kode status HTTP (200 berarti OK, 4xx kesalahan di pemanggil, 5xx kesalahan di fungsi). Elemen kedua ($msg) adalah pesan kesalahan, atau 'OK' jika status 200. Elemen ketiga ($result) berisi hasil yang diinginkan. Elemen keempat ($meta) disebut metadata hasil, bersifat opsional, berupa hash informasi tambahan."

### function/Text::Usage

msgid  "or as argument #%1"
msgstr "atau sebagai argumen #%1"

### function/POD

msgid  "None are exported by default, but they are exportable."
msgstr "Tidak ada yang diekspor secara otomatis, tapi dapat diekspor."

# function features

msgid  "This function supports undo operation. Please read 'The undo protocol' in Rinci::function specification."
msgstr "Fungsi ini mendukung operasi undo (pembatalan). Silakan baca 'The undo protocol' di spesifikasi Rinci::function."

msgid  "This function is declared as %1 (%2). Please read the '%1' feature in Rinci::function specification."
msgid  "Fungsi ini dideklarasikan %1 (%2). Silakan baca fitur '%1' di spesifikasi Rinci::function."

