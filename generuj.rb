require "kramdown"
require "cgi"
require "fileutils"
require "date"

FileUtils.mkdir_p("posty")

def sformatuj_date(nazwa_pliku)
  data = nazwa_pliku[0, 10]

  Date.strptime(data, "%Y-%m-%d").strftime("%d.%m.%Y")
rescue ArgumentError
  ""
end

szablon = File.read("szablon.html", encoding: "UTF-8")

# Zamiana wszystkich plików Markdown na HTML
pliki_md = Dir.glob("posty/*.md")

pliki_md.each do |plik_md|
  nazwa = File.basename(plik_md, ".md")
  data = sformatuj_date(nazwa)
  plik_html = "posty/#{nazwa}.html"

  markdown = File.read(plik_md, encoding: "UTF-8")
  linie = markdown.lines

  # Pierwszy nagłówek Markdown staje się tytułem wpisu
  linia_tytulu = linie.find do |linia|
    linia.match?(/\A#\s+/)
  end

  if linia_tytulu
    tytul = linia_tytulu.sub(/\A#\s+/, "").strip

    # Usuwamy pierwszy nagłówek,
    # żeby nie pojawił się drugi raz w treści
    linie.delete(linia_tytulu)
  else
    tytul = nazwa
  end

  tresc_markdown = linie.join

  # Konwersja Markdown na HTML
  tresc_html = Kramdown::Document
    .new(tresc_markdown)
    .to_html

  html = szablon
    .gsub("{{TYTUL_STRONY}}", CGI.escapeHTML(tytul))
    .gsub("{{DATA}}", CGI.escapeHTML(data))
    .gsub("{{TRESC}}") { tresc_html }

  File.write(plik_html, html, encoding: "UTF-8")

  puts "Wygenerowano: #{plik_html}"
end

# Pobieramy wszystkie gotowe strony HTML
wszystkie_posty = Dir.glob("posty/*.html").sort.reverse

# Przypięty wpis "About me"
# Kod szuka pliku zaczynającego się od tej daty
przypiety_post = wszystkie_posty.find do |plik|
  File.basename(plik).start_with?("2026-09-16-welcome-to-my-blog.html")
end

# Najpierw wpis przypięty, potem pozostałe wpisy
posty = wszystkie_posty.reject do |plik|
  plik == przypiety_post
end

posty.unshift(przypiety_post) if przypiety_post

# Tworzenie listy wpisów na stronie głównej
lista = posty.map do |plik_html|
  nazwa = File.basename(plik_html, ".html")
  plik_md = "posty/#{nazwa}.md"

  tytul = nil

  # Dla wpisów Markdown pobieramy tytuł z pierwszego nagłówka
  if File.exist?(plik_md)
    markdown = File.read(plik_md, encoding: "UTF-8")

    linia_tytulu = markdown.lines.find do |linia|
      linia.match?(/\A#\s+/)
    end

    if linia_tytulu
      tytul = linia_tytulu
        .sub(/\A#\s+/, "")
        .strip
    end
  end

  # Dla starych plików HTML używamy nazwy pliku
  tytul ||= nazwa

  <<~HTML
    <li>
      <a href="#{plik_html}">
        #{CGI.escapeHTML(tytul)}
      </a>
    </li>
  HTML
end.join

# Tworzenie strony głównej
index = <<~HTML
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Tsuki Blog - Main Page</title>
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
