# Zapisz jako generuj.rb
posty = Dir.glob("posty/*.html").sort.reverse

lista = posty.map do |p|
  "<li><a href='#{p}'>#{File.basename(p, '.html')}</a></li>"
end.join

index = <<~HTML
<!DOCTYPE html>
<html>
<title>Tsuki Blog - Strona Główna</title>
<head><link rel="stylesheet" href="style.css"></head>
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

File.write("index.html", index)
puts "Strona główna zaktualizowana!"
