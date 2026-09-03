#!/usr/bin/env bash
# Собирает автономную страницу: картинки и видео вшиты как data:URI.
set -e
cd "$(dirname "$0")"
OUT="${1:-pushkin-preview.html}"
{
  printf '<title>Пушкин. Живой</title>\n'
  printf '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
  printf '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n'
  printf '<link href="https://fonts.googleapis.com/css2?family=Prata&family=Golos+Text:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">\n'
  printf '<style>\nhtml,body{margin:0;background:#06080F}\n'
  cat tilda/02-style.css
  printf '\n</style>\n'
  perl -0777 -MMIME::Base64 -pe '
    s{"(assets/[^"]+\.(webp|mp4|jpg|png))"}{
      my ($p,$e) = ($1,$2);
      if (-f $p) {
        my %m = (webp=>"image/webp", mp4=>"video/mp4", jpg=>"image/jpeg", png=>"image/png");
        open(my $fh, "<:raw", $p) or die $!;
        local $/; my $d = <$fh>; close $fh;
        my $b = encode_base64($d, "");
        qq{"data:$m{$e};base64,$b"}
      } else { qq{"$p"} }
    }ge;
  ' tilda/03-body.html
  printf '\n'
  cat tilda/04-footer.html
} > "$OUT"
echo "$OUT: $(du -h "$OUT" | cut -f1)"
