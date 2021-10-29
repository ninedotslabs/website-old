#!/bin/sh
# bash build.sh

set -e

rm -rf dist

cp -r public/ dist/

sass public/assets/css/app.scss dist/assets/css/app.css --style compressed

rm dist/assets/css/*.scss

js="dist/assets/js/app.js"
min="dist/assets/js/app.min.js"
elm="src/Main.elm"

elm make --optimize --output=$js $elm

uglifyjs $js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output $min
node_modules/.bin/webpack

rm dist/assets/js/app.js
rm dist/index.html

html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true public/index.html --output dist/index.html
