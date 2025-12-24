= Convention SysV AMD64 x86-64 (ABI)
\
== Parametres
\
=== 1) Parametres de fonction int et ptr dans l'ordre: rdi, rsi, rdx, rcx, r8, and r9. 

-  rdi (destination index)
-  rsi (source index)
-  rdx (data)
-  rcx (compteur)

=== 2) Parametres float via : xmm0 jusqu'a xmm7. 
\
Tout les autres arguments qui ne rentre pas dans ces registres sont passe par la stack dans le sens inverse (pour que l'ordre lors du depilement corresponde).
== Warning

- La stack grandit vers le bas. 
- Contrairement au parametres standart (registres correspondant pour int et ptr) ,les registres pour float sont pas persistant entres les appels de fonction.
- Les parametres passe par la stack peuve etre modifier par la fonction appelante.
\
== Fonctionement appel de fonctions
\
Les fonctions sont appelées à l'aide de l'instruction `call`, qui empile l'adresse de l'instruction suivante et effectue un saut vers l'opérande. Les fonctions retournent à l'appelant à l'aide de l'instruction `ret`, qui dépile l'adresse de retour et effectue un saut vers cette adresse. La pile est alignée sur 16 octets juste avant l'exécution de l'instruction `call`.

== Persistance des registres

- Les fonctions preserve les registres rbx, rsp, rbp, r12, r13, r14, and r15;
- Tandis que les registres rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11 sont des registres temporaires.

\
\
\
\
\
\
\
\
\
\
\
== Valeur de retour
\
 *La valeur de retour est stocker dans le registre rax (accumulator).*\
 Si c'est une valeur de 128-bit,alors les 64 bits de poids fort sont place dans rdx.

*Si la valeur de retour ne tient pas dans `rax` et `rdx`*.\ l'appelant doit réserver de l'espace mémoire et passer un pointeur dans `rdi` comme s'il s'agissait du premier argument.
L'appelé doit retourner ce même pointeur dans `rax`.

\
\
\
\
\
\
\
Les gestionnaires de signaux sont exécutés sur la même pile, mais 128 octets, appelés « zone rouge », sont soustraits de la pile avant tout empilement. Cela permet aux petites fonctions feuilles d'utiliser 128 octets d'espace de pile sans réservation préalable, grâce à la soustraction du pointeur de pile. La zone rouge est connue pour poser problème aux développeurs de noyaux x86-64, car le processeur ne la prend pas en compte lors de l'appel des gestionnaires d'interruptions. Ceci entraîne une rupture subtile du noyau, l'ABI étant en contradiction avec le comportement du processeur. La solution consiste à compiler tout le code du noyau avec l'option `-mno-red-zone` ou à gérer les interruptions en mode noyau sur une pile différente de la pile courante (implémentant ainsi l'ABI).


En option, les fonctions empilent rbp de sorte que le registre rip de retour de l'appelant soit situé 8 octets au-dessus, et affectent à rbp l'adresse du registre rbp sauvegardé. Ceci permet de parcourir les cadres de pile existants. Cette opération peut être désactivée en spécifiant l'option GCC `-fomit-frame-pointer`.


\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\

= CheatSheet Conventions d'appel
\

*SOMMAIRE*
 + [SystemV AMD64]
 + [SystemV i386]
 + [Windows x64]
 + [Windows StdCall]


---

== [SystemV AMD64]

 === Paramètres
    - Entiers de 64 bits : `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`
    - Flottants de 128 bits : `xmm0`, `xmm1`, `xmm2`, `xmm3`, `xmm4`, `xmm5`, `xmm6`, `xmm7`
    - Flottants de 256 bits : `ymm0`, `ymm1`, `ymm2`, `ymm3`, `ymm4`, `ymm5`, `ymm6`, `ymm7`
    - Flottants de 512 bits : `zmm0`, `zmm1`, `zmm2`, `zmm3`, `zmm4`, `zmm5`, `zmm6`, `zmm7`
 === Paramètres supplémentaires
    - pile (_de droite à gauche_)
 === Valeur de retour
    - Entier de 64 bits : `rax`
    - Entier de 128 bits : `rdx:rax`
    - Flottant de 128 bits : `xmm0`
    - Flottant de 256 bits : `xmm1:xmm0`
 === Registres sauvegardés par l'appelé
    - `rbx`, `rbp`, `rsp`, `r12`, `r13`, `r14`, `r15`
 === Registres sauvegardés par l'appelant
    - `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`, `r9`, `r10`, `r11`
    - `xmm0`, `xmm1`, `xmm2`, `xmm3`, `xmm4`, `xmm5`, `xmm6`, `xmm7`, `xmm8`, `xmm9`, `xmm10`, `xmm11`, `xmm12`, `xmm13`, `xmm14`, `xmm15`
    - `ymm0`, `ymm1`, `ymm2`, `ymm3`, `ymm4`, `ymm5`, `ymm6`, `ymm7`, `ymm8`, `ymm9`, `ymm10`, `ymm11`, `ymm12`, `ymm13`, `ymm14`, `ymm15`
    - `zmm0`, `zmm1`, `zmm2`, `zmm3`, `zmm4`, `zmm5`, `zmm6`, `zmm7`, `zmm8`, `zmm9`, `zmm10`, `zmm11`, `zmm12`, `zmm13`, `zmm14`, `zmm15`

---

== [Windows x64]

 === Paramètres
    - Entiers de 64 bits : `rcx`, `rdx`, `r8`, `r9`
    - Flottants de 128 bits : `xmm0`, `xmm1`, `xmm2`, `xmm3`
 === Paramètres supplémentaires
    - pile (_de droite à gauche_)
 === Valeur de retour
    - Entier de 64 bits : `rax`
    - Flottant de 128 bits : `xmm0`
 === Registres sauvegardés par l'appelé
    - `rbx`, `rbp`, `rsp`, `rsi`, `rdi`, `r12`, `r13`, `r14`, `r15`
    - `xmm6`, `xmm7`, `xmm8`, `xmm9`, `xmm10`, `xmm11`, `xmm12`, `xmm13`, `xmm14`, `xmm15`
    - `ymm0`, `ymm1`, `ymm2`, `ymm3`, `ymm4`, `ymm5`, `ymm6`, `ymm7`, `ymm8`, `ymm9`, `ymm10`, `ymm11`, `ymm12`, `ymm13`, `ymm14`, `ymm15`<br>(_uniquement les 128 bits de poids faible_)
    - `zmm0`, `zmm1`, `zmm2`, `zmm3`, `zmm4`, `zmm5`, `zmm6`, `zmm7`, `zmm8`, `zmm9`, `zmm10`, `zmm11`, `zmm12`, `zmm13`, `zmm14`, `zmm15`<br>(_uniquement les 256 bits de poids faible_)
 === Registres sauvegardés par l'appelant
    - `rax`, `rcx`, `rdx`, `r8`, `r9`, `r10`, `r11`
    - `xmm0`, `xmm1`, `xmm2`, `xmm3`, `xmm4`, `xmm5`
    - `ymm0`, `ymm1`, `ymm2`, `ymm3`, `ymm4`, `ymm5`, `ymm6`, `ymm7`, `ymm8`, `ymm9`, `ymm10`, `ymm11`, `ymm12`, `ymm13`, `ymm14`, `ymm15`<br>(_uniquement les 128 bits de poids fort_)
    - `zmm0`, `zmm1`, `zmm2`, `zmm3`, `zmm4`, `zmm5`, `zmm6`, `zmm7`, `zmm8`, `zmm9`, `zmm10`, `zmm11`, `zmm12`, `zmm13`, `zmm14`, `zmm15`<br>(_uniquement les 256 bits de poids fort_)
    - `xmm16`, `xmm17`, `xmm18`, `xmm19`, `xmm20`, `xmm21`, `xmm22`, `xmm23`, `xmm24`, `xmm25`, `xmm26`, `xmm27`, `xmm28`, `xmm29`, `xmm30`, `xmm31`
    - `ymm16`, `ymm17`, `ymm18`, `ymm19`, `ymm20`, `ymm21`, `ymm22`, `ymm23`, `ymm24`, `ymm25`, `ymm26`, `ymm27`, `ymm28`, `ymm29`, `ymm30`, `ymm31`
    - `zmm16`, `zmm17`, `zmm18`, `zmm19`, `zmm20`, `zmm21`, `zmm22`, `zmm23`, `zmm24`, `zmm25`, `zmm26`, `zmm27`, `zmm28`, `zmm29`, `zmm30`, `zmm31`

---

== [SystemV i386]

 === Paramètres
    - pile (_de droite à gauche_)
 === Valeur de retour
    - Entier de 32 bits : `eax`
    - Entier de 64 bits : `edx:eax`
 === Registres sauvegardés par l'appelé
    - `ebx`, `ebp`, `esp`, `esi`, `edi`
 === Registres sauvegardés par l'appelant
    - `eax`, `ecx`, `edx`

---

== [Windows StdCall]

 === Paramètres
    - pile (_de droite à gauche_)
 === Valeur de retour
    - Entier de 32 bits : `eax`
    - Entier de 64 bits : `eax:edx`
    - Flottant de 128 bits : `st0`
 === Registres sauvegardés par l'appelé
    - `ebx`, `ebp`, `esp`, `esi`, `edi`, `cs`, `ds`, `es`, `fs`, `gs`
 === Registres sauvegardés par l'appelant
    - `eax`, `ecx`, `edx`
    - `st0`, `st1`, `st2`, `st3`, `st4`, `st5`, `st6`, `st7`
