#! /bin/bash

set -euo pipefail

main() {
    for f in $(find graphs -name '*.dot'); do
        dot "$f" -Tpdf -o  "graphs/$(basename $f .dot).pdf"
        convert -density 150 "$f" -quality 90 "graphs/$(basename $f .dot).png"
    done
}

main
