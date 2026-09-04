#!/usr/bin/env bash
# Собирает автономную страницу-превью: картинки и видео вшиты как data:URI.
#
# Превью урезано намеренно — на странице есть лимит размера, а полный
# комплект медиа в него не влезает. Отличия от настоящего сайта:
#   • в галереях подставлены миниатюры, оригиналы не вшиваются
#   • в галерее зала показаны 6 кадров из 12
#   • в галерее полотен показаны 24 работы из 47
# На сайте, который собирается set-assets-base.sh, всё на месте.
set -e
cd "$(dirname "$0")"
OUT="${1:-pushkin-preview.html}"

perl -pe 's/\s+data-full="[^"]*"//g' tilda/03-body.html \
  | awk '/pj-gal--art/ { art = 1 }
         /pj-gal__i/   { n++; if (art && n > 24) next; if (!art && n > 6) next }
         { print }' \
  > .body-preview.tmp

{
  printf '<title>Пушкин. Живой</title>\n'
  printf '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
  printf '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n'
  printf '<link href="https://fonts.googleapis.com/css2?family=Prata&family=Golos+Text:wght@400;500;600&family=Cormorant+Garamond:wght@500;600;700&display=swap" rel="stylesheet">\n'
  printf '<style>\nhtml,body{margin:0;background:#E9E9E6}\n'
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
  ' .body-preview.tmp
  printf '\n'
  cat tilda/04-footer.html
} > "$OUT"

rm -f .body-preview.tmp
echo "$OUT: $(du -h "$OUT" | cut -f1)"
