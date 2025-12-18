= Debugging d'un programme ASM ELF64 avec GDB (Syntaxe Intel)
\
== Introduction
Ce tutoriel explique comment créer, compiler et déboguer un programme *ASM ELF64* avec *GDB*, en utilisant la *syntaxe Intel*. 
Nous allons utiliser `nasm` pour l'assemblage et `ld` pour l'édition de liens.

\
== 1. Préparer un fichier ASM simple

Créons un fichier `hello.asm` :

```asm
section .data
    msg db "Hello, GDB!", 0Ah  ; message avec saut de ligne
    len equ $ - msg            ; longueur du message

section .text
    global _start

_start:
    mov rax, 1        ; syscall: sys_write
    mov rdi, 1        ; file descriptor: stdout
    mov rsi, msg      ; adresse du message
    mov rdx, len      ; longueur du message
    syscall           ; appel système

    mov rax, 60       ; syscall: sys_exit
    xor rdi, rdi      ; code de retour 0
    syscall
```
\
== 2. Compiler et lier

Pour assembler et lier le programme, on utilise nasm et ld :

```sh
nasm -f elf64 -g -F dwarf -o hello.o hello.asm
ld hello.o -o prog
```
- -g : active le debug.

- -F dwarf : génère les informations de debug au format DWARF.

- -f elf64 : format 64 bits.

- ld : crée l'exécutable ELF64.

Avec ces options, GDB pourra afficher le code source avec des symboles et lignes, pas seulement les adresses.

\
\
\
\
\

== 3. Lancer GDB et configurer l’affichage split

Pour déboguer l'exécutable :

```sh
gdb ./prog
```

```sh
(gdb) layout split
```

- layout split : divise l’écran en deux panneaux.
- En haut : source ou désassemblage.
- En bas : console GDB.
- Pour afficher automatiquement le contenu des registres à chaque étape :

#raw("
(gdb) display /x $rax
(gdb) display /x $rbx
(gdb) display /x $rcx
")

- display : montre automatiquement la valeur d’une expression à chaque step ou next.

- /x : format hexadécimal (pratique pour ASM).
Une fois dans GDB, tu peux utiliser les commandes suivantes.

== 4. Commandes de base GDB

- file ./hello : charger l'exécutable.
- break `_start` : placer un point d'arrêt au début.
- run : exécuter le programme.
- disassemble : voir le code assembleur autour de l'adresse actuelle.
- stepi ou si : exécuter une instruction à la fois.
- info registers : afficher le contenu des registres.
- x/10i `$rip` : examiner 10 instructions à partir de l'instruction courante.
- print `$rax` : afficher la valeur du registre RAX.

== 5. Exemple de session GDB

#raw("
(gdb) break _start
Breakpoint 1 at 0x400080
(gdb) run
Starting program: ./hello

Breakpoint 1, _start ()
(gdb) info registers
RAX            0x0 0
RBX            0x0 0
...
(gdb) stepi
(gdb) x/5i `$rip`
")


Tu peux répéter stepi pour exécuter instruction par instruction et observer l'effet sur les registres.
\
\
\
\
\

== 5. Exemple de session GDB avec display et layout
#raw("
(gdb) break _start
Breakpoint 1 at 0x400080
(gdb) run
Starting program: ./hello

Breakpoint 1, _start ()
(gdb) layout split
(gdb) display /x $rax
(gdb) display /x $rdi
(gdb) display /x $rsi
(gdb) stepi
(gdb) stepi
")


Chaque instruction exécutée mettra automatiquement à jour les registres affichés en bas, et le code reste visible en haut grâce à layout split.

== 6. Conseils pour le débogage ASM

- Nommer les sections correctement : .data pour les données, .text pour le code.
- Placer des labels : `_start` ou loop: pour pouvoir mettre des breakpoints.
- Vérifier les registres après chaque instruction : info registers.
- Examiner la mémoire : x/10xb address pour 10 octets en hexadécimal.
- Debugger syscall : vérifier rax avant et après syscall.
- Utiliser -g -F dwarf pour les programmes ASM complexes.
- display pour surveiller automatiquement les registres clés (rax, rbx, rip, etc.).
- layout split pour voir le code et la console en simultané.
