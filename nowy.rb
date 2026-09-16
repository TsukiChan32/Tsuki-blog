require "date"
require "fileutils"

tytul = ARGV.join(" ").strip

if tytul.empty?
  puts 'Podaj tytuł, na przykład: ruby nowy.rb "Mój nowy wpis"'
  exit 1
end

FileUtils.mkdir_p("posty")

data = Date.today.strftime("%Y-%m-%d")

slug = tytul
  .downcase
  .gsub(/[^\p{L}\p{N}]+/u, "-")
  .gsub(/\A-+|-+\z/, "")

plik = "posty/#{data}-#{slug}.md"

if File.exist?(plik)
  puts "Taki plik już istnieje: #{plik}"
  exit 1
end

tresc = <<~MARKDOWN
# #{tytul}

Tutaj wpisz swoją treść.

Możesz używać **pogrubienia**, *kursywy*, linków i list.

MARKDOWN

File.write(plik, tresc, encoding: "UTF-8")

puts "Utworzyłam plik: #{plik}"
