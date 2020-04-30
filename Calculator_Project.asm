.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
extern scanf: proc
extern printf: proc
extern exit: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data

x dd 0
oper dd 0
msg db 10, "Operatia: ", 0
nr db "%d", 0
caract db "%c", 0
k dd 1
nrAux dd 0
i dd 0
builtNr dd 20 dup(0)
ten dd 10
result dd 0

.code

sum proc					;suma efectiva
	push ebp
	mov ebp, esp
	mov eax, [ebp + 12]		; elem 1
	add eax, [ebp + 8]		; elem 2 
	mov esp, ebp
	pop ebp
	ret 8
sum endp

subtraction proc 			; diferenta efectiva
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]
	sub eax, [ebp + 12]
	mov esp, ebp
	pop ebp
	ret 8
subtraction endp

multiplication proc			; inmultirea efectiva
	push ebp
	mov ebp, esp
	mov eax, [ebp + 12]
	mov ecx, [ebp + 8]
	mul ecx
	mov esp, ebp
	pop ebp
	ret 8
multiplication endp

divide proc					; impartirea efectiva
	push ebp
	mov ebp, esp
	mov edx, 0
	mov eax, [ebp + 8]
	mov ecx, [ebp + 12]
	div ecx
	mov esp, ebp
	pop ebp
	ret 8
divide endp 

start:
	;aici se scrie codul
	
restart:					; dupa afisare se sare la restart, care afiseaza din nou mesajul de inceput 
	mov i,0
	mov edi, 0
	push offset msg
	call printf
	
clean:						; curatare builtNr[] 
	mov builtNr[edi], 0
	add edi, 4
	dec k
	cmp k, 0
	jne clean
	mov edi, 0
	
citire:						; citire caracter cu caracter 
	push offset x
	push offset caract
	call scanf
	add esp, 8
	cmp x, 10				; cod ascii new line
	je citire
	inc i					; 1 pentru primul caracter citit => va duce la verificarea daca primul caracter e operator
	cmp i, 1
	je operator_primul
	add edi, 4 				; increment edi
	
	cmp x, "+"  				; pentru suma
	je operator_plus
	
	cmp x, "-"                  ; pentru diferenta
	je operator_minus
	
	cmp x, "*"                  ; pentru inmultire
	je operator_mul
	
	cmp x, "/"                  ; pentru impartire
	je operator_div
	jmp building
	
operator_plus:					; pune operatorul in variabila oper 
	mov oper, '+'
	jmp citire
	
operator_minus:
	mov oper, '-'
	jmp citire
	
operator_mul:
	mov oper, '*'
	jmp citire
	
operator_div:
	mov oper, '/'
	jmp citire
	
building:							; construirea numarului
	mov ebx, x
	sub ebx, 48 					; cod ascii pt 0 => cifra propriu-zisa
	mov nrAux, ebx
	finit							; initializare coprocesor
	fild builtNr[edi]				; pune valoarea din builtNr[edi] pe stiva coprocesorului
	fild ten						; inmulteste cu 10 
	fmul
	fild nrAux						; adauga nrAux 
	fadd
	fistp builtNr[edi]  			; pune calculul in builtNr
	inc k					 		; numarul de elemente din sirul operatiei 
	push offset x					; aici citesc in caz ca o fost o cifra si operator dupa, daca a fost tot cifra sare inapoi la building, ca sa puna un nr de mai multe cifre pe aceeasi pozitie
	push offset caract			
	call scanf
	cmp x, "+"  					; daca e operator, se pune in variabila oper operatorul respectiv, apoi se intoarce la citire
	je operator_plus
	cmp x, "-"                  
	je operator_minus
	cmp x, "*"                  
	je operator_mul
	cmp x, "/"                 
	je operator_div
	cmp x, '='
	je cmp_oper
	jmp building
	
cmp_oper:							; face operatia in functie de ce operator am citit
	mov edi, 0
	cmp oper, "+"  				; pentru suma
	je sum_et
	
	cmp oper, "-"                 ; pentru diferenta
	je sub_et
	
	cmp oper, "*"                 ; pentru inmultire
	je mul_et
	
	cmp oper, "/"                 ; pentru impartire
	je div_et
	
operator_primul:				; face operatia in cazul in care operatorul este primul 
	cmp x, "+"  				; pentru suma
	je operator_plus_prim
	
	cmp x, "-"                  ; pentru diferenta
	je operator_minus_prim
	
	cmp x, "*"                  ; pentru inmultire
	je operator_mul_prim
	
	cmp x, "/"                  ; pentru impartire
	je operator_div_prim
	
	jmp building
	
construire2:					; construieste sirul pentru cand primul caracter e operator
	push offset x
	push offset caract
	call scanf
	cmp x, '='					; se opreste cand se citeste "="
	je cmp_oper_prim
	mov ebx, x
	sub ebx, 48					; cod ascii pt 0
	mov nrAux, ebx
	finit						; initializare coprocesor
	fild builtNr[edi]
	fild ten
	fmul
	fild nrAux					; adauga nrAux
	fadd
	fistp builtNr[edi] 			; pune calculul in builtNr
	inc k					 	; numarul de elemente din sirul operatiei
	jmp construire2
	
operator_plus_prim:
	mov oper, '+'
	jmp construire2
	
operator_minus_prim:
	mov oper, '-'
	jmp construire2
	
operator_mul_prim:
	mov oper, '*'
	jmp construire2
	
operator_div_prim:
	mov oper, '/'
	jmp construire2
	
cmp_oper_prim:					; verifica ce fel de operator este
	cmp oper, "+"  				; pentru suma
	je sum_prim
	
	cmp oper, "-"                 ; pentru diferenta
	je sub_prim
	
	cmp oper, "*"                 ; pentru inmultire
	je mul_prim
	
	cmp oper, "/"                 ; pentru impartire
	je div_prim
	
sum_et: 	
	push builtNr[edi]
	push builtNr[edi + 4]
	call sum
	jmp afisare
	
sub_et:
	push builtNr[edi + 4]
	push builtNr[edi]
	call subtraction
	jmp afisare
	
mul_et:
	push builtNr[edi]
	push builtNr[edi + 4]
	call multiplication
	jmp afisare
	
div_et:
	push builtNr[edi + 4]
	push builtNr[edi]
	call divide
	jmp afisare

sum_prim:							; suma efectiva cand primul caracter e operator
	push result
	push builtNr[edi]
	call sum 
	jmp afisare
	
sub_prim:							; diferenta efectiva cand primul caracter e operator
	push builtNr[edi]
	push result
	call subtraction
	jmp afisare
	
mul_prim:							; inmultirea efectiva cand primul caracter e operator
	push result
	push builtNr[edi]
	call multiplication
	jmp afisare
	
div_prim:							; impartirea efectiva cand primul caracter e operator
	push builtNr[edi]
	push result
	call divide
	jmp afisare
	
afisare:
	mov result, eax
	push eax
	push offset nr
	call printf
	jmp restart
	
	;terminarea programului
	push 0
	call exit
end start