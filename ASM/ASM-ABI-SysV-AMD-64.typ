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

