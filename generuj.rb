require "kramdown"
require "cgi"
require "fileutils"

FileUtils.mkdir_p("posty")

szablon = File.read("szablon.html", encoding: "UTF-8")

# Zamiana wszystkich plików Markdown na HTML
pliki_md = Dir.glob("posty/*.md")

pliki_md.each do |plik_md|
  nazwa = File.basename(plik_md, ".md")
  plik_html = "posty/#{nazwa}.html"

  markdown = File.read(plik_md, encoding: "UTF-8")
  linie = markdown.lines

  # Pierwszy nagłówek Markdown staje się tytułem wpisu
  linia_tytulu = linie.find { |linia| linia.match?(/\A#\s+/) }

  if linia_tytulu
    tytul = linia_tytulu.sub(/\A#\s+/, "").strip

    # Nie pokazujemy tego samego nagłówka drugi raz w treści
    linie.delete(linia_tytulu)
  else
    tytul = nazwa
  end

  tresc_markdown = linie.join

  # Konwersja Markdown -> HTML
  tresc_html = Kramdown::Document
    .new(tresc_markdown)
    .to_html

  html = szablon
    .gsub("{{TYTUL_STRONY}}", CGI.escapeHTML(tytul))
    .gsub("{{TRESC}}") { tresc_html }

  File.write(plik_html, html, encoding: "UTF-8")

  puts "Wygenerowano: #{plik_html}"
end

# Pobieramy wszystkie gotowe strony HTML
posty = Dir.glob("posty/*.html").sort.reverse

lista = posty.map do |plik_html|
  nazwa = File.basename(plik_html, ".html")
  plik_md = "posty/#{nazwa}.md"

  # Tytuł do listy pobieramy z pierwszego nagłówka Markdown
  if File.exist?(plik_md)
    markdown = File.read(plik_md, encoding: "UTF-8")

    tytul = markdown.lines
      .find { |linia| linia.match?(/\A#\s+/) }
      &.sub(/\A#\s+/, "")
      &.strip
  end

  # Dla starych plików HTML używamy nazwy pliku
  tytul ||= nazwa

  "<li><a href='#{plik_html}'>#{CGI.escapeHTML(tytul)}</a></li>"
end.join

index = <<~HTML
<!doctype html>
<html lang="pl">
<head>
    <meta charset="utf-8">
    <title>Tsuki Blog - Strona Główna</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="kontener">
        <h1>Tsuki Blog</h1>
        <ul>
            #{lista}
        </ul>
    </div>
</body>
</html>
HTML

File.write("index.html", index, encoding: "UTF-8")

puts "Strona główna zaktualizowana!"
