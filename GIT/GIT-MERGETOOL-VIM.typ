#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
  numbering: "1"
)
= Configurer Git + vim comme mergetool avec stow 


#linebreak()
Ce guide explique comment : 
- Gérer ta configuration Git avec ton repo de dotfiles et *stow* - Utiliser *vim* comme mergetool et difftool 
- Résoudre un conflit de merge dans vim 
== 1. Organisation des dotfiles avec stow 

=== 1.1. Arborescence Dans ton repo de dotfiles (par exemple `~/dotfiles`), crée la structure suivante : 

#linebreak()
```bash 
cd ~/dotfiles mkdir -p git touch git/.gitconfig 
```

#linebreak()
L’objectif est que `git/.gitconfig` soit symlinké en `~/.gitconfig`.
=== 1.2. Application avec stow Depuis ton repo de dotfiles : cd ~/dotfiles stow git Si tout se passe bien, tu auras :

#linebreak()
- `~/dotfiles/git/.gitconfig` (fichier dans le repo) 
- `~/.gitconfig` (lien symbolique qui pointe vers ce fichier) 
== 2. Exemple de `git/gitconfig` complet (avec vim mergetool)

#linebreak()
Colle cet exemple dans `git/.gitconfig` de ton repo de dotfiles, puis adapte les commentaires / options comme tu veux. 

```bash
# Identité #
[user]
    name = Ton Nom                # Ton nom d'auteur dans les commits
    email = ton.email@example.com # Ton email

# Éditeur & pager # 
[core]
    editor = vim                   # Utiliser Neovim comme éditeur

# Merge & mergetool (Neovim) # 
[merge]
    tool = vim                 # Utiliser Neovim (nvimdiff) comme mergetool
    conflictstyle = merge           # Montre aussi BASE dans les conflits (optionnel)

[mergetool]
    prompt = false                  # Ne pas demander de confirmation à chaque fichier
    keepBackup = false              # Ne pas garder les fichiers .orig
    trustExitCode = false            # Laisser Git décider si le merge est OK

[mergetool "vim"]
    cmd = vim -d $LOCAL $MERGED $REMOTE 
    # Layout par défaut (Git sait gérer vimdiff sans cmd explicite)
    # Si tu veux un layout custom, tu peux utiliser cmd à la place
    # cmd = nvim -d "$LOCAL" "$MERGED" "$BASE" "$REMOTE" -c "wincmd w" -c "wincmd J"
    # Exemple alternatif : Diffview (plugin Neovim)
    # [merge]
    # tool = diffview
    # [mergetool "diffview"]
    # cmd = nvim -n -c "DiffviewOpen" "$MERGED"

# Difftool (optionnel, aussi en vi) # 
[diff]
    tool = vim                 # Utiliser vim comme difftool

[difftool]
    prompt = false                  # Ne pas demander pour chaque fichier

[difftool "vim"]
    cmd = vim -d $LOCAL $REMOTE

# Pull / Fetch / Push # 
[pull]
    # rebase = true                # Faire un rebase plutôt qu'un merge sur git pull

[push]
    default = current               # Pousser seulement la branche courante
    autoSetupRemote = true          # Créer le remote tracking à la première poussée

#  Branches # 
[branch]
    autosetuprebase = always        # Toujours rebase pour les nouvelles branches

# Log & couleur # 
[color]
    ui = auto                       # Couleurs auto dans Git

[format]
    # pretty = oneline              # Formattage par défaut des logs

#  GPG / signature (optionnel) # 
[commit]
    # gpgsign = true               # Signer tous les commits

[tag]
    # gpgsign = true               # Signer tous les tags

#  Divers # 
[init]
    # defaultBranch = main           # Nom par défaut de la branche initiale

[rerere]
    # enabled = true                 # Réutiliser les résolutions de conflits
    ```

= Résoudre un conflit avec Vim mergetool (3 fenêtres : LOCAL-MERGED-REMOTE)

== 1. Lancer le mergetool
#linebreak()

1. Effectue un merge qui crée des conflits (exemple : git merge feature).
2. Git indique qu'il y a des conflits.
3. Lance la commande suivante :

```bash
   $ git mergetool
```
#pagebreak()
Git ouvre Vim en mode diff avec 3 fenêtres (conflictstyle = merge) :

LOCAL (gauche) : ta version locale

MERGED (milieu) : le fichier cible à éditer

REMOTE (droite) : la version distante

== 2. Mappings pratiques dans Vim (.vimrc)

Ajoute ces lignes dans ton .vimrc pour faciliter la résolution :

```vim
if &diff
  nmap 1 :diffget LOCAL<CR>
  nmap 2 :diffget REMOTE<CR>
  nnoremap dc :diffupdate<CR>
endif
```

=== Explication des raccourcis


```vim
if &diff vérifie si Vim est en mode diff.
```

- 1 prend la version LOCAL (gauche).
- 2 prend la version REMOTE (droite).
dc rafraîchit l'affichage des différences.

== 3. Workflow typique de résolution (3 fenêtres)

=== Étapes

 *1) Lance le mergetool :*

```bash
   $ git mergetool
```

 *2) Vim s'ouvre avec LOCAL-MERGED-REMOTE.*

 *3) Place-toi dans MERGED (milieu, généralement fenêtre active).*

 *4) Sur un conflit donné :*
- Utilise les mappings :
  1 : prendre LOCAL (gauche)
  2 : prendre REMOTE (droite)
- Ou commandes directes :
  :diffget LOCAL
  :diffget REMOTE
- dc : rafraîchir affichage

  *5) Navigue conflits :*

- `]`c pour conflit suivant
- `[`c pour conflit précédent

=== Explications

:diffget copie le bloc de différence depuis LOCAL ou REMOTE vers MERGED (milieu).
Tu peux mélanger : 1 pour une ligne, 2 pour une autre.

#pagebreak()
== 4. Finaliser le merge

=== 1) Quand satisfait :
```bash
:w  (sauvegarde MERGED)
```

=== 2) Quitte Vim :
```bash
:qa
```

=== 3) Terminal :
```bash
$ git status
$ git commit
```

== Résumé rapide (ta config)

- git mergetool → 3 fenêtres (LOCAL-MERGED-REMOTE)
- Dans MERGED : 1=LOCAL gauche, 2=REMOTE droite
- `]`c/`[`c navigue conflits
- :w :qa termine


