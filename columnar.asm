;; Profeanu Ioana, 323CA

section .data
    extern len_cheie, len_haystack
    key_iterator dd 0
    ciphertext_iterator dd 0

;; defining global variables; used for keeping data in order to be able to
;; use as many registers as possible
section .text
    global columnar_transposition

;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext

;; initialise the global variables and the registers
initiaise_values:
    xor ecx, ecx
    xor eax, eax ; the current key element will be kept here
    mov dword [key_iterator], 0 ; used for iterating within the key
    mov dword [ciphertext_iterator], 0 ; used for iterating in the ciphertext

;; get the current element within the key
get_key_order:
    mov ecx, dword [key_iterator]
    ; compare the current key index with the length of the key
    cmp ecx, [len_cheie]
    ; if we finished iterating within the key, exit the program
    jge exit 
    
    ; in eax, we will keep the current key element
    mov eax, dword [edi + 4 * ecx]

;; add the characters into the ciphertext
add_in_ciphertext:
    mov ecx, [ciphertext_iterator]
    mov dh, [esi + eax] ; extract the charcter from the haystack
    mov [ebx + ecx], dh ; add the character into the ciphertext array

    inc dword [ciphertext_iterator] ; increase the ciphertext iterator
    add eax, [len_cheie] ; add the length of the key to the current key index
    ; compare the current position with the haysack length
    cmp eax, [len_haystack]
    jl add_in_ciphertext ; if lower, go back into the loop

    inc dword [key_iterator] ; increase the key iterator
    ; compare the current position with the haysack length
    cmp eax, [len_haystack]
    jge get_key_order ; if greater or equal, continue iterating through the key

exit:
    popa
    leave
    ret
