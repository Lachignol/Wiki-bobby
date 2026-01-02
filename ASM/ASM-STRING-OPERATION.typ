#set page(paper: "a4", margin: 2cm)
#set heading(numbering: "1.")

= Fonction `strlen` en Assembleur x86-64

#linebreak()
[Implémentation `strlen` avec REPNE x86-64 la plus simple],


```asm
section .text
global my_strlen

my_strlen:
push rdi ; Sauve adresse début chaîne
mov rcx, -1 ; Compteur illimité
xor eax, eax ; AL = 0 (cherche \0)
cld ; Direction avant (inc RDI)
repne scasb ; Scan automatique jusqu'à \0 !
pop rax ; RAX = début chaîne
sub rdi, rax ; RDI - début = pos après \0
mov rax, rdi
dec rax ; Longueur exacte (ignore \0)
ret
```

== Principe 
L'instruction `repne scasb` est magique : elle scanne la mémoire
automatiquement en comparant *AL* (=0) avec chaque octet pointed par *RDI*.

#figure(
table(
columns: (1fr, 1fr, 1fr, 1fr, 1fr),
[*Étape*], [*RDI*], [*[RDI]*], [*Action*], [*ZF*],
[Start], [0], [`'t'`], [--], [--],
[It1], [1], [`'e'`], [cmp !=0, RDI++, RCX--], [0],
[It4], [4], [`\0`], [cmp ==0, *STOP* après RDI=5], [1],
),
caption: [Exécution sur "test\0" (len=4)],
)

*Après repne* : RDI pointe *après* le `\0`, soustraction donne longueur.

== Registres
- *RDI* : Pointeur mémoire (avancé auto)
- *RCX* : `-1` = illimité
- *AL* : 0 (fin chaîne)
- *Retour* : RAX

== Avantages
+ Ultra simple (5 instructions clés)
+ Optimisée hardware
+ Utilisée par glibc


= Opérations sur Chaînes x86-64 : REP Instructions 


== Introduction

Les instructions *string operations* avec `REP` remplacent des boucles entières !

#columns(2)[
*Registres obligatoires :*
- `RDI` : Destination
- `RSI` : Source
- `RCX` : Compteur (`-1` = illimité)
- `AL` : Valeur constante
- `DF` : Direction (`cld` = ++)
]

== Les 4 Opérations Fondamentales

#figure(
table(
columns: (2fr, 1fr, 1fr, 1fr, 2fr, 2fr),
align: (center, center, center, center, center, center),
[*Instruction*], [*Action*], [*Source*], [*Dest*], [*Préfixe*], [*Fonction*],
`movsb`, [Copie byte], `RSI++`, `RDI++`, `rep`, `memcpy`,
`cmpsb`, [Compare byte], `RSI++`, `RDI++`, `repe`, `strcmp`,
`scasb`, [Scan byte], `AL`, `RDI++`, `repne`, `strlen`,
`stosb`, [Remplit byte], `AL`, `RDI++`, `rep`, `memset`,
),
caption: [Les 4 instructions string x86-64],
)

== 1. Copie : `rep movsb` (memcpy)

```asm
; RDI=dest, RSI=src, RCX=longueur
my_memcpy:
cld
rep movsb ; 1 ligne = boucle entière !
ret ; RDI = nouvelle position
```
Exécution : Copie `RCX` bytes de `[RSI++]` vers `[RDI++]`.

== 2. Scan : `repne scasb` (strlen)

```asm
; RDI=chaîne terminée par 0my_strlen:
push rdi ; Sauve début
mov rcx, -1 ; Illimité
xor eax, eax ; AL=0
cld
repne scasb ; Avance RDI jusqu'après \0
pop rax ; Début
sub rdi, rax ; Distance
dec rax ; Ignore \0
ret ; RAX=longueur
```

== 3. Compare : `repe cmpsb` (strcmp)


```asm
; RDI=str1, RSI=str2my_strcmp:
mov rcx, -1
xor eax, eax
cld
repe cmpsb ; Compare jusqu'à différent
; Après arrêt : RDI/RSI sur 1er byte différent
movzx rax, byte[rdi-1]
sub al, [rsi-1]
movsx rax, al ; RAX = signe(str1-str2)
ret
```
Retour :
- `RAX < 0` : str1 < str2
- `RAX > 0` : str1 > str2
- `RAX = 0` : égales


#pagebreak()
== 4. Remplissage : `rep stosb` (memset)

```asm
; RDI=dest, AL=valeur, RCX=longueurmy_memset:
cld
rep stosb ; AL → [RDI++] x RCX
ret
```
// Pour bzero : `xor al, al; call memset`
== Programme Test Complet

```asm
section .datasrc db "Hello World", 0
dest times 20 db 0
nl db 10, 0

section .text
global _start

_start:
; 1. strlen
mov rdi, src
call my_strlen ; RAX=11

; 2. memcpy
mov rdi, dest
mov rsi, src
mov rcx, rax
call my_memcpy

; 3. memset (padding)
mov rdi, dest+11
mov al, '!'
mov rcx, 9
call my_memset ; "Hello World!!!!!!!!"

; 4. strcmp (test égalité)
mov rdi, src
mov rsi, dest
call my_strcmp ; RAX=0 si OK

mov rax, 60 ; exit
xor rdi, rdi
syscall
```

== Variantes Avancées
#columns(2)[

#figure(table(
columns: 3,
[*Taille*], [*Registre*], [*Suffixe*],
[8-bit], `AL`, `b`,
[16-bit], `AX`, `w`,
[32-bit], `EAX`, `d`,
[64-bit], `RAX`, `q`,
),
)

Exemples :
• `rep movsq` : copie 64-bit
• `repne scasq` : scan 64-bit
]

#pagebreak()
== Direction Arrière

std ; -- au lieu de ++repne scasb ; RDI-- jusqu'à \0
; RDI pointe SUR le \0
cld ; Remets normal

== Performance & Usage#figure(
table(
columns: 2,
[Avantage], [Limite],
[1 instr = boucle], [RCX 64-bit max],
[Hardware optimisé], [Pas SIMD],
[glibc utilise], [Setup registres],
),
caption: [Bilan],
)
Utilisation réelle : Base de `memcpy`, `memset`, `strlen` en libc !
