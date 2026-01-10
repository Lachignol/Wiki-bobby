#set document(title: "Tutoriel Complet : Créer un Plugin Neovim")

#set page(margin: 1.5cm)

#set text(font: "New Computer Modern", size: 11pt, lang: "fr")

#set par(justify: true)



#align(center)[

  #text(size: 24pt, weight: "bold")[Tutoriel Complet : Créer un Plugin Neovim]

  #v(0.5cm)

  #text(size: 14pt)[De l'idée à l'installation]

]



#outline()



#pagebreak()



= Introduction



Tutoriel pour la création d'un plugin Neovim complet. Nous allons créer un plugin simple appelé *hello.nvim* qui affichera des messages de salutation personnalisés.



== Prérequis



- Neovim installé (version 0.8+)

- Connaissance de base de Lua

- Git installé

- Un gestionnaire de plugins (lazy.nvim, packer.nvim, etc.)



= Comprendre l'Architecture d'un Plugin Neovim


== Qu'est-ce qu'un plugin Neovim ?


Un plugin Neovim est un ensemble de fichiers Lua organisés dans une structure spécifique qui étend les fonctionnalités de Neovim. Les plugins modernes utilisent Lua pour la performance et la simplicité.


== Comment Neovim charge les plugins


Neovim recherche les plugins dans le `runtimepath`. Quand vous installez un plugin avec un gestionnaire, il est ajouté à ce chemin. Neovim charge automatiquement les fichiers selon une hiérarchie précise.


= Structure de Base d'un Plugin


== Arborescence Minimale


Voici la structure minimale pour notre plugin `hello.nvim` :



```

hello.nvim/

├── lua/

│   └── hello/

│       ├── init.lua          # Point d'entrée du plugin

│       ├── config.lua         # Configuration par défaut

│       └── utils.lua          # Fonctions utilitaires

├── plugin/

│   └── hello.lua              # Auto-chargement des commandes

├── doc/

│   └── hello.txt              # Documentation

└── README.md                  # Description du projet

```



== Explication de chaque dossier



*lua*: Contient le code Lua principal du plugin. Le nom du sous-dossier (`hello/`) doit correspondre au nom de votre plugin.



*plugin*: Les fichiers ici sont automatiquement exécutés au démarrage de Neovim. Utilisé pour enregistrer les commandes et keymaps.



*doc*: Documentation au format help de VimNeovim.



*README.md*: Documentation pour GitHub/GitLab.



= Étape 1 : Créer la Structure du Projet



== Initialisation du projet



Créez un nouveau dossier pour votre plugin :



```bash

mkdir -p ~/projects/hello.nvim

cd ~/projects/hello.nvim

git init

```



== Créer l'arborescence


```bash

mkdir -p lua/hello

mkdir -p plugin

mkdir -p doc

touch lua/hello/init.lua

touch lua/hello/config.lua

touch lua/hello/utils.lua

touch plugin/hello.lua

touch doc/hello.txt

touch README.md

```



= Étape 2 : Implémenter la Configuration



== Fichier `lua/hello/config.lua`



Ce fichier contient la configuration par défaut du plugin.



```lua
-- lua/hello/config.lua
local M = {}
-- Configuration par défaut
M.defaults = {
-- Message de salutation par défaut
  default_greeting = "Hello",
-- Utiliser le nom d'utilisateur système
  use_username = true,
-- Préfixe pour les messages
  prefix = "👋 ",
-- Style de notification
  notify_level = "info", -- "info", "warn", "error"
}

-- Configuration actuelle (sera fusionnée avec les options utilisateur)
M.options = {}


-- Fonction pour configurer le plugin

function M.setup(user_options)

-- Fusionner la configuration utilisateur avec les valeurs par défaut
  M.options = vim.tbl_deep_extend("force", M.defaults, user_options or {})

end

return M

```


*Explication* : 

- `M.defaults` contient toutes les options configurables

- `M.setup()` permet à l'utilisateur de personnaliser le plugin

- `vim.tbl_deep_extend()` fusionne intelligemment les tables Lua



= Étape 3 : Créer les Fonctions Utilitaires



== Fichier `lua/hello/utils.lua`



