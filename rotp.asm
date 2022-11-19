;; Profeanu Ioana, 323CA

section .text
    global rotp

;; void rotp(char *ciphertext, char *plaintext, char *key, int len);
rotp:
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len

;; initialize ebx with 0, which will be used as an iterator
initiaise_values:
    xor ebx, ebx

;; calculate the value of ciphertext 
calculate_ciphertext_value:
    ; move the value of plaintext[i] into the one byte register ah
    mov ah, [esi + ebx]
    ; perform the xor operation between plaintext[i] and key[len - i - 1]
    xor ah, [edi + ecx - 1]
    ; move the result into ciphertext[i]
    mov [edx + ebx], ah

    inc ebx ; increase the counter ebx
    dec ecx ; decrement ecx
    cmp ecx, 0 ; compare ecx to 0
    jge calculate_ciphertext_value ; if greater than 0, continue iteration

    popa
    leave
    ret
