#!/usr/bin/env bash
# Генерация кадров для эпизодов через Hugging Face Space FLUX.1-schnell.
# Запуск:  bash gen-images.sh assets/ep/prompts.tsv
# Нужна квота ZeroGPU: залогиньтесь на huggingface.co (PRO даёт ~25 мин GPU в сутки).
# Читает TSV: имя <TAB> ширина <TAB> высота <TAB> промпт
# Кладёт .webp в site/assets/ep/
S="https://evalstate-flux1-schnell.hf.space"
OUTDIR="$(cd "$(dirname "$0")" && pwd)/assets/ep"
STYLE="oil painting, 19th century Russian academic art, muted desaturated palette of deep ink blue and pale snow white with warm candlelight gold, dramatic chiaroscuro lighting, visible canvas texture, painterly brushwork, cinematic composition"
mkdir -p "$OUTDIR"
ok=0; fail=0
while IFS=$'\t' read -r NAME W H P; do
  [ -z "$NAME" ] && continue
  [ -f "$OUTDIR/$NAME.webp" ] && { echo "skip $NAME"; continue; }
  FULL="$P, $STYLE"
  # JSON-экранирование кавычек и обратных слэшей
  ESC="$FULL"
  printf '{"data":["%s",0,true,%s,%s,4]}' "$ESC" "$W" "$H" > .req.json
  EID=$(curl -sS -X POST "$S/gradio_api/call/infer" -H "Content-Type: application/json" --data-binary @.req.json | tr -d '{}"' | sed 's/.*event_id: *//')
  if [ -z "$EID" ]; then echo "FAIL(no eid) $NAME"; fail=$((fail+1)); continue; fi
  RES=$(curl -sS --max-time 240 -N "$S/gradio_api/call/infer/$EID")
  URL=$(printf '%s' "$RES" | grep -o 'https://[^"]*image.webp' | head -1)
  if [ -z "$URL" ]; then
    echo "FAIL $NAME :: $(printf '%s' "$RES" | tr -d '\n' | tail -c 160)"
    fail=$((fail+1)); continue
  fi
  curl -sS -o "$OUTDIR/$NAME.webp" "$URL"
  echo "ok $NAME $(stat -c%s "$OUTDIR/$NAME.webp")b"
  ok=$((ok+1))
done < "$1"
echo "=== готово: $ok, ошибок: $fail ==="