```lua
-- lua/hello/utils.lua

local M = {}

-- Obtenir le nom d'utilisateur système

function M.get_username()

  local handle = io.popen("whoami")

  if handle then

  local username = handle:read("*a")
  handle:close()
  return username:gsub("%s+", "") -- Enlever les espaces/retours ligne

  end

  return "User"

end



-- Obtenir l'heure actuelle formatée

function M.get_time()

  return os.date("%H:%M:%S")

end



-- Obtenir le jour de la semaine
function M.get_day()

  local days = {"Dimanche", "Lundi", "Mardi", "Mercredi","Jeudi", "Vendredi", "Samedi"}

  return days[tonumber(os.date("%w")) + 1]

end

-- Créer un message de salutation personnalisé
function M.create_greeting(config)
	local parts = {}

	-- Prefix safe
	if config and config.prefix then
		parts[#parts + 1] = config.prefix
	end

	-- Greeting et puis tout le reste dans le M.defaults donc par default dans config
	if config and config.default_greeting then
		greeting = config.default_greeting
	end
	parts[#parts + 1] = greeting

	-- Username optionnel
	if config and config.use_username then
		parts[#parts + 1] = M.get_username()
	end

	return table.concat(parts, " ")
end



-- Afficher une notification Neovim

function M.notify(message, level)

  local levels = {
    info = vim.log.levels.INFO,
    warn = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
  }
  vim.notify(message, levels[level] or levels.info, {
  title = "Hello.nvim",
  })

end

return M

```



*Explication* :

- Chaque fonction a une responsabilité unique

- `M.get_username()` utilise une commande système

- `M.notify()` utilise l'API de notification de Neovim


= Étape 4 : Implémenter le Cœur du Plugin

== Fichier `lua/hello/init.lua`

C'est le point d'entrée principal du plugin.

```lua

-- lua/hello/init.lua

local config = require("hello.config")

local utils = require("hello.utils")



local M = {}



-- Fonction setup pour initialiser le plugin
function M.setup(user_options)

-- Configurer le plugin avec les options utilisateur
  config.setup(user_options)

end

-- Fonction principale : dire bonjour
function M.say_hello()

  local greeting = utils.create_greeting(config.options)

  utils.notify(greeting, config.options.notify_level)

end


-- Dire bonjour avec l'heure
function M.say_hello_with_time()

  local greeting = utils.create_greeting(config.options)

  local time = utils.get_time()

  local message = string.format("%s - Il est %s", greeting, time)

  utils.notify(message, config.options.notify_level)

end

-- Dire bonjour avec le jour
function M.say_hello_with_day()

  local greeting = utils.create_greeting(config.options)

  local day = utils.get_day()

  local message = string.format("%s - Nous sommes %s", greeting, day)

  utils.notify(message, config.options.notify_level)

end



-- Message personnalisé
function M.custom_message(msg)

  if not msg or msg == "" then

  utils.notify("Aucun message fourni!", "warn")

  return

  end

  local full_message = config.options.prefix .. msg

  utils.notify(full_message, config.options.notify_level)

end


-- Fonction de santé (health check)
function M.check_health()

  local health = {
  ok = true,
  messages = {},
}
-- Vérifier que Neovim est à jour
  if vim.fn.has("nvim-0.8") == 0 then
  health.ok = false
  table.insert(health.messages, "Neovim 0.8+ requis")
  else
  table.insert(health.messages, "Version Neovim OK")

end

-- Vérifier que la config est chargée
  if config.options.default_greeting then

  table.insert(health.messages, "Configuration chargée")
  else

  health.ok = false

  table.insert(health.messages, "Configuration non chargée")

  end

  return health

end

return M

```



*Explication* :

- `M.setup()` est appelée par l'utilisateur pour configurer le plugin

- Chaque fonction publique peut être appelée via `:lua require('hello').say_hello()`

- Le plugin est modulaire et facile à étendre



= Étape 5 : Créer les Commandes et Auto-chargement


== Fichier `plugin/hello.lua`

Ce fichier est automatiquement exécuté au démarrage de Neovim.

```lua

-- plugin/hello.lua

-- S'assurer que le plugin n'est chargé qu'une seule fois
if vim.g.loaded_hello then

  return

end

vim.g.loaded_hello = true

-- Créer les commandes utilisateur
vim.api.nvim_create_user_command("Hello", function()
  require("hello").say_hello()
end, {desc = "Afficher un message de salutation"})


vim.api.nvim_create_user_command("HelloTime", function()
  require("hello").say_hello_with_time()
end, {desc = "Afficher un message de salutation avec l'heure"})

vim.api.nvim_create_user_command("HelloDay", function()
  require("hello").say_hello_with_day()
end, {desc = "Afficher un message de salutation avec le jour"})


vim.api.nvim_create_user_command("HelloCustom", function(opts)
  require("hello").custom_message(opts.args)
end, {nargs = 1,desc = "Afficher un message personnalisé"})

-- Créer un autocommand pour dire bonjour au démarrage (optionnel)
vim.api.nvim_create_autocmd("VimEnter", {

  callback = function()
-- Attendre un peu que Neovim soit complètement chargé
  vim.defer_fn(function()
-- Vérifier si l'utilisateur a configuré le plugin
  local ok, hello = pcall(require, "hello")
  if ok and hello then
-- Ne rien faire automatiquement, laisser l'utilisateur décider
  end

 end, 100)

end,

})

```



