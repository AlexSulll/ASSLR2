.model  small
.186
.stack  100h
MAX =   256
.data
    filename        db  'output.txt',0
    input_message   db  'Enter your string: ','$'
    outrange        db  0Dh, 0Ah, 'Len string out of range','$'
    output_string   db  0Dh, 0Ah, 'Output: ','$'
    short_string    db  0Dh, 0Ah, 'Need more word','$'
    waiting         db  0Dh, 0Ah, 'Press any key to exit...','$'
    space           db  ?
    string          db  MAX DUP(?)
.code
Start:
    mov     ax,@data
    mov     ds,ax
    mov     es,ax
    mov     ah,09h
    mov     dx,offset input_message
    int     21h
    mov     di,offset space
    mov     al,20h
    stosb
    mov     si,di
    mov     cx,MAX
read_char:
    xor     ah,ah
    int     16h
    cmp     al,0Dh
    je      end_input
    cmp     al,08h
    je      backspace
    cmp     al,7Fh
    jae     read_char
    cmp     al,20h
    jb      read_char
    jne     no_space
    inc     bx
    dec     di
    scasb
    jne     no_space
    dec     bx
    jmp     read_char
backspace:
    cmp     di,si
    jz      read_char
    dec     di
    mov     al,20h
    scasb
    jz      minus_word
write_backspace:
    mov     ax,0E08h
    int     10h
    mov     al,20h
    int     10h
    mov     al,08h
    int     10h
    inc     cx
    dec     di
    loop    read_char
minus_word:
    dec     bx
    inc     cx
    jmp     write_backspace
no_space:
    mov     ah,14
    int     10h
    stosb
    loop    read_char
end_limit_char:
    mov     ah,09h
    mov     dx,offset outrange
    int     21h
end_input:
    mov     ax,0020h
    dec     di
    scasb
    jne     count_word
    dec     bx
    inc     cx
count_word:
    stosw
    cmp     bx,3
    jnl     more_four
short_input:
    mov     ah,09h
    mov     dx,offset short_string
    int     21h
    jmp     ozidanie
more_four:
    sub     cx,MAX
    not     cx
    mov     di,si
    mov     bx,si
    mov     ax,0320h
    mov     dh,1
fourth_word:
    scasb
    jne     next_char
    dec     ah
    jnz     next_char
    scasb
    jnb     output_str
    dec     di
    mov     dl,cl
    mov     cx,0FFFFh
    repnz   scasb
    not     cx
    sub     dl,cl
    dec     dh
    jz      reversing
    sub     di,cx
    xchg    si,di
    rep     movsb
    jmp     reset_values
reversing:
    mov     ah,cl
    dec     di
    dec     di
    xchg    si,di
looping_for_reverse:
    movsb
    dec     si
    dec     si
    loop    looping_for_reverse
    mov     cl,ah
    add     si,cx
    inc     si
    inc     si
reset_values:
    mov     cl,dl
    xchg    si,di
    mov     ah,3
next_char:
    loop    fourth_word     
output_str:
    mov     ah,   09h
    mov     dx,   offset output_string
    int     21h
    mov     dx,   offset filename            
    mov     ah,   03Ch                   
    int     21h 
    mov     dx,   bx
    not     bx
    mov     cx,   si
    add     cx,   bx
    mov     bx,   ax 
    mov     ah,   40h      
    int     21h
    mov     bx,   1   
    mov     ah,   40h      
    int     21h
ozidanie:
    mov     ah,03h
    int     10h
    mov     ah,02h
    inc     dh
    int     10h
    mov     ah,09h
    mov     dx,offset waiting
    int     21h
    xor     ah,ah
    int     16h
exit:
    mov     ah,4Ch
    int     21h
    end     Start