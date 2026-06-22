image:transparent() {
    local in="$1"
    local out="${2:-${in%.*}-transparent.png}"
    local bg="${3:-$(magick "$in" -format "%[pixel:p{10,10}]" info:)}"

    magick "$in" \
      -fuzz 25% \
      -transparent "$bg" \
      "$out"
}
