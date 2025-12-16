= ASM

== Syntaxe AT&T
Moins lisible : usage de `%,$` etc.

== Syntaxe Intel
Plus lisible et proche du langage machine naturel.

= Sections mémoire


- *BSS* : variables globales non initialisées ou initialisées à zéro.
- *RODATA* : données en lecture seule (constantes, chaînes).
- *DATA* : variables globales initialisées.
- *TEXT* : code exécutable (fonctions, étiquettes).

=== BSS
Stocke les variables globales ou statiques non initialisées.  
Initialisée à zéro par le système, sans occuper de place dans le binaire.

```c
int age;
char buffer[256];
```

=== RODATA
Contient les données constantes ou chaînes littérales.
Protégé contre l’écriture pour éviter toute modification accidentelle.

ex :
```c
int age = 1337;
char buffer[] = "Hello world";
```

=== DATA
Contient les variables globales initialisées avec une valeur non nulle.
Modifiable en exécution contrairement à .rodata.

ex :
```c
int age = 1337;
char buffer[] = "Hello";
```

=== TEXT
Section du code exécutable contenant fonctions, étiquettes et instructions.
Lecture/Exécution, non modifiable.

Exemples : fonctions, labels, instructions diverses.
\
\
\
\
\
\
\
= Schéma ASM pur
=== ASM pur (sans libc)

#raw("
adresses basses ↑ adresses hautes
┌─────────────────┐
│     .text       │ Code (MOV,JMP,CALL...)
├─────────────────┤
│    .rodata      │ Constantes (DB \"hello\")
├─────────────────┤
│     .data       │ Données init (DD 42)
├─────────────────┤
│     .bss        │ Données non init (RESB 256→0)
├─────────────────┤
│      heap       │ brk/mmap manuel (optionnel)
│   (↑croît)      │
├─────────────────┤
│     ...         │
├─────────────────┤
│     stack       │ RSP/RBP (PUSH/CALL ↓descend)
│   (↓descend)    │
└─────────────────┘
")

ASM : contrôles sur tout. Heap/stack = syscalls manuelles.

=== Schéma C normal (avec libc)

#raw("
adresses basses ↑ adresses hautes
┌─────────────────┐
│     .text       │ Code compilé (fonctions)
├─────────────────┤
│    .rodata      │ Strings, const (printf(\"hello\"))
├─────────────────┤
│     .data       │ Globals init (int x=42;)
├─────────────────┤
│     .bss        │ Globals non init (int y;)
├─────────────────┤
│   libc/.got/... │ Libc, PLT, GOT (appels dynamiques)
├─────────────────┤
│      heap       │ malloc(), calloc() (glibc gère)
│   (↑croît)      │
├─────────────────┤
│ mmap(anon)...   │ Allocs dynamiques hautes
├─────────────────┤
│     ...         │
├─────────────────┤
│     stack       │ Variables locales, argc/argv
│   (↓descend)    │
└─────────────────┘
")

C : runtime libc + crt0 initialisent stack/heap.
Plus de sections (GOT, PLT) pour les appels dynamiques.
\
\
\

= REGISTRES CPU

ESPACE memoire sur le cpu lui meme qui pointe ver une valeur (stock des donnees)

#raw("
64 bits              32 bits         16 bits

rax         |           eax     |       ax
rdi         |           edx     |       bx
rsi         |           ecx     |       cx
rdx         |           ebx     |       dx
")

= INSTRUCTIONS CLEF

== MOV
Transfère une valeur dans un registre.

- mov <destination> , <source>

ex :
```asm
mov rax, 45
```
== SYSCALL
Appel au kernel. Différent selon architecture (ELF32/64, PE32/64).

== DB, DW, DD

DB : define byte (1 octet)

DW : define word (2 octets)

DD : define double word (4 octets)


== RES(X) --> RESERVED

RESB : Reserved 1 byte (1 octet == 8 bits)

ex:
```asm
section .bss
    example resb 25         ;Syntaxe basique
    example times 25 resb 1 ;Syntaxe differente ( en gros on dit de repeter 25 fois cette instruction):
```

RESW : Reserved 2 bytes (word) (2 octets == 16 bits)

RESD : Reserved 4 bytes (double word) (4 octets == 32 bits)

RESQ : Reserved 8 bytes (quadruple word) (8 octets == 64 bits)

== EQU (equal)

Directive qui sert a definir une constante

ex:
```asm
section .data
    msg db "voici une chaine" , 10 <= (char '\n')
    MSG_LENGTH equ $-msg
    STD_OUTPUT equ 1
    TRUE equ 1
```


== ECRITURE SELON LA BASE

d ou t :decimal ---> 5, 05, 0150d, 0d150
q ou o :octal   ---> 755q, 0q755
b ou y :binaire ---> 0b110111101 , 0b1101_1101, 1101_1100b
h ou x :hexa    ---> 0xA5 , 0A5h

== Étiquettes
Permettent de créer des points de saut (jmp).

```asm
nomEtiquette:
    jmp nomNouvelleEtiquette

nomNouvelleEtiquette:
    blablalabla
```


== OPERATEURS MATHEMATIQUE


=== ADD
Additionne deux valeurs.


```asm
mov rax, 789
add rax, 1337   ; rax = 2126
```

=== SUB
Soustraction.

```asm
mov rax, 789
sub rax, 1337   ; rax = -548
```

\
=== DIV
Division.

```asm
mov rax, 1337
mov rdi, 50
div rdi ; rax = quotient, rdx = reste
```

=== MUL
Multiplication.

```asm
mov rax, 1337
mov rdi, 50
mul rdi; rax = 66850
```

=== Exemple combiné

```asm
mov rax, 1337
mov rdi, 50
mul rdi
add rax, 1337; rax = 68187
```

== STACK

=== PUSH
Pousse une valeur sur la pile.


```asm
mov rax, 45
push rax
```

=== POP
Retire une valeur de la pile.

```asm
mov rax, 45
pop rdi
```

== CONDITIONS

=== CMP
Compare un registre avec une valeur.

```asm
cmp <register>, <value>
```
== Flags et jumps

=== Non signés

- JE : égal
- JA : supérieur
- JAE : supérieur ou égal
- JB : inférieur
- JBE : inférieur ou égal

=== Signés

- JG : supérieur
- JGE : supérieur ou égal
- JL : inférieur
- JLE : inférieur ou égal

=== Spécifiques

- JC : retenue générée
- JO : overflow
- JZ : zéro
- JS : négatif

== Versions inverses

Pour toutes ces instructions, il existe une version inverse.
ex :

```asm
jne   ; jump if not equal
```


