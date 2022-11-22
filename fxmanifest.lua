fx_version 'adamant'

games { 'gta5' }

author 'TusMuertos.#4903 / Javi'

ui_page "html/ui.html"

shared_scripts {
  '@es_extended/imports.lua',
  "@es_extended/locale.lua",
  "locales/*.lua",
  'config.lua'
}

client_scripts {
  "client/main.lua",
  "client/player.lua",
  "client/clothing.lua",
  'client/almacenes.lua'
}

server_scripts {
  "@async/async.lua",
  "@mysql-async/lib/MySQL.lua",
  "server/main.lua",
  'server/storage.lua'
}

files {
  "html/ui.html",
  "html/css/ui.css",
  "html/js/inventory.js",
  "html/js/config.js",
  'html/img/items/*.png',
  "html/fonts/*.ttf",
  "html/sonidos/*.ogg"
}