*Explication* :

- `vim.g.loaded_hello` empêche le double chargement

- `nvim_create_user_command()` crée des commandes Ex (`:Hello`)

- Les commandes chargent le module à la demande (lazy loading)

= Étape 6 : Ajouter la Documentation

== Fichier `doc/hello.txt`



```

*hello.txt*    Plugin de salutation pour Neovim



==============================================================================

CONTENU                                                      *hello-contents*



    1. Introduction ............................ |hello-introduction|

    2. Installation ............................ |hello-installation|

    3. Configuration ........................... |hello-configuration|

    4. Commandes ............................... |hello-commands|

    5. API Lua ................................. |hello-api|



==============================================================================

1. INTRODUCTION                                          *hello-introduction*



Hello.nvim est un plugin simple qui affiche des messages de salutation

personnalisés dans Neovim.



==============================================================================

2. INSTALLATION                                          *hello-installation*



Avec lazy.nvim: >lua

    {

      "votre-username/hello.nvim",

      config = function()

        require("hello").setup({

          default_greeting = "Bonjour",

          use_username = true,

        })

      end

    }

<

Avec vim.pack: >lua

Ajouter le plugin : 

Si le repo est en prive pour tester avec bien sur la clef ssh qui faut:

vim.pack.add{ src = "git@github.com:votre-username/hello.nvim" },

Si en public :

vim.pack.add{ src = "https://github.com/votre-username/hello.nvim" },

et dans le hello.lua:


require("hello").setup({
	default_greeting = "",
	prefix = "[TestPlugin] ",
	notify_level = vim.log.levels.INFO,
	use_username = true
})


==============================================================================

3. CONFIGURATION                                        *hello-configuration*



Options disponibles :



- `default_greeting` (string) : Message de salutation par défaut

  Défaut : "Hello"



- `use_username` (boolean) : Inclure le nom d'utilisateur

  Défaut : true



- `prefix` (string) : Préfixe emoji/texte

  Défaut : "👋 "



- `notify_level` (string) : Niveau de notification ("info", "warn", "error")

  Défaut : "info"



Exemple de configuration complète : >lua


require("hello").setup({
	default_greeting = "message de test",
	prefix = "[TestPlugin] ",
	notify_level = vim.log.levels.INFO,
	use_username = true
})

<



==============================================================================

4. COMMANDES                                                *hello-commands*



:Hello                                                             *:Hello*

    Affiche un message de salutation simple.



:HelloTime                                                     *:HelloTime*

    Affiche un message de salutation avec l'heure actuelle.



:HelloDay                                                       *:HelloDay*

    Affiche un message de salutation avec le jour de la semaine.



:HelloCustom {message}                                        *:HelloCustom*

    Affiche un message personnalisé.

    Exemple : `:HelloCustom Bonne journée!`



==============================================================================

5. API LUA                                                        *hello-api*



require("hello").setup({opts})                              *hello.setup()*

    Configure le plugin avec les options fournies.



require("hello").say_hello()                            *hello.say_hello()*

    Affiche un message de salutation.



require("hello").say_hello_with_time()          *hello.say_hello_with_time()*

    Affiche un message avec l'heure.



require("hello").say_hello_with_day()            *hello.say_hello_with_day()*

    Affiche un message avec le jour.



require("hello").custom_message(msg)              *hello.custom_message()*

    Affiche un message personnalisé.

    Paramètres :

        {msg} (string) : Le message à afficher



==============================================================================

vim:tw=78:ts=8:ft=help:norl:

```

*Afin de cree le help*

Dans Neovim, tapez la commande :

```sh

:helptags chemin/du_dossier_ou_il_y_a_le_fichier.txt

```
Ici par exemple

```sh

:helptags doc/

```



*Explication* :

- Format spécial pour l'aide Vim/Neovim

- Les `*tags*` permettent la navigation avec `:h hello`

- Structure standard : Introduction, Installation, Configuration, etc.

