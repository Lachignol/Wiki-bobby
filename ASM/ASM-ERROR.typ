= Fonctionement des erreurs

\
\
\


```asm

syscall                     ;je fait mon syscall qui peu retourner une erreur ex:read 
test rax, rax               ;je fait un test pour mettre a jour les flag
js error                    ;js = Jump if Sign → “saute si signe négatif”.
ret

error:
    neg rax                 ;errno a besoin du code en positif donc ex -9 je le met a 9
    mov r8d, eax            ;la je prend des registre de 32 bit car errno est sur 32 bit donc je prend les 4 bit qui corresponde a l'int du code err dans rax donne par le syscall
    call __errno_location   ;j'apelle le errno_location pour obtenir le pointeur de errno
    mov [rax], r8d          ;je copie donc le code err a l'endroit pointe par errno'
    mov rax, -1             ;je retourne -1 comme retour de la fonction
    ret

```
