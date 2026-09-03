#!/usr/bin/env bash
# Готовит блоки для вставки в Tilda: подставляет во все пути к картинкам
# и видео ваш адрес хостинга.
#
#   bash set-assets-base.sh https://ваш-хостинг.ru/pushkin
#
# Результат — в site/tilda-ready/
set -e
cd "$(dirname "$0")"

BASE="$1"
if [ -z "$BASE" ]; then
  echo "Укажите адрес, где лежит папка assets/, например:"
  echo "  bash set-assets-base.sh https://ivanov.github.io/pushkin"
  exit 1
fi
BASE="${BASE%/}"

OUT="tilda-ready"
rm -rf "$OUT"; mkdir -p "$OUT"

# разметка с переписанными путями (адрес идёт через окружение:
# в имени ветки бывает «@», и в коде perl принял бы его за массив)
BASE="$BASE" perl -pe 's{"assets/}{"$ENV{BASE}/assets/}g' tilda/03-body.html > "$OUT/.body.tmp"

cp tilda/01-head.html "$OUT/1-head.html"
cp tilda/02-style.css "$OUT/2-styles.css"

# главный блок: разметка и скрипт вместе — так работает на любом тарифе,
# даже если в настройках сайта нет поля для кода внутрь BODY
{
  cat "$OUT/.body.tmp"
  printf '\n\n'
  cat tilda/04-footer.html
} > "$OUT/3-block-T123.html"

# запасной вариант: стили, обёрнутые в <style>, если класть их в HEAD
{ printf '<style>\n'; cat tilda/02-style.css; printf '\n</style>\n'; } > "$OUT/2-styles-for-head.html"

# страница-проверка: повторяет то, что соберёт Tilda.
# Откройте двойным щелчком, чтобы увидеть результат до вставки.
{
  printf %s "<!doctype html>
<html lang=\"ru\"><head><meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>Пушкин. Живой — проверка перед вставкой в Tilda</title>
"
  cat "$OUT/1-head.html"
  printf %s "
<style>body{margin:0}</style>
<style>
"
  cat "$OUT/2-styles.css"
  printf %s "
</style>
</head>
<body class=\"t-body\">
<div class=\"t-rec\"><div class=\"t123\">
"
  cat "$OUT/3-block-T123.html"
  printf %s "
</div></div>
</body></html>
"
} > "$OUT/проверить-до-вставки.html"

rm -f "$OUT/.body.tmp"

N=$(grep -oF "$BASE/assets/" "$OUT/3-block-T123.html" | wc -l)
cat <<TXT
Готово: $OUT/

  1-head.html         → Настройки сайта → Ещё → HTML-код внутрь HEAD
  2-styles.css        → Настройки сайта → Ещё → CSS-код (без тегов <style>)
  3-block-T123.html   → блок T123 «HTML-код» на странице (разметка и скрипт вместе)

  2-styles-for-head.html — тот же CSS, но обёрнутый в <style>.
                           Нужен, только если кладёте стили в HEAD, а не в поле CSS.

  проверить-до-вставки.html — откройте двойным щелчком, это и увидит посетитель

Путей к медиа переписано: $N
Файлы assets/ раздаются с $BASE/assets/
TXT