Appuyez sur Entrée. Cela génère le fichier doc/tags indispensable pour :help test-plugin.



= Étape 7 : Créer le README



== Fichier `README.md`



```markdown

# hello.nvim



Un plugin Neovim simple et élégant pour afficher des messages de salutation personnalisés.



## ✨ Fonctionnalités



- 👋 Messages de salutation personnalisables

- ⏰ Affichage de l'heure

- 📅 Affichage du jour de la semaine

- 💬 Messages personnalisés

- ⚙️ Configuration flexible



## 📦 Installation



### lazy.nvim



```lua

{

  "votre-username/hello.nvim",

  config = function()

  require("hello").setup({

  default_greeting = "Bonjour",

  use_username = true,

  prefix = "👋 ",

  notify_level = "info",
  })

  end
}

```



### packer.nvim



```lua

use {

  "votre-username/hello.nvim",

  config = function()

    require("hello").setup()

  end

}

```

### vim.pack


Si le repo est en prive pour tester avec bien sur la clef ssh qui faut:

```lua
vim.pack.add{ src = "git\@github.com:votre-username/hello.nvim" },

```

Si en public :


```lua
vim.pack.add{ src = "https://github.com/votre-username/hello.nvim" },
```



## ⚙️ Configuration



Configuration par défaut :



```lua

require("hello").setup({

  -- Message de salutation par défaut

  default_greeting = "Hello",

  -- Utiliser le nom d'utilisateur système

  use_username = true,

  -- Préfixe pour les messages

  prefix = "👋 ",

  -- Style de notification

  notify_level = "info", -- "info", "warn", "error"

})

```



## 🚀 Utilisation



### Commandes



- `:Hello` - Affiche un message de salutation simple

- `:HelloTime` - Affiche un message avec l'heure actuelle

- `:HelloDay` - Affiche un message avec le jour

- `:HelloCustom [message]` - Affiche un message personnalisé



### API Lua



```lua

-- Message simple

require("hello").say_hello()



-- Avec l'heure

require("hello").say_hello_with_time()



-- Avec le jour

require("hello").say_hello_with_day()



-- Message personnalisé

require("hello").custom_message("Bonne journée!")

```



### Keymaps (exemple)



```lua

vim.keymap.set("n", "<leader>hh", "<cmd>Hello<cr>", { desc = "Dire bonjour" })

vim.keymap.set("n", "<leader>ht", "<cmd>HelloTime<cr>", { desc = "Bonjour + heure" })

vim.keymap.set("n", "<leader>hd", "<cmd>HelloDay<cr>", { desc = "Bonjour + jour" })

```



## 📝 Documentation



Pour plus d'informations, consultez l'aide intégrée :



```vim

:help hello

```



## 🤝 Contribution



Les contributions sont les bienvenues! N'hésitez pas à ouvrir une issue ou une pull request.



## 📄 Licence



MIT

```



= Étape 8 : Installation et Test



== Installation locale pour le développement



Pour tester votre plugin pendant le développement :



```lua

-- Dans votre configuration Neovim (init.lua)



-- Ajouter le chemin de développement au runtimepath

vim.opt.runtimepath:append("~/projects/hello.nvim")



-- Configurer le plugin


require("hello").setup({
	default_greeting = "Morpheus",
	prefix = "[TestPlugin] ",
	notify_level = "info",
	use_username = true

})

```



== Installation avec lazy.nvim



Configuration complète avec lazy.nvim :



```lua

-- ~/.config/nvim/lua/plugins/hello.lua



return {

  -- Pour un plugin local en développement

  dir = "~/projects/hello.nvim",

  -- Ou pour un plugin sur GitHub (après publication)

  -- "votre-username/hello.nvim",

  -- Options de lazy loading

  cmd = { "Hello", "HelloTime", "HelloDay", "HelloCustom" },

  keys = {

    { "<leader>hh", "<cmd>Hello<cr>", desc = "Dire bonjour" },

    { "<leader>ht", "<cmd>HelloTime<cr>", desc = "Bonjour + heure" },

    { "<leader>hd", "<cmd>HelloDay<cr>", desc = "Bonjour + jour" },

  },

  -- Configuration du plugin

  config = function()

    require("hello").setup({

      default_greeting = "Salut",

      use_username = true,

      prefix = "👋 ",

      notify_level = "info",

    })

  end,

}

```



== Installation avec packer.nvim



```lua

use {

  "votre-username/hello.nvim",

  config = function()

    require("hello").setup({

      default_greeting = "Bonjour",

      use_username = true,

    })

  end

}

```



