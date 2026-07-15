# Tutoriel Complet : Maîtriser `pass` (The Standard Unix Password Manager)

`pass` est un gestionnaire de mots de passe en ligne de commande qui suit scrupuleusement la philosophie Unix. Chaque mot de passe est stocké dans un fichier chiffré individuel avec **GnuPG (GPG)**. Ces fichiers sont organisés dans une arborescence de dossiers simple, ce qui permet de les versionner et de les synchroniser très facilement avec **Git**.

Ce tutoriel complet vous guide à travers toutes les étapes, de la création de votre clé cryptographique à la synchronisation Git et la restauration de votre coffre-fort sur une nouvelle machine.

---

## Sommaire
1. [Installation de `pass` et de GnuPG](#1-installation-de-pass-et-de-gnupg)
2. [Création et configuration de votre clé GPG](#2-création-et-configuration-de-votre-clé-gpg)
3. [Initialisation de `pass`](#3-initialisation-de-pass)
4. [Utilisation quotidienne (Ajouter, Générer, Lire)](#4-utilisation-quotidienne)
5. [Synchronisation avec Git](#5-synchronisation-avec-git)
6. [Migration et importation sur une autre machine](#6-migration-et-importation-sur-une-autre-machine)
7. [Astuces et sécurité (Sauvegarde, Agent GPG)](#7-astuces-et-sécurité)

---

## 1. Installation de `pass` et de GnuPG

Pour commencer, vous devez installer `pass` et l'outil de chiffrement `gnupg` sur votre système.

### Sur macOS
La méthode la plus simple consiste à utiliser **Homebrew** :
```bash
brew install gnupg pass
```

### Sur Linux (Debian / Ubuntu)
```bash
sudo apt update
sudo apt install gnupg pass git
```

### Sur Linux (Arch Linux)
```bash
sudo pacman -S gnupg pass git
```

---

## 2. Création et configuration de votre clé GPG

Puisque `pass` utilise GPG pour chiffrer vos données, vous avez impérativement besoin d'une paire de clés (publique et privée).

### Étape 2.1 : Générer la clé
Exécutez la commande suivante pour lancer l'assistant interactif :
```bash
gpg --full-generate-key
```

Suivez les instructions à l'écran :
1. **Sélection du type de clé** : Choisissez `(1) RSA and RSA (default)` (ou ECC si vous préférez une clé plus moderne et rapide).
2. **Taille de la clé** : Saisissez `4096` bits pour une sécurité maximale.
3. **Durée de validité** : Choisissez la durée de votre choix (par exemple `0` pour qu'elle n'expire jamais, ou `2y` pour 2 ans).
4. **Identité** : Saisissez votre nom réel et votre adresse e-mail. Ces informations lieront la clé à votre identité.
5. **Passphrase** : **IMPORTANT !** Saisissez un mot de passe extrêmement robuste. C'est la clé de voûte de votre sécurité. Si vous perdez cette passphrase, vous perdrez définitivement l'accès à vos mots de passe.

### Étape 2.2 : Récupérer l'identifiant (ID) de votre clé
Une fois la clé créée, vous devez lister vos clés privées pour obtenir son identifiant unique :
```bash
gpg --list-secret-keys --keyid-format LONG
```

L'output ressemblera à ceci :
```text
sec   rsa4096/3AA5C34371567BD2 2026-07-15 [SC] [expire : 2028-07-14]
      6F2D87B409E2B2A34A6F1D5D3AA5C34371567BD2
uid           [ultime] Jean Dupont <jean.dupont@example.com>
ssb   rsa4096/2BB6D45482678CE3 2026-07-15 [E] [expire : 2028-07-14]
```

> [!TIP]
> Votre identifiant de clé GPG est la suite de caractères située après l'algorithme (ici **`3AA5C34371567BD2`** sur la première ligne). Vous pouvez aussi utiliser l'adresse e-mail associée à la clé (`jean.dupont@example.com`).

---

## 3. Initialisation de `pass`

Maintenant que vous possédez une clé GPG, vous pouvez initialiser votre coffre-fort de mots de passe.

Exécutez la commande suivante en remplaçant l'ID par le vôtre (ou votre e-mail) :
```bash
pass init 3AA5C34371567BD2
```

**Ce que fait cette commande :**
- Elle crée un dossier caché `~/.password-store` dans votre répertoire personnel.
- Elle y dépose un fichier caché `.gpg-id` contenant l'ID de la clé GPG utilisée pour chiffrer les futurs mots de passe.

---

## 4. Utilisation quotidienne

Voici les commandes essentielles pour gérer vos identifiants au quotidien.

### 4.1. Insérer un mot de passe manuellement
Pour stocker un mot de passe (par exemple pour votre compte GitHub sous l'identifiant `mon_username`) :
```bash
pass insert developpement/github
```
Le terminal vous demandera de saisir le mot de passe deux fois (saisie masquée).

> [!NOTE]
> `pass` accepte le stockage multi-ligne (utile pour stocker des notes, des codes de récupération ou des questions de sécurité). Utilisez l'option `-m` :
> ```bash
> pass insert -m developpement/github
> ```
> Saisissez vos lignes, puis terminez avec la combinaison de touches `Ctrl+D`.

### 4.2. Générer un mot de passe automatiquement
Si vous voulez que `pass` génère un mot de passe fort et aléatoire (par exemple de 20 caractères sans symboles étranges, pour un compte Amazon) :
```bash
pass generate shopping/amazon 20
```
*(Ajoutez `-n` à la fin si vous ne voulez aucun caractère spécial, uniquement des lettres et chiffres).*

### 4.3. Lister vos mots de passe
Pour visualiser l'arborescence complète de votre coffre :
```bash
pass
```
L'arborescence s'affichera sous cette forme :
```text
Password Store
├── developpement
│   └── github
└── shopping
    └── amazon
```

### 4.4. Afficher et copier un mot de passe
* **Pour l'afficher dans le terminal** (demande votre passphrase GPG) :
  ```bash
  pass developpement/github
  ```
* **Pour le copier directement dans votre presse-papiers** (il s'effacera automatiquement au bout de 45 secondes pour des raisons de sécurité) :
  ```bash
  pass -c developpement/github
  ```

### 4.5. Modifier ou supprimer un élément
* **Modifier** le contenu d'une fiche existante (ouvre votre éditeur de texte par défaut comme Vim ou Nano) :
  ```bash
  pass edit developpement/github
  ```
* **Supprimer** un mot de passe :
  ```bash
  pass rm developpement/github
  ```

---

## 5. Synchronisation avec Git

L'un des plus grands atouts de `pass` est son intégration native avec Git. Chaque ajout, modification ou suppression génère automatiquement un commit Git.

### Étape 5.1 : Initialiser le dépôt Git
```bash
pass git init
```

### Étape 5.2 : Lier un dépôt distant (GitHub, GitLab, serveur privé...)
Créez un dépôt **privé** sur votre hébergeur de code préféré (ex: GitHub), puis associez-le à votre coffre-fort :
```bash
pass git remote add origin git@github.com:votre_pseudo/mon-password-store.git
```

> [!CAUTION]
> **VOTRE DÉPÔT GIT DISTANT DOIT ÊTRE STRICTEMENT PRIVÉ.** Bien que vos mots de passe soient chiffrés individuellement et incassables sans votre clé privée GPG, publier la structure de vos dossiers et les métadonnées de vos comptes publiquement pose un risque sérieux pour votre vie privée.

### Étape 5.3 : Envoyer vos données vers le serveur (Push)
Pour votre premier envoi, configurez la branche par défaut (généralement `master` ou `main`) :
```bash
pass git push -u origin master
```

### Étape 5.4 : Synchronisation au quotidien
Chaque fois que vous modifiez vos mots de passe, `pass` crée un commit automatique. Pour envoyer et récupérer les modifications :
```bash
pass git push
pass git pull
```

---

## 6. Migration et importation sur une autre machine

Vous avez un nouvel ordinateur et vous voulez y récupérer vos mots de passe ? Voici la procédure pas à pas.

### Étape 6.1 : Depuis la machine d'origine (Export de la clé GPG)
Pour déchiffrer vos mots de passe sur la nouvelle machine, vous devez y transférer votre clé GPG.

1. **Trouvez l'ID de votre clé** : `gpg --list-secret-keys --keyid-format LONG`.
2. **Exportez la clé publique** :
   ```bash
   gpg --export -a 3AA5C34371567BD2 > mon_gpg_public.asc
   ```
3. **Exportez la clé privée** :
   ```bash
   gpg --export-secret-keys -a 3AA5C34371567BD2 > mon_gpg_prive.asc
   ```

> [!WARNING]
> Transférez le fichier `mon_gpg_prive.asc` vers votre nouvelle machine de manière extrêmement sécurisée (par exemple via une clé USB physique que vous effacerez ensuite). **Ne stockez jamais ce fichier non chiffré sur un cloud public.**

---

### Étape 6.2 : Sur la nouvelle machine (Import et Configuration)

1. **Installez les prérequis** : `pass`, `gnupg` et `git` (voir [Étape 1](#1-installation-de-pass-et-de-gnupg)).
2. **Importez vos clés GPG** :
   ```bash
   gpg --import mon_gpg_public.asc
   gpg --import mon_gpg_prive.asc
   ```

   > [!IMPORTANT]
   > **Nettoyage et sécurité post-importation :**
   > Une fois l'importation réussie, GnuPG a enregistré vos clés de manière sécurisée dans son propre dossier interne (`~/.gnupg/`). Le fichier d'importation `mon_gpg_prive.asc` n'est plus nécessaire.
   > Vous devez **impérativement supprimer les fichiers d'importation `.asc`** de votre support de transfert (clé USB, téléchargements) pour éviter que votre clé privée ne fuite.
   > 
   > Pour les supprimer définitivement et de manière sécurisée (par écrasement physique) :
   > * **Sur macOS :**
   >   ```bash
   >   rm -P mon_gpg_prive.asc mon_gpg_public.asc
   >   ```
   > * **Sur Linux :**
   >   ```bash
   >   shred -u mon_gpg_prive.asc mon_gpg_public.asc
   >   ```
3. **Définissez la confiance de votre clé importée** :
   Par défaut, GnuPG n'accorde pas sa confiance aux clés importées. Vous devez lui attribuer explicitement une "confiance ultime" :
   - Lancez l'édition de la clé :
     ```bash
     gpg --edit-key 3AA5C34371567BD2
     ```
   - Dans l'invite interactive de GPG, saisissez :
     ```text
     gpg> trust
     ```
   - Choisissez l'option **`5`** (`I trust ultimately` / `Je fais confiance ultimement`).
   - Confirmez en saisissant **`y`** (Oui).
   - Quittez l'invite :
     ```text
     gpg> quit
     ```

4. **Clonez votre dépôt Git de mots de passe** :
   Clonez le dépôt distant directement dans le dossier attendu par `pass` (le dossier `~/.password-store`) :
   ```bash
   git clone git@github.com:votre_pseudo/mon-password-store.git ~/.password-store
   ```

5. **Testez que tout fonctionne** :
   Saisissez simplement :
   ```bash
   pass
   ```
   Vous devriez voir toute votre arborescence ! Essayez d'en lire un :
   ```bash
   pass developpement/github
   ```
   Votre système vous demandera la passphrase de votre clé GPG, puis affichera votre mot de passe décrypté.

---

## 7. Astuces et sécurité

### 7.1. Configurer un GPG Agent (éviter de saisir la passphrase à chaque fois)
Saisir sa longue passphrase GPG à chaque fois qu'on lit un mot de passe peut être fastidieux. Vous pouvez configurez `gpg-agent` pour qu'il garde la clé en mémoire pendant quelques heures.

Créez ou modifiez le fichier `~/.gnupg/gpg-agent.conf` :
```text
# Conserver la passphrase en mémoire pendant 2 heures (7200 secondes)
default-cache-ttl 7200
max-cache-ttl 86400
```
Puis redémarrez l'agent GPG :
```bash
gpgconf --kill gpg-agent
```

### 7.2. Autocomplétion dans le terminal
`pass` est livré avec d'excellents scripts d'autocomplétion pour **Bash**, **Zsh** et **Fish**. 
Si vous utilisez **Zsh** (par exemple par défaut sur macOS), assurez-vous d'avoir activé `compinit` dans votre fichier `~/.zshrc` :
```bash
autoload -Uz compinit && compinit
```
Désormais, taper `pass dev` puis appuyer sur `Tab` complétera automatiquement vers `pass developpement/`.

### 7.3. Intégration Navigateur (PassFF)
Vous pouvez remplir automatiquement vos mots de passe dans Firefox ou Chrome en installant :
1. L'extension de navigateur **PassFF**.
2. L'application hôte locale d'accompagnement (host app) : `passff-host` (disponible via Homebrew ou les gestionnaires de paquets Linux).

---

> [!NOTE]
> Nettoyez bien vos fichiers de clés exportés (`.asc`) de vos supports temporaires (comme vos clés USB) après la migration pour éviter toute fuite accidentelle de votre clé privée !
