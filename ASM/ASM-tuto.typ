// --- Configuration du document ---
#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
  numbering: "1"
)
#set text(
  font: "Linux Libertine",
  lang: "fr",
  size: 11pt
)
#set heading(numbering: "1.1.")
#show heading: it => block(above: 1.5em, below: 1em, it)

// --- Styles pour le code et les blocs ---
#let codebox(body) = block(
  fill: luma(245),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  stroke: luma(200) + 0.5pt,
  text(font: "Fira Code", size: 9pt, body)
)

#let diagram(body) = align(center)[
  #block(
    fill: luma(250),
    inset: 10pt,
    radius: 4pt,
    stroke: luma(200) + 0.5pt,
    text(font: "Fira Code", size: 8pt, body)
  )
]

// --- Titre ---
#align(center)[
  #text(size: 24pt, weight: "bold")[Tutoriel Complet : Assembleur x86-64 ELF64 (Syntaxe Intel)]
  #v(1em)
  #line(length: 100%, stroke: 0.5pt)
]

// --- Table des matières ---
#outline(indent: auto, depth: 2)
#pagebreak()

= 1. Introduction et concepts fondamentaux

== 1.1 Architecture x86-64

L'architecture x86-64 (aussi appelée AMD64 ou Intel 64) est une extension 64 bits de l'architecture x86. Elle offre :

- *Registres 64 bits* : Extension des registres existants
- *Espace d'adressage étendu* : Jusqu'à $2^64$ octets théoriques
- *Plus de registres* : 16 registres généraux au lieu de 8
- *Mode long* : Mode natif 64 bits

== 1.2 Format ELF64

Le format ELF (Executable and Linkable Format) est le format standard sous Linux pour :
- Exécutables
- Bibliothèques partagées
- Fichiers objets

== 1.3 Syntaxe Intel vs AT&T

#codebox(raw("
; Syntaxe Intel (celle que nous utiliserons)
mov rax, 42          ; destination, source
add rax, rbx

; Syntaxe AT&T (pour référence)
movq $42, %rax       ; source, destination (avec préfixes)
addq %rbx, %rax
", lang: "nasm"))

*Avantages de la syntaxe Intel :*
- Plus intuitive (destination à gauche)
- Pas de préfixes % et `$`
- Plus lisible

#line(length: 100%, stroke: 0.5pt)

= 2. Registres x86-64

== 2.1 Registres généraux

#diagram(raw("
┌─────────────────────────────────────────────────────────┐
│                    64 bits (RAX)                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │              32 bits (EAX)                       │   │
│  │  ┌───────────────────────────────┐               │   │
│  │  │     16 bits (AX)              │               │   │
│  │  │  ┌──────────┬──────────┐      │               │   │
│  │  │  │ AH (8b)  │ AL (8b)  │      │               │   │
│  │  │  └──────────┴──────────┘      │               │   │
│  │  └───────────────────────────────┘               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
"))

== 2.2 Les 16 registres généraux

#table(
  columns: (auto, auto, auto, auto, auto, 2fr),
  inset: 5pt,
  fill: (col, row) => if row == 0 { luma(230) } else { white },
  [*Registre 64b*], [*32b*], [*16b*], [*8b haute*], [*8b basse*], [*Usage conventionnel*],
  [RAX], [EAX], [AX], [AH], [AL], [Accumulateur, valeur de retour],
  [RBX], [EBX], [BX], [BH], [BL], [Base (préservé)],
  [RCX], [ECX], [CX], [CH], [CL], [Compteur, 4ème argument],
  [RDX], [EDX], [DX], [DH], [DL], [Données, 3ème argument],
  [RSI], [ESI], [SI], [-], [SIL], [Source index, 2ème argument],
  [RDI], [EDI], [DI], [-], [DIL], [Destination index, 1er argument],
  [RBP], [EBP], [BP], [-], [BPL], [Base pointer (préservé)],
  [RSP], [ESP], [SP], [-], [SPL], [Stack pointer],
  [R8], [R8D], [R8W], [-], [R8B], [5ème argument],
  [R9], [R9D], [R9W], [-], [R9B], [6ème argument],
  [R10], [R10D], [R10W], [-], [R10B], [Temporaire],
  [R11], [R11D], [R11W], [-], [R11B], [Temporaire],
  [R12], [R12D], [R12W], [-], [R12B], [Préservé],
  [R13], [R13D], [R13W], [-], [R13B], [Préservé],
  [R14], [R14D], [R14W], [-], [R14B], [Préservé],
  [R15], [R15D], [R15W], [-], [R15B], [Préservé],
)

== 2.3 Registres spéciaux