== Installation avec vim-plug



```vim

Plug 'votre-username/hello.nvim'



lua << EOF

require("hello").setup({

  default_greeting = "Hello",

  use_username = true,

})

EOF

```



= Étape 9 : Tests et Debugging



== Tester le plugin

Après installation, testez chaque fonctionnalité :


```vim

:Hello

:HelloTime

:HelloDay

:HelloCustom Ceci est un test!

```



Ou en Lua :



```lua

:lua require("hello").say_hello()

:lua require("hello").say_hello_with_time()

:lua require("hello").say_hello_with_day()

:lua require("hello").custom_message("Test message")

```



== Debugging



Pour débugger votre plugin :



```lua

-- Recharger le plugin après modifications

:lua package.loaded["hello"] = nil

:lua package.loaded["hello.config"] = nil

:lua package.loaded["hello.utils"] = nil

:lua require("hello").setup()



-- Inspecter la configuration

:lua vim.print(require("hello.config").options)



-- Vérifier les messages d'erreur

:messages

```



== Ajouter des logs de débogage



Modifiez temporairement votre code :



```lua

-- Dans n'importe quel fichier du plugin

local function debug_log(message)

  vim.notify(

  string.format("[DEBUG] %s", message),

  vim.log.levels.DEBUG

  )

end



-- Utiliser dans vos fonctions

function M.say_hello()

  debug_log("say_hello appelée")

  local greeting = utils.create_greeting(config.options)

  debug_log("Greeting créé: " .. greeting)

  utils.notify(greeting, config.options.notify_level)

end

```



= Étape 10 : Fonctionnalités Avancées

== Ajouter un Health Check


Créez `lua/hello/health.lua` :



```lua

-- lua/hello/health.lua

local M = {}



function M.check()

  local health_start = vim.health.start or vim.health.report_start

  local health_ok = vim.health.ok or vim.health.report_ok

  local health_error = vim.health.error or vim.health.report_error

  local health_warn = vim.health.warn or vim.health.report_warn

  health_start("hello.nvim")

-- Vérifier la version de Neovim

  if vim.fn.has("nvim-0.8") == 1 then

  health_ok("Neovim version 0.8+")

  else

  health_error("Neovim 0.8+ requis")

  end

-- Vérifier que le plugin est configuré

  local ok, config = pcall(require, "hello.config")

  if ok and config.options.default_greeting then

  health_ok("Plugin configuré correctement")

  health_ok(string.format("Message: '%s'",config.options.default_greeting))

  else

  health_warn("Plugin non configuré, utilisation des valeurs par défaut")

  end

-- Vérifier les dépendances (si nécessaire)

  if vim.fn.executable("whoami") == 1 then

  health_ok("Commande 'whoami' disponible")

  else

  health_warn("Commande 'whoami' non trouvée")

  end

end


return M

```



Testez avec `:checkhealth hello`



== Ajouter de la persistance


Créez `lua/hello/storage.lua` :



```lua

-- lua/hello/storage.lua

local M = {}


-- Chemin du fichier de stockage
local storage_path = vim.fn.stdpath("data") .. "/hello_data.json"



-- Sauvegarder des données
function M.save(data)

  local file = io.open(storage_path, "w")

  if file then

  local json = vim.json.encode(data)

  file:write(json)

  file:close()

  return true

  end

  return false

end

-- Charger des données
function M.load()

  local file = io.open(storage_path, "r")

  if file then

  local content = file:read("*all")

  file:close()

  local ok, data = pcall(vim.json.decode, content)

  if ok then

  return data

  end

end

return nil

end



-- Sauvegarder un compteur de salutations
function M.increment_counter()

  local data = M.load() or { count = 0 }

  data.count = data.count + 1

  data.last_greeting = os.date("%Y-%m-%d %H:%M:%S")

  M.save(data)

  return data.count

end



-- Obtenir les statistiques
function M.get_stats()

  return M.load() or { count = 0, last_greeting = "Jamais" }

end



return M

```



Ajoutez une commande pour voir les stats :



```lua

-- Dans plugin/hello.lua

vim.api.nvim_create_user_command("HelloStats", function()

  local storage = require("hello.storage")

  local stats = storage.get_stats()

  local message = string.format("Salutations totales: %d\nDernière: %s",stats.count,stats.last_greeting)

  vim.notify(message, vim.log.levels.INFO, { title = "Hello Stats" })

end, {desc = "Afficher les statistiques de hello.nvim"})

```



