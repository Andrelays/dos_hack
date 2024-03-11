.model tiny
.286
.code
org 100h
locals @@

Start:
        mov dx, offset prompt_for_input
        mov ah, 09h                                     ;printing an input prompt
        int 21h                                         ; DOS -	PRINT STRING
                                                        ; DS:DX	-> string terminated by	"$"
        mov si, 0

@@continue_typing:                                      ;data entry
        mov ah, 07h
        int 21h                                         ;al - ascii code character
        cmp al, 0dh                                     ;if (al is '\r') - stop (pressed enter)
        je @@end_typing
        mov user_input[si], al                          ;si - the first free cell of the array
        inc si                                          ;si++
        jmp @@continue_typing
@@end_typing:
        dec si                                          ;si - the last cell of the array
        call calculate_hash

        cmp bx, password                                ;if (bx == password)
        jne @@input_failed

@@input_passed:                                         ;The output password is accepted
        mov dx, offset correct_password_message
        mov ah, 09h
        int 21h
        jmp @@completion_of_program

@@input_failed:                                         ;The output password is not accepted
        mov dx, offset incorrect_password_message
        mov ah, 09h
        int 21h

@@completion_of_program:

        mov ax, 4c00h
        int 21h

        user_input db 8 dup('0')                        ;the first vulnerability is the buffer in front of the hash function
;---------------------------FUNCTIONS------------------------------------
;-------------------------CALCUCATE_HASH---------------------------------
;calculates the hash using Fletcher's checksum algorithm
;Entry: si - the number of bytes in the entered password
;Destr: СX, BX, DI
;Ret: BX - hash
;------------------------------------------------------------------------
calculate_hash		proc
        mov cx, 0               ;sum1
        mov bx, 0               ;sum2
        mov di, 0               ;index
@@for_cycle:
        cmp di, si              ;for (index = 0; index < count; ++index)
        je @@end_for_cycle      ;
        add cl, user_input[di]  ;sum1 = (sum1 + data[index]) % 255
        add bl, cl              ;sum2 = (sum2 + sum1) % 255
        inc di
        jmp @@for_cycle

@@end_for_cycle:
        shl bx, 8
        or  bx, cx
        ret                     ;return (sum2 << 8) | sum1
calculate_hash		endp

        prompt_for_input db 'Password: $'
        incorrect_password_message db 'The password is not accepted$'
        correct_password_message   db 'The password is accepted$'
        password dw 9463h       ;password is 123

end             Start