#table(
  columns: (auto, 1fr),
  inset: 5pt,
  fill: (col, row) => if row == 0 { luma(230) } else { white },
  [*Registre*], [*Description*],
  [*RIP*], [Instruction Pointer (pointeur d'instruction)],
  [*RFLAGS*], [Registre de flags (ZF, CF, SF, OF, etc.)],
)

== 2.4 Flags principaux

#codebox(raw("
RFLAGS (64 bits)
┌────┬────┬────┬────┬────┬────┬────┬────┐
│ OF │ SF │ ZF │ AF │ PF │ CF │ .. │ .. │
└────┴────┴────┴────┴────┴────┴────┴────┘

CF (Carry)     : Retenue/emprunt arithmétique
PF (Parity)    : Parité du résultat
AF (Auxiliary) : Retenue auxiliaire (BCD)
ZF (Zero)      : Résultat nul
SF (Sign)      : Signe du résultat
OF (Overflow)  : Dépassement signé
"))

#line(length: 100%, stroke: 0.5pt)

= 3. Modes d'adressage

== 3.1 Adressage immédiat

#codebox(raw("
mov rax, 42          ; Charge la valeur 42 dans rax
mov rbx, 0x1000      ; Charge 0x1000 dans rbx
", lang: "nasm"))

== 3.2 Adressage registre

#codebox(raw("
mov rax, rbx         ; Copie rbx dans rax
add rcx, rdx         ; rcx = rcx + rdx
", lang: "nasm"))

== 3.3 Adressage mémoire direct

#codebox(raw("
mov rax, [var]       ; Charge depuis l'adresse de var
mov [var], rbx       ; Stocke rbx à l'adresse de var
", lang: "nasm"))

== 3.4 Adressage indirect par registre

#codebox(raw("
mov rax, [rbx]       ; Charge depuis l'adresse contenue dans rbx
mov [rcx], rdx       ; Stocke rdx à l'adresse contenue dans rcx
", lang: "nasm"))

== 3.5 Adressage avec déplacement

#codebox(raw("
mov rax, [rbx + 8]   ; Charge depuis rbx + 8 octets
mov [rsp - 16], rcx  ; Stocke à rsp - 16 octets
", lang: "nasm"))

== 3.6 Adressage avec base + index

#codebox(raw("
mov rax, [rbx + rcx]         ; base + index
mov rax, [rbx + rcx * 4]     ; base + index * échelle
mov rax, [rbx + rcx * 8 + 16] ; base + index * échelle + déplacement
", lang: "nasm"))

*Format général :*
```
[base + index * scale + displacement]

scale : 1, 2, 4, ou 8
```

== 3.7 Adressage relatif à RIP

#codebox(raw("
mov rax, [rel variable]    ; Adressage relatif à RIP (position-independent)
lea rax, [rel variable]    ; Charge l'adresse relative
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 4. Instructions de base

== 4.1 Transfert de données

=== MOV - Mouvement de données

#codebox(raw("
mov destination, source

mov rax, 42           ; Immédiat vers registre
mov rax, rbx          ; Registre vers registre
mov rax, [rbx]        ; Mémoire vers registre
mov [rax], rbx        ; Registre vers mémoire
mov qword [rax], 42   ; Immédiat vers mémoire (avec taille)
", lang: "nasm"))

*Tailles :*
#codebox(raw("
mov al, 0x12          ; 8 bits
mov ax, 0x1234        ; 16 bits
mov eax, 0x12345678   ; 32 bits (met à zéro les 32 bits hauts)
mov rax, 0x123456789ABCDEF0 ; 64 bits
", lang: "nasm"))

=== MOVSX / MOVZX - Mouvement avec extension

#codebox(raw("
movsx rax, bl         ; Extension de signe (8->64)
movsx rax, bx         ; Extension de signe (16->64)
movsxd rax, ebx       ; Extension de signe (32->64)

movzx rax, bl         ; Extension avec zéros (8->64)
movzx rax, bx         ; Extension avec zéros (16->64)
", lang: "nasm"))

=== LEA - Load Effective Address

#codebox(raw("
lea rax, [rbx + rcx * 4 + 8]  ; Calcule l'adresse sans déréférencer

; Exemple d'utilisation pour calcul arithmétique
lea rax, [rdi + rdi * 2]      ; rax = rdi * 3
lea rax, [rdi + rdi * 4]      ; rax = rdi * 5
", lang: "nasm"))

=== XCHG - Échange

#codebox(raw("
xchg rax, rbx         ; Échange rax et rbx (atomique)
xchg [mem], rax       ; Échange mémoire et registre
", lang: "nasm"))

== 4.2 Opérations arithmétiques

=== ADD / SUB - Addition / Soustraction

#codebox(raw("
add rax, rbx          ; rax = rax + rbx
add rax, 10           ; rax = rax + 10
sub rax, rbx          ; rax = rax - rbx
sub rax, 5            ; rax = rax - 5
", lang: "nasm"))

=== INC / DEC - Incrément / Décrément

#codebox(raw("
inc rax               ; rax = rax + 1
dec rbx               ; rbx = rbx - 1
", lang: "nasm"))

=== MUL / IMUL - Multiplication

#codebox(raw("
; Multiplication non signée (MUL)
mul rbx               ; rdx:rax = rax * rbx (128 bits)

; Multiplication signée (IMUL)
imul rbx              ; rdx:rax = rax * rbx
imul rax, rbx         ; rax = rax * rbx (2 opérandes)
imul rax, rbx, 10     ; rax = rbx * 10 (3 opérandes)
", lang: "nasm"))

=== DIV / IDIV - Division

#codebox(raw("
; Division non signée
mov rdx, 0            ; Partie haute du dividende
mov rax, 100          ; Partie basse du dividende
mov rbx, 7
div rbx               ; rax = quotient, rdx = reste

; Division signée
cqo                   ; Étend rax en rdx:rax (signe)
idiv rbx              ; Division signée
", lang: "nasm"))

=== NEG - Négation

#codebox(raw("
neg rax               ; rax = -rax (complément à deux)
", lang: "nasm"))

== 4.3 Opérations logiques

=== AND / OR / XOR

#codebox(raw("
and rax, rbx          ; ET logique
or  rax, rbx          ; OU logique
xor rax, rbx          ; OU exclusif

xor rax, rax          ; Idiome pour mettre à zéro (plus rapide que mov rax, 0)
", lang: "nasm"))

=== NOT

#codebox(raw("
not rax               ; Complément à un
", lang: "nasm"))

=== TEST

#codebox(raw("
test rax, rbx         ; AND logique sans modifier les opérandes (met à jour flags)
test rax, rax         ; Teste si rax est zéro
", lang: "nasm"))

=== CMP - Comparaison

#codebox(raw("
cmp rax, rbx          ; Effectue rax - rbx et met à jour les flags
cmp rax, 42           ; Compare avec une valeur immédiate
", lang: "nasm"))

== 4.4 Décalages et rotations

=== Décalages logiques

#codebox(raw("
shl rax, 1            ; Shift left (décalage gauche)
shr rax, 1            ; Shift right (décalage droite, bits hauts à 0)

shl rax, cl           ; Décalage de cl positions
shr rax, cl
", lang: "nasm"))

=== Décalages arithmétiques

#codebox(raw("
sal rax, 1            ; Shift arithmetic left (identique à shl)
sar rax, 1            ; Shift arithmetic right (préserve le signe)
", lang: "nasm"))

=== Rotations

#codebox(raw("
rol rax, 1            ; Rotate left
ror rax, 1            ; Rotate right
rcl rax, 1            ; Rotate through carry left
rcr rax, 1            ; Rotate through carry right
", lang: "nasm"))

== 4.5 Instructions de contrôle de flux

=== Sauts inconditionnels

#codebox(raw("
jmp label             ; Saut inconditionnel
jmp rax               ; Saut indirect (adresse dans rax)
jmp [rax]             ; Saut indirect (adresse pointée par rax)
", lang: "nasm"))

=== Sauts conditionnels

#codebox(raw("
; Basés sur les flags
je   label            ; Jump if equal (ZF=1)
jne  label            ; Jump if not equal (ZF=0)
jz   label            ; Jump if zero (ZF=1)
jnz  label            ; Jump if not zero (ZF=0)

; Comparaisons non signées
ja   label            ; Jump if above (CF=0 et ZF=0)
jae  label            ; Jump if above or equal (CF=0)
jb   label            ; Jump if below (CF=1)
jbe  label            ; Jump if below or equal (CF=1 ou ZF=1)

; Comparaisons signées
jg   label            ; Jump if greater (ZF=0 et SF=OF)
jge  label            ; Jump if greater or equal (SF=OF)
jl   label            ; Jump if less (SF≠OF)
jle  label            ; Jump if less or equal (ZF=1 ou SF≠OF)

; Basés sur des flags spécifiques
js   label            ; Jump if sign (SF=1)
jns  label            ; Jump if not sign (SF=0)
jo   label            ; Jump if overflow (OF=1)
jno  label            ; Jump if not overflow (OF=0)
jc   label            ; Jump if carry (CF=1)
jnc  label            ; Jump if not carry (CF=0)
", lang: "nasm"))

=== Boucles

#codebox(raw("
loop label            ; Décrémente rcx et saute si rcx ≠ 0
loope label           ; Loop if equal (rcx-- et ZF=1)
loopne label          ; Loop if not equal (rcx-- et ZF=0)
", lang: "nasm"))

=== Appels et retours

#codebox(raw("
call function         ; Appel de fonction
ret                   ; Retour de fonction
ret 16                ; Retour avec nettoyage de pile (rare en x86-64)
", lang: "nasm"))

== 4.6 Instructions de pile

#codebox(raw("
push rax              ; Empile rax (rsp -= 8, puis [rsp] = rax)
pop rax               ; Dépile dans rax (rax = [rsp], puis rsp += 8)

push qword [mem]      ; Empile depuis mémoire
pop qword [mem]       ; Dépile vers mémoire

pushfq                ; Empile RFLAGS
popfq                 ; Dépile RFLAGS
", lang: "nasm"))

== 4.7 Instructions système

#codebox(raw("
syscall               ; Appel système (Linux x86-64)
nop                   ; No operation
hlt                   ; Halt (arrêt du processeur)
", lang: "nasm"))

== 4.8 Instructions de chaînes

#codebox(raw("
; Préfixes de répétition
rep                   ; Répète tant que rcx > 0
repe / repz           ; Répète tant que ZF=1 et rcx > 0
repne / repnz         ; Répète tant que ZF=0 et rcx > 0

; Instructions
movsb / movsw / movsd / movsq  ; Déplace string (RSI vers RDI)
stosb / stosw / stosd / stosq  ; Stocke AL/AX/EAX/RAX dans [RDI]
lodsb / lodsw / lodsd / lodsq  ; Charge depuis [RSI] dans AL/AX/EAX/RAX
scasb / scasw / scasd / scasq  ; Compare AL/AX/EAX/RAX avec [RDI]
cmpsb / cmpsw / cmpsd / cmpsq  ; Compare [RSI] avec [RDI]

; Exemple : copie de mémoire
mov rcx, 100          ; 100 octets
mov rsi, source
mov rdi, destination
rep movsb             ; Copie rcx octets
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 5. ABI System V x86-64

== 5.1 Qu'est-ce que l'ABI ?

L'*ABI (Application Binary Interface)* définit :
- Comment passer les arguments aux fonctions
- Quels registres préserver
- Comment retourner les valeurs
- L'alignement de la pile
- Les conventions d'appel

== 5.2 Passage des arguments

#diagram(raw("
┌─────────────────────────────────────────────────┐
│  Ordre de passage des arguments (entiers/ptrs)  │
├─────────┬───────────────────────────────────────┤
│ Arg 1   │ RDI                                   │
│ Arg 2   │ RSI                                   │
│ Arg 3   │ RDX                                   │
│ Arg 4   │ RCX                                   │
│ Arg 5   │ R8                                    │
│ Arg 6   │ R9                                    │
│ Arg 7+  │ Sur la pile (ordre inversé)           │
└─────────┴───────────────────────────────────────┘
"))

*Pour les flottants (XMM0-XMM7) :*
```
XMM0 : 1er argument flottant
XMM1 : 2ème argument flottant
...
XMM7 : 8ème argument flottant
```

== 5.3 Registres préservés vs volatiles

#diagram(raw("
┌─────────────────────────────────────────────────┐
│             Registres PRÉSERVÉS                 │
│  (la fonction appelée doit les sauvegarder)     │
├─────────────────────────────────────────────────┤
│ RBX, RBP, R12, R13, R14, R15                    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│             Registres VOLATILES                 │
│  (peuvent être modifiés par l'appelé)           │
├─────────────────────────────────────────────────┤
│ RAX, RCX, RDX, RSI, RDI, R8-R11                 │
│ XMM0-XMM15, RFLAGS                              │
└─────────────────────────────────────────────────┘
"))

*Règle importante :* Si votre fonction utilise des registres préservés, vous *devez* les sauvegarder au début et les restaurer avant de retourner.

== 5.4 Valeurs de retour

#codebox(raw("
; Entiers et pointeurs
RAX    : Valeur de retour (64 bits max)
RDX    : Partie haute pour retour 128 bits

; Flottants
XMM0   : Valeur de retour flottante
XMM1   : Partie haute pour retour 128 bits

; Structures
; Si <= 16 octets : dans RAX:RDX ou XMM0:XMM1
; Si > 16 octets : via pointeur (argument caché en RDI)
", lang: "nasm"))

== 5.5 Red Zone

#diagram(raw("
┌─────────────────────────────────────────────────┐
│                  RED ZONE                       │
├─────────────────────────────────────────────────┤
│ 128 octets sous RSP non utilisables par         │
│ gestionnaires d'interruptions/signaux           │
│                                                 │
│ Une fonction 'leaf' (qui n'appelle personne)    │
│ peut utiliser cette zone sans ajuster RSP       │
└─────────────────────────────────────────────────┘

RSP -> ┌───────────────┐
       │               │
                               │  Red Zone     │  128 octets utilisables
                          │  (optionnel)  │  sans modifier RSP
       │               │
       └───────────────┘
"))

*Exemple :*
#codebox(raw("
; Fonction leaf utilisant la red zone
my_leaf_function:
    mov [rsp - 8], rdi    ; Utilise la red zone
    mov [rsp - 16], rsi
    ; ... traitement ...
    mov rax, [rsp - 8]
    ret
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 6. Gestion de la pile

== 6.1 Structure de la pile

#diagram(raw("
Mémoire haute (adresses élevées)
    ↓
    ├──────────────────┐
                              │   Arguments 7+   │  (si plus de 6 arguments)
    ├──────────────────┤
                     │  Adresse retour  │  (push par CALL)
                                     ├──────────────────┤ <- RSP à l'entrée de la fonction
                                     │   RBP sauvegardé │  (optionnel, pour frame pointer)
                        ├──────────────────┤ <- RBP (si utilisé)
    │  Registres       │
    │  préservés       │
    ├──────────────────┤
    │  Variables       │
    │  locales         │
    ├──────────────────┤
                             │  Alignement      │  (padding si nécessaire)
                              ├──────────────────┤ <- RSP durant l'exécution
                             │  Red Zone        │  (optionnel, 128 octets)
    └──────────────────┘
    ↓
Mémoire basse (adresses faibles)
"))

== 6.2 Alignement de la pile : RÈGLE ESSENTIELLE

*La pile DOIT être alignée sur 16 octets avant un CALL.*

#diagram(raw("
┌─────────────────────────────────────────────────┐
│       RÈGLE D'ALIGNEMENT CRITIQUE               │
├─────────────────────────────────────────────────┤
│ Avant CALL : RSP ≡ 0 (mod 16)                   │
│ Après CALL : RSP ≡ 8 (mod 16)                   │
│               (car CALL empile 8 octets)        │
│                                                 │
│ Dans la fonction : RSP ≡ 8 (mod 16) au début    │
└─────────────────────────────────────────────────┘
"))

== 6.3 Pourquoi l'alignement est important ?

1. *Instructions SSE* : Nécessitent un alignement 16 octets
2. *Performance* : Accès mémoire plus rapides
3. *Obligations ABI* : Requis par la norme System V

== 6.4 Comment assurer l'alignement

=== Méthode 1 : Sans frame pointer (moderne)

#codebox(raw("
my_function:
    ; À l'entrée : RSP ≡ 8 (mod 16)
    
    ; Sauvegarder registres préservés (nombre impair pour alignement)
    push rbx              ; RSP ≡ 0 (mod 16)
    
    ; Allouer espace local (multiple de 16)
    sub rsp, 32           ; RSP ≡ 0 (mod 16)
    
    ; ... code de la fonction ...
    
    ; Restaurer
    add rsp, 32
    pop rbx
    ret
", lang: "nasm"))

=== Méthode 2 : Avec frame pointer (classique)

#codebox(raw("
my_function:
    ; Prologue standard
    push rbp              ; Sauvegarder ancien RBP
    mov rbp, rsp          ; RBP pointe sur le frame actuel
    
    ; Sauvegarder autres registres
    push rbx
    push r12
    
    ; Aligner et allouer (RSP doit être aligné avant CALL)
    sub rsp, 24           ; Ajuster selon besoins
    
    ; Corps de la fonction
    ; ...
    
    ; Épilogue
    add rsp, 24
    pop r12
    pop rbx
    pop rbp
    ret
", lang: "nasm"))

=== Méthode 3 : Calcul dynamique

#codebox(raw("
my_function:
    push rbp
    mov rbp, rsp
    
    ; Calculer espace nécessaire
    mov rax, taille_necessaire
    add rax, 15           ; Arrondir au multiple de 16 supérieur
    and rax, -16          ; Masquer les 4 bits de poids faible
    sub rsp, rax
    
    ; ...
    
    mov rsp, rbp
    pop rbp
    ret
", lang: "nasm"))

== 6.5 Schéma détaillé d'alignement

#codebox(raw("
Avant CALL (dans fonction appelante) :
RSP -> ┌───────────────┐  Adresse: 0x...0 ou 0x...8
       │               │  RSP ≡ 0 (mod 16) ✓
       └───────────────┘

Après CALL (entrée fonction) :
       ┌───────────────┐
       │ Adr. retour   │  8 octets empilés
RSP -> └───────────────┘  RSP ≡ 8 (mod 16)

Après PUSH RBP :
       ┌───────────────┐
       │ Adr. retour   │
       ├───────────────┤
       │ RBP ancien    │  8 octets
RSP -> └───────────────┘  RSP ≡ 0 (mod 16) ✓

Après SUB RSP, 32 :
       ┌───────────────┐
       │ Adr. retour   │
       ├───────────────┤
       │ RBP ancien    │
       ├───────────────┤
       │               │
       │  Espace       │  32 octets
       │  local        │
       │               │
RSP -> └───────────────┘  RSP ≡ 0 (mod 16) ✓
"))

== 6.6 Exemples d'erreurs courantes

=== ❌ ERREUR : Mauvais alignement

#codebox(raw("
bad_function:
    push rbx              ; RSP ≡ 0
    sub rsp, 24           ; RSP ≡ 8 (mod 16) - MAUVAIS !
    call autre_fonction   ; CRASH ou comportement indéfini
    add rsp, 24
    pop rbx
    ret
", lang: "nasm"))

=== ✓ CORRECT : Bon alignement

#codebox(raw("
good_function:
    push rbx              ; RSP ≡ 0
    sub rsp, 24           ; RSP ≡ 8
    sub rsp, 8            ; RSP ≡ 0 (mod 16) - BON !
    call autre_fonction   ; OK
    add rsp, 32
    pop rbx
    ret
", lang: "nasm"))

Ou plus simplement :

#codebox(raw("
good_function_v2:
    push rbx              ; RSP ≡ 0
    sub rsp, 32           ; RSP ≡ 0 (mod 16) - BON !
    call autre_fonction   ; OK
    add rsp, 32
    pop rbx
    ret
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 7. Appels de fonctions

== 7.1 Anatomie complète d'un appel de fonction

#codebox(raw("
; Fonction appelante (caller)
caller:
    push rbp
    mov rbp, rsp
    sub rsp, 16           ; Alignement
    
    ; Préparer les arguments
    mov rdi, 10           ; 1er argument
    mov rsi, 20           ; 2ème argument
    mov rdx, 30           ; 3ème argument
    ; ... jusqu'à 6 arguments en registres
    
    ; Arguments supplémentaires sur la pile (ordre inversé)
    push 8eme_arg
    push 7eme_arg
    
    call ma_fonction      ; Appel
    
    ; Nettoyer la pile si nécessaire
    add rsp, 16           ; Enlever les 2 arguments empilés
    
    ; Résultat dans RAX
    ; ...
    
    mov rsp, rbp
    pop rbp
    ret

; Fonction appelée (callee)
ma_fonction:
    ; Prologue
    push rbp
    mov rbp, rsp
    
    ; Sauvegarder registres préservés utilisés
    push rbx
    push r12
    push r13
    
    ; Aligner et allouer espace local
    sub rsp, 24           ; 24 pour avoir total multiple de 16
    
    ; Les arguments sont dans :
    ; rdi = arg1
    ; rsi = arg2
    ; rdx = arg3
    ; [rbp + 16] = arg7 (si présent)
    ; [rbp + 24] = arg8 (si présent)
    
    ; Corps de la fonction
    ; ...
    
    ; Préparer la valeur de retour
    mov rax, resultat
    
    ; Épilogue
    add rsp, 24
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
", lang: "nasm"))

== 7.2 Patterns de prologue/épilogue

=== Pattern 1 : Simple (sans registres préservés)

#codebox(raw("
fonction_simple:
    ; Pas de prologue si pas de variables locales
    ; et pas de registres préservés utilisés
    
    mov rax, rdi
    add rax, rsi
    ret
", lang: "nasm"))

=== Pattern 2 : Avec variables locales

#codebox(raw("
fonction_avec_vars:
    push rbp
    mov rbp, rsp
    sub rsp, 32           ; Espace pour variables locales
    
    ; Utiliser [rbp-8], [rbp-16], etc. pour variables
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi
    
    ; ...
    
    leave                 ; Équivalent à: mov rsp, rbp; pop rbp
    ret
", lang: "nasm"))

=== Pattern 3 : Avec registres préservés

#codebox(raw("
fonction_complete:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24           ; Ajuster pour alignement 16
    
    ; Corps
    ; ...
    
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
", lang: "nasm"))

== 7.3 Appels de fonctions C depuis l'assembleur

#codebox(raw("
section .data
    format db 'Résultat: %d', 10, 0  ; Format pour printf

section .text
    extern printf                     ; Déclarer fonction externe
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16                       ; Alignement
    
    ; Appeler printf('Résultat: %d\n', 42)
    lea rdi, [rel format]             ; 1er arg : pointeur format
    mov rsi, 42                       ; 2ème arg : valeur
    xor eax, eax                      ; AL=0 (pas d'args flottants)
    call printf
    
    xor eax, eax                      ; Retourner 0
    leave
    ret
", lang: "nasm"))

*Points importants :*
1. `xor eax, eax` avant `call printf` : indique le nombre d'arguments flottants (0 ici)
2. Utiliser `lea rdi, [rel format]` pour code position-independent
3. Toujours assurer l'alignement 16 octets avant CALL

== 7.4 Fonctions variadiques

Pour appeler des fonctions comme `printf` :

#codebox(raw("
    ;printf('%s %d %f\\n',str, num, float)
    lea rdi, [rel format]     ; Format string
    lea rsi, [rel str]        ; 1er arg
    mov rdx, 42               ; 2ème arg (entier)
    movsd xmm0, [rel fval]    ; 3ème arg (flottant)
    mov eax, 1                ; Nombre de registres XMM utilisés
    call printf
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 8. Exemples pratiques

== 8.1 Hello World complet

#codebox(raw("
section .data
    message db 'Hello, World!', 10, 0  ; 10 = newline, 0 = null
    msg_len equ $ - message - 1        ; Longueur sans le null

section .text
    global _start

_start:
    ; write(1, message, msg_len)
    mov rax, 1              ; syscall: sys_write
    mov rdi, 1              ; fd: stdout
    lea rsi, [rel message]  ; buffer
    mov rdx, msg_len        ; count
    syscall
    
    ; exit(0)
    mov rax, 60             ; syscall: sys_exit
    xor rdi, rdi            ; status: 0
    syscall
", lang: "nasm"))

*Compilation et exécution :*
```bash
nasm -f elf64 hello.asm -o hello.o
ld hello.o -o hello
./hello
```

== 8.2 Fonction : Addition de deux nombres

#codebox(raw("
section .text
    global add_numbers

; int64_t add_numbers(int64_t a, int64_t b)
add_numbers:
    ; Arguments : rdi = a, rsi = b
    ; Pas de prologue nécessaire (fonction leaf simple)
    
    mov rax, rdi        ; rax = a
    add rax, rsi        ; rax = a + b
    ret                 ; Retourner rax
", lang: "nasm"))

== 8.3 Fonction : Factorielle (récursive)

#codebox(raw("
section .text
    global factorial

; uint64_t factorial(uint64_t n)
factorial:
    ; Argument : rdi = n
    push rbp
    mov rbp, rsp
    push rbx                ; Sauvegarder rbx (préservé)
    sub rsp, 8              ; Alignement (total 16 avec push rbx)
    
    ; Cas de base : if (n <= 1) return 1
    cmp rdi, 1
    jle .base_case
    
    ; Cas récursif : return n * factorial(n-1)
    mov rbx, rdi            ; Sauvegarder n dans rbx
    dec rdi                 ; n-1
    call factorial          ; factorial(n-1)
    imul rax, rbx           ; n * factorial(n-1)
    jmp .end
    
.base_case:
    mov rax, 1
    
.end:
    add rsp, 8
    pop rbx
    pop rbp
    ret
", lang: "nasm"))

== 8.4 Fonction : Copie de chaîne (strcpy)

#codebox(raw("
section .text
    global my_strcpy

; char* my_strcpy(char* dest, const char* src)
my_strcpy:
    ; Arguments : rdi = dest, rsi = src
    push rbp
    mov rbp, rsp
    
    mov rax, rdi            ; Sauvegarder dest pour retour
    
.loop:
    mov cl, [rsi]           ; Charger byte depuis src
    mov [rdi], cl           ; Stocker dans dest
    test cl, cl             ; Tester si c'est '\0'
    jz .done                ; Si oui, terminer
    
    inc rsi                 ; src++
    inc rdi                 ; dest++
    jmp .loop
    
.done:
    pop rbp
    ret                     ; Retourner pointeur dest original
", lang: "nasm"))

== 8.5 Fonction : Longueur de chaîne (strlen)

#codebox(raw("
section .text
    global my_strlen

; size_t my_strlen(const char* str)
my_strlen:
    ; Argument : rdi = str
    xor rax, rax            ; Compteur = 0
    
.loop:
    cmp byte [rdi + rax], 0 ; Tester si '\0'
    je .done
    inc rax                 ; Incrémenter compteur
    jmp .loop
    
.done:
    ret                     ; Retourner longueur dans rax
", lang: "nasm"))

== 8.6 Fonction : Comparaison de chaînes (strcmp)

#codebox(raw("
section .text
    global my_strcmp

; int my_strcmp(const char* s1, const char* s2)
my_strcmp:
    ; Arguments : rdi = s1, rsi = s2
    
.loop:
    mov al, [rdi]           ; Charger caractère s1
    mov bl, [rsi]           ; Charger caractère s2
    
    ; Comparer
    cmp al, bl
    jne .different          ; Si différents, sortir
    
    ; Si on atteint '\0', les chaînes sont égales
    test al, al
    jz .equal
    
    ; Avancer aux caractères suivants
    inc rdi
    inc rsi
    jmp .loop
    
.different:
    ; Retourner différence
    movzx rax, al
    movzx rbx, bl
    sub rax, rbx
    ret
    
.equal:
    xor rax, rax            ; Retourner 0
    ret
", lang: "nasm"))

== 8.7 Programme complet : Calculatrice simple

#codebox(raw("
section .data
    prompt db 'Entrez deux nombres: ', 0
    result_msg db 'Résultat: %ld', 10, 0
    format_int db '%ld', 0

section .bss
    num1 resq 1
    num2 resq 1

section .text
    extern printf, scanf
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16             ; Alignement
    
    ; Afficher prompt
    lea rdi, [rel prompt]
    xor eax, eax
    call printf
    
    ; Lire premier nombre
    lea rdi, [rel format_int]
    lea rsi, [rel num1]
    xor eax, eax
    call scanf
    
    ; Lire deuxième nombre
    lea rdi, [rel format_int]
    lea rsi, [rel num2]
    xor eax, eax
    call scanf
    
    ; Additionner
    mov rax, [rel num1]
    add rax, [rel num2]
    
    ; Afficher résultat
    lea rdi, [rel result_msg]
    mov rsi, rax
    xor eax, eax
    call printf
    
    ; Retourner 0
    xor eax, eax
    leave
    ret
", lang: "nasm"))

== 8.8 Manipulation de tableaux : Somme d'éléments

#codebox(raw("
section .text
    global array_sum

; int64_t array_sum(int64_t* array, size_t length)
array_sum:
    ; Arguments : rdi = array, rsi = length
    
    xor rax, rax            ; Somme = 0
    xor rcx, rcx            ; Index = 0
    
    ; Vérifier si length == 0
    test rsi, rsi
    jz .done
    
.loop:
    add rax, [rdi + rcx * 8] ; Ajouter array[i] (8 octets par élément)
    inc rcx                  ; i++
    cmp rcx, rsi             ; i < length ?
    jl .loop
    
.done:
    ret
", lang: "nasm"))

== 8.9 Fonction : Maximum de deux nombres

#codebox(raw("
section .text
    global max

; int64_t max(int64_t a, int64_t b)
max:
    ; Arguments : rdi = a, rsi = b
    
    cmp rdi, rsi
    jge .a_is_max
    
    mov rax, rsi            ; b est plus grand
    ret
    
.a_is_max:
    mov rax, rdi            ; a est plus grand ou égal
    ret
", lang: "nasm"))

== 8.10 Fonction : Swap (échange de valeurs)

#codebox(raw("
section .text
    global swap

; void swap(int64_t* a, int64_t* b)
swap:
    ; Arguments : rdi = &a, rsi = &b
    
    mov rax, [rdi]          ; Charger *a
    mov rbx, [rsi]          ; Charger *b
    mov [rdi], rbx          ; *a = *b
    mov [rsi], rax          ; *b = ancien *a
    ret
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 9. Optimisations et bonnes pratiques

== 9.1 Optimisations courantes

=== Utiliser LEA pour calculs arithmétiques

#codebox(raw("
; Au lieu de :
mov rax, rdi
imul rax, 3
add rax, 5

; Utiliser :
lea rax, [rdi + rdi * 2 + 5]  ; rax = rdi * 3 + 5 (plus rapide)
", lang: "nasm"))

=== Zéro-init avec XOR

#codebox(raw("
; Au lieu de :
mov rax, 0                    ; 7 octets, plus lent

; Utiliser :
xor eax, eax                  ; 2 octets, plus rapide (met aussi à 0 les bits hauts)
", lang: "nasm"))

=== Test d'un registre contre lui-même

#codebox(raw("
; Au lieu de :
cmp rax, 0

; Utiliser :
test rax, rax                 ; Plus rapide, même effet sur ZF
", lang: "nasm"))

=== Multiplication et division par puissances de 2

#codebox(raw("
; Multiplication par 8
shl rax, 3                    ; Au lieu de imul rax, 8

; Division par 4 (non signée)
shr rax, 2                    ; Au lieu de div

; Division par 4 (signée, avec arrondi correct)
sar rax, 2                    ; Au lieu de idiv
", lang: "nasm"))

== 9.2 Patterns efficaces

=== Swap sans variable temporaire

#codebox(raw("
xor rax, rbx
xor rbx, rax
xor rax, rbx                  ; rax et rbx sont échangés
", lang: "nasm"))

=== Valeur absolue

#codebox(raw("
; Pour obtenir |rax|
mov rbx, rax
sar rbx, 63                   ; Remplir rbx avec le bit de signe
xor rax, rbx
sub rax, rbx                  ; rax = |rax|
", lang: "nasm"))

=== Minimum/Maximum sans branchement

#codebox(raw("
; max(rax, rbx) -> rax
cmp rax, rbx
cmovl rax, rbx                ; Si rax < rbx, rax = rbx

; min(rax, rbx) -> rax
cmp rax, rbx
cmovg rax, rbx                ; Si rax > rbx, rax = rbx
", lang: "nasm"))

== 9.3 Éviter les pièges courants

=== Piège 1 : Oublier l'alignement

#codebox(raw("
; ❌ MAUVAIS
function:
    push rbx              ; RSP ≡ 0
    sub rsp, 8            ; RSP ≡ 8 - MAUVAIS pour call
    call autre
    
; ✓ BON
function:
    push rbx              ; RSP ≡ 0
    sub rsp, 16           ; RSP ≡ 0 - BON
    call autre
", lang: "nasm"))

=== Piège 2 : Ne pas préserver les registres

#codebox(raw("
; ❌ MAUVAIS - modifie rbx sans le sauvegarder
function:
    mov rbx, rdi          ; rbx est préservé !
    ; ...
    ret

; ✓ BON
function:
    push rbx
    mov rbx, rdi
    ; ...
    pop rbx
    ret
", lang: "nasm"))

=== Piège 3 : Opérations 32 bits qui modifient 64 bits

#codebox(raw("
mov rax, 0xFFFFFFFFFFFFFFFF
mov eax, 1                    ; rax = 0x0000000000000001 (zéro-extension!)
", lang: "nasm"))

*Règle :* Les opérations 32 bits mettent à zéro les 32 bits hauts.

=== Piège 4 : Division sans initialiser RDX

#codebox(raw("
; ❌ MAUVAIS
mov rax, 100
div rbx                       ; Utilise rdx:rax, rdx contient des déchets!

; ✓ BON
mov rax, 100
xor rdx, rdx                  ; ou: mov rdx, 0
div rbx

; ✓ BON pour division signée
mov rax, -100
cqo                           ; Étend le signe de rax dans rdx
idiv rbx
", lang: "nasm"))

== 9.4 Débogage

=== Utiliser GDB

```bash

nasm -f elf64 -g -F dwarf prog.asm
gcc -g prog.o -o prog

gdb ./prog

(gdb) break main              
(gdb) run                     
(gdb) stepi                   
(gdb) info registers          
(gdb) x/16xb $rsp            
(gdb) disassemble            

```

=== Macros de débogage

#codebox(raw("
%macro PRINT_REG 1
    push rdi
    push rsi
    push rax
    
    mov rdi, reg_format
    mov rsi, %1
    xor eax, eax
    call printf
    
    pop rax
    pop rsi
    pop rdi
%endmacro

section .data
    reg_format db 'Register: %ld', 10, 0

section .text
    ; Utilisation :
    PRINT_REG rax
", lang: "nasm"))

== 9.5 Structure de projet recommandée

```
projet/
├── Makefile
├── src/
│   ├── main.asm
│   ├── functions.asm
│   └── utils.asm
├── include/
│   └── constants.inc
└── build/
    └── (fichiers objets)
```

*Makefile exemple :*

```makefile
ASM = nasm
ASMFLAGS = -f elf64 -g -F dwarf
LD = ld
LDFLAGS = 

`SOURCES = $(wildcard src/*.asm)`
`OBJECTS = $(SOURCES:src/%.asm=build/%.o)`
TARGET = program

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) `$^` -o $@

build/%.o: src/%.asm
	@mkdir -p build
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -rf build $(TARGET)

.PHONY: all clean
```

== 9.6 Conventions de nommage

#codebox(raw("
; Labels de fonctions : snake_case
my_function:
calculate_sum:

; Labels locaux : .prefixe
.loop:
.done:
.error:

; Constantes : UPPERCASE
BUFFER_SIZE equ 1024
MAX_VALUE equ 100

; Variables : snake_case
user_input:
result_buffer:
", lang: "nasm"))

== 9.7 Commentaires efficaces

#codebox(raw("
; ❌ MAUVAIS - répète le code
mov rax, 5                    ; met 5 dans rax

; ✓ BON - explique l'intention
mov rax, 5                    ; Initialiser compteur de boucle

; ✓ EXCELLENT - documente la fonction
; calculate_average
; Calcule la moyenne d'un tableau d'entiers
; Arguments:
;   rdi - pointeur vers le tableau
;   rsi - nombre d'éléments
; Retourne:
;   rax - moyenne (arrondie vers le bas)
; Registres modifiés:
;   rax, rcx, rdx
calculate_average:
    ; ...
", lang: "nasm"))

== 9.8 Performance : Do's and Don'ts

=== DO ✓

#codebox(raw("
; Minimiser les accès mémoire
mov rax, [mem]
add rax, 1
add rax, 2
add rax, 3
mov [mem], rax

; Utiliser les instructions de chaîne pour copies
mov rcx, count
rep movsq                     ; Plus rapide qu'une boucle manuelle

; Dérouler les petites boucles
add rax, [rsi]
add rax, [rsi + 8]
add rax, [rsi + 16]
add rax, [rsi + 24]
", lang: "nasm"))

=== DON'T ✗

#codebox(raw("
; Éviter les accès mémoire répétés
add qword [mem], 1            ; Lent
add qword [mem], 2            ; Éviter
add qword [mem], 3

; Éviter les dépendances de données
add rax, rbx
add rbx, rax                  ; Dépend du résultat précédent
add rax, rbx                  ; Pipeline bloqué

; Éviter les divisions si possible
; Si diviser par constante :
; Au lieu de div
; Utiliser multiplication par inverse (technique avancée)
", lang: "nasm"))

#line(length: 100%, stroke: 0.5pt)

= 10. Tableaux de référence rapide

== 10.1 Syscalls Linux x86-64 (les plus courants)

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  inset: 5pt,
  fill: (col, row) => if row == 0 { luma(230) } else { white },
  [*RAX*], [*Syscall*], [*RDI*], [*RSI*], [*RDX*], [*R10*], [*R8*], [*R9*],
  [0], [read], [fd], [buf], [count], [-], [-], [-],
  [1], [write], [fd], [buf], [count], [-], [-], [-],
  [2], [open], [filename], [flags], [mode], [-], [-], [-],
  [3], [close], [fd], [-], [-], [-], [-], [-],
  [9], [mmap], [addr], [length], [prot], [flags], [fd], [offset],
  [60], [exit], [status], [-], [-], [-], [-], [-],
)

== 10.2 Tailles des opérandes

#table(
  columns: (auto, auto, 1fr),
  inset: 5pt,
  fill: (col, row) => if row == 0 { luma(230) } else { white },
  [*Suffixe*], [*Taille*], [*Exemple*],
  [byte], [8 bits], [mov byte [rax], 42],
  [word], [16 bits], [mov word [rax], 42],
  [dword], [32 bits], [mov dword [rax], 42],
  [qword], [64 bits], [mov qword [rax], 42],
)

== 10.3 Codes de condition pour sauts

#table(
  columns: (auto, auto, auto),
  inset: 5pt,
  fill: (col, row) => if row == 0 { luma(230) } else { white },
  [*Jump*], [*Condition*], [*Flags*],
  [JE / JZ], [Equal / Zero], [ZF=1],
  [JNE / JNZ], [Not Equal / Not Zero], [ZF=0],
  [JG / JNLE], [Greater (signé)], [ZF=0 et SF=OF],
  [JGE / JNL], [Greater or Equal (signé)], [SF=OF],
  [JL / JNGE], [Less (signé)], [SF≠OF],
  [JLE / JNG], [Less or Equal (signé)], [ZF=1 ou SF≠OF],
  [JA / JNBE], [Above (non signé)], [CF=0 et ZF=0],
  [JAE / JNB], [Above or Equal (non signé)], [CF=0],
  [JB / JNAE], [Below (non signé)], [CF=1],
  [JBE / JNA], [Below or Equal (non signé)], [CF=1 ou ZF=1],
)

#line(length: 100%, stroke: 0.5pt)

= Conclusion

Ce tutoriel couvre les aspects essentiels de l'assembleur x86-64 avec syntaxe Intel :

*Points clés à retenir :*
1. *Alignement de pile* : Toujours 16 octets avant CALL
2. *ABI* : Respecter les conventions (arguments, registres préservés)
3. *Registres* : Connaître la différence entre préservés et volatiles
4. *Performance* : Minimiser les accès mémoire, utiliser LEA intelligemment
5. *Débogage* : Utiliser GDB et commenter abondamment

*Pour aller plus loin :*
- Manuel Intel (Intel® 64 and IA-32 Architectures Software Developer's Manuals)
- System V ABI documentation
- Optimization manuals (Intel, AMD, Agner Fog)
- Pratique avec des projets réels