= Étape 11 : Publication du Plugin



== Préparer le dépôt GitHub



Créez un fichier `.gitignore` :



```

# Fichiers Neovim

*.swp

*.swo

*~



# Données de test

test/

.test/



# OS

.DS_Store

Thumbs.db

```



Ajoutez une licence (MIT) :



```

MIT License



Copyright (c) 2024 Votre Nom



Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in all

copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

SOFTWARE.

```



== Publier sur GitHub



```bash

# Créer le premier commit

git add .

git commit -m "Initial commit: hello.nvim plugin"


# Créer le dépôt sur GitHub (via l'interface web)

# Puis lier le dépôt local

git remote add origin git@github.com:votre-username/hello.nvim.git

git branch -M main

git push -u origin main

# Créer un tag de version

git tag -a v1.0.0 -m "Version 1.0.0"

git push origin v1.0.0

```



== Ajouter des badges au README



Améliorez votre README avec des badges :



```markdown

# hello.nvim



![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)

![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)

![License](https://img.shields.io/badge/license-MIT-orange.svg)

...

```



= Étape 12 : Bonnes Pratiques



== Organisation du code



*Séparation des responsabilités* :

- `init.lua` : Point d'entrée, API publique

- `config.lua` : Gestion de la configuration

- `utils.lua` : Fonctions utilitaires réutilisables

- `health.lua` : Vérifications de santé



== Gestion des erreurs



Toujours protéger les appels critiques :



```lua

function M.safe_function()

  local ok, result = pcall(function()
-- Code qui peut échouer
  return some_risky_operation()
  end)

  if not ok then

  vim.notify("Erreur dans hello.nvim: " .. tostring(result),
  vim.log.levels.ERROR
  )

  return nil

  end

  return result

end

```



== Performance



Utiliser le lazy loading :



```lua

-- Charger les modules seulement quand nécessaire

local utils



function M.say_hello()

  if not utils then

  utils = require("hello.utils")

  end

-- Utiliser utils...

end

```



== Documentation du code



Commenter votre code :



```lua

--- Crée un message de salutation personnalisé

--- @param config table Configuration du plugin

--- @return string Message de salutation formaté

function M.create_greeting(config)

  -- Implementation...

end

```



= Étape 13 : Tester avec des Utilisateurs



== Demander des retours



Créez un fichier `CONTRIBUTING.md` :



```markdown

# Contribution à hello.nvim



Merci de votre intérêt pour contribuer!



## Signaler un bug



Ouvrez une issue avec :

- Description du problème

- Étapes pour reproduire

- Version de Neovim

- Configuration du plugin



## Proposer une fonctionnalité



Ouvrez une issue avec :

- Description de la fonctionnalité

- Cas d'usage

- Exemple d'implémentation (optionnel)



## Soumettre une Pull Request



1. Forkez le projet

2. Créez une branche (`git checkout -b feature/amazing-feature`)

3. Committez vos changements

4. Poussez vers la branche

5. Ouvrez une Pull Request

```



== Créer un template d'issue



`.github/ISSUE_TEMPLATE/bug_report.md` :



```markdown

---

name: Bug Report

about: Signaler un problème

title: '[BUG] '

labels: bug

---



**Description du bug**

Description claire et concise.



**Reproduction**

Étapes pour reproduire :

1. 

2. 

3. 



**Comportement attendu**

Ce qui devrait se passer.



**Configuration**

- Version Neovim :

- Système d'exploitation :

- Configuration du plugin :



```lua

-- Votre configuration

```

```



= Conclusion



== Récapitulatif



Vous avez maintenant créé un plugin Neovim complet avec :



1. ✅ Structure modulaire et organisée

2. ✅ Configuration flexible

3. ✅ Commandes utilisateur

4. ✅ Documentation complète

5. ✅ Health checks

6. ✅ Gestion d'erreurs

7. ✅ Publication sur GitHub



== Prochaines étapes



Pour aller plus loin :



- Ajouter des tests automatisés avec `plenary.nvim`

- Créer une interface UI avec `nui.nvim`

- Intégrer avec d'autres plugins (telescope, etc.)

- Ajouter des actions GitHub pour CI/CD

- Créer des vidéos de démonstration

- Participer à awesome-neovim



== Ressources



- Documentation Neovim Lua : `:help lua-guide`

- API Neovim : `:help api`

- Awesome Neovim : github.com/rockerBOO/awesome-neovim

- Neovim Discourse : neovim.discourse.group






