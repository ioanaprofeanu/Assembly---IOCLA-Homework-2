;; Profeanu Ioana, 323CA

;; defining constants, you can use these as immediate values in your code
CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS

;; defining global variables; used for keeping data in order to be able to
;; use as many registers as possible
section .data
    line_iterator dd 0
    column_iterator dd 0
    tag dd 0
    offset dd 0

section .text
    global load

;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE],
;; char* address, int to_replace);
load:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha
    
    ; address of reg
    mov eax, [ebp + 8]
    ; tags
    mov ebx, [ebp + 12]
    ; cache
    mov ecx, [ebp + 16]
    ; address
    mov edx, [ebp + 20]
    ; to_replace (index of the cache line that needs to be replaced
    ; to be replaced in case of a cache MISS) - in case of cache HIT, we will
    ; keep the line the address is located in cache
    mov edi, [ebp + 24]

;; calculate the tag and the offset of the given address
calculate_tag_and_offset:
    ; calculate the tag of the address and keep the result in the tag variable
    mov dword [tag], edx
    shr dword[tag], OFFSET_BITS
    shl dword[tag], OFFSET_BITS

    ; calculate the offset of the address and keep the result
    ; in the offset variable
    mov dword [offset], edx
    AND dword [offset], 0x7

    ; push the eax register to stack in order to be able to use it
    ; (we don't need the addres of the reg for now)
    push eax
    mov dword [line_iterator], 0

;; check if the tag of the address is found in the tags array
check_tag_in_tags:
    mov eax, [line_iterator]
    mov esi, [tag]

    ; verify if the address' tag is equal to the current tag in the array
    cmp [ebx + 4 * eax], esi
    je cache_hit ; if the tags are equal

    ; if the tags are not equal, increase the iterator and verify if
    ; its value is less than the number of elements in the tags array
    inc dword [line_iterator] ; increase the iterator
    mov eax, CACHE_LINES
    cmp dword[line_iterator], eax ; compare the index and the size
    jl check_tag_in_tags ; go back into the loop
    jge cache_miss ; otherwise, we are in the cache miss case

;; remember the index of the found tag in the edi register
;; and jump to the next step
cache_hit:
    mov edi, eax
    jmp retrieve_from_cache

;; add the address' tag into the tags array
cache_miss:
    mov eax, dword [tag]
    mov [ebx + 4 * edi], eax

; push the ebx and edx registers to stack in order to be able to
; use more registers
    push ebx
    push edx

;; in ebx, we will keep the address of the beginning of the to_replace
;; line on which we have to add the addresses
initialise_beginning_of_row:
    lea ebx, [ecx + 8 * edi];
 
    mov dword [column_iterator], 0

;; copy into the cache line the bytes from the 8 addresses
;;starting with the address of the tag
add_to_cache:
    mov eax, [column_iterator]
    ; move the already found tag in a register
    mov esi, [tag]
    ; move the value found at the register's address into
    ; a one byte register
    mov dh, [esi]
    ; move the one byte register into the cache matrix
    mov [ebx + eax], dh

    inc dword [column_iterator] ; increase the column iterator
    inc dword [tag] ; increase the value of the tag

    ; check if we have reached the end of the current line
    mov eax, dword [column_iterator]
    cmp eax, CACHE_LINE_SIZE
    jl add_to_cache ; go back into the loop

; retrieve the values from the edx and ebx registers
    pop edx
    pop ebx

;; retrieve the address of reg from the cache
retrieve_from_cache:
    ; retrieve the initial value of eax and push the value of edx
    pop eax
    push edx
    mov edx, dword [offset]
    ; in ebx, keep the address of the beginning of the line
    ; on which the address is found
    lea ebx, [ecx + 8 * edi]
    ; move the already found offset in a register
    mov esi, edx
    ; move the value found at the register's address into
    ; a one byte register
    mov dl, [ebx + esi]
    ; move the one byte register into address of reg
    mov [eax], dl
    ; retrieve the value of edx
    pop edx

    popa
    leave
    ret
