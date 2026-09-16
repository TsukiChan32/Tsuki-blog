tytul = ARGV[0] || "Bez tytułu"
data = Time.now.strftime('%Y-%m-%d')
plik = "#{data}-#{tytul.downcase.gsub(' ', '-')}.html"

szablon = File.read('szablon.html')


html = szablon.gsub('{{TYTUL_STRONY}}', tytul)
              .gsub('{{TRESC}}', "<h1>#{tytul}</h1><p>Tutaj wpisz swoją treść w HTML...</p>")

File.write("posty/#{plik}", html)
puts "Utworzyłam plik: posty/#{plik}"
