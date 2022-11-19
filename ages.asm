;; Profeanu Ioana, 323CA

; This is your structure
struc  my_date
    .day: resw 1
    .month: resw 1
    .year: resd 1
endstruc

section .text
    global ages

; void ages(int len, struct my_date* present, struct my_date* dates, int* all_ages);
ages:
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; present
    mov     edi, [ebp + 16] ; dates
    mov     ecx, [ebp + 20] ; all_ages

;; initialise the registers
initialise_registers:
    push edx ; add the value of edx to stack (the len value)
    xor ebx, ebx ; iteration counter

;; compare the present year and the current iteration year
compare_years:
    ; move the years into registers
    mov eax, [esi + my_date.year]
    mov edx, [edi + 8 * ebx + my_date.year]
    cmp eax, edx ; compare years
    jg present_year_greater ; if the present year is greater
    jle zero_years ; if the present year is equal or less

;; if the present year is greater than the year of the current person
present_year_greater:
    ; put the months into one byte registers
    mov ax, [esi + my_date.month]
    mov dx, [edi + 8 * ebx + my_date.month]
    cmp ax, dx ; compare months
    ; if the present month is greater than the current person's month
    jg result_year_difference
    ; if the present month is lower than the current person's month
    jl result_year_difference_minus_one
    ; if the months are equal
    je same_month

;; if the present year is equal or less than the person's year,
;; it means the person has 0 years
zero_years:
    mov eax, [ecx + ebx] ; into the array of ages, get to the current person
    mov eax, 0 ; add the age 0 into the array
    jmp continue_iteration ; continue the iteration

;; in this case, the age of the person will be the
;; difference between the years
result_year_difference:
    ; move the years into registers
    mov eax, [esi + my_date.year]
    mov edx, [edi + 8 * ebx + my_date.year]
    ; substract the person's year from the current year
    sub eax, edx
    mov [ecx + 4 * ebx], eax ; add the age into the age array
    jmp continue_iteration ; continue the iteration

;; in this case, the age of the person will be the
;; difference between the years minus one
result_year_difference_minus_one:
    ; move the years into registers
    mov eax, [esi + my_date.year]
    mov edx, [edi + 8 * ebx + my_date.year]
    ; substract the person's year from the current year
    sub eax, edx
    ; decrement the difference
    dec eax
    mov [ecx + 4 * ebx], eax ; add the age into the age array
    jmp continue_iteration ; continue the iteration

;; if the present month and the person's month are equal
same_month:
    ; move the days into registers
    mov ax, [esi + my_date.day]
    mov dx, [edi + 8 * ebx + my_date.day]
    cmp ax, dx ; compare days
    jge result_year_difference ; if the current day is greater or equal
    jl result_year_difference_minus_one ; if the current day is less

;; continue the iteration through the array or dates
continue_iteration:
    pop edx ; retrieve the len value from the stack
    inc ebx ; increase the iterator
    cmp ebx, edx ; compare iterator and the length of the dates array
    push edx ; add the len value in the stack
    jl compare_years ; if lower, go back and repeat the process

    pop edx ; retrieve the len value from the stack (the stack should be empty)

    popa
    leave
    ret
