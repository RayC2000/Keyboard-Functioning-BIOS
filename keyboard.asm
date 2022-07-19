section .data


section .bss
row resb 4
column resb 4
char resb 1
maxColumns resb 4


section .code

; Set video mode
setVideo:
mov ah, 0		; 320x200 256 color graphics (MCGA,VGA)
mov al, 13h
int 10h

; Get maximum columns
getColumns:
mov ah, 0xf
int 10h
mov [maxColumns], ah

; Read character and store it
readChar:
mov ah, 0
int 16h
cmp al, 0x1C0D
je newLine
cmp al, 0x0E08
je goPrevChar
mov [char], al

; Write character read
writeChar:
mov ah, 0xe
mov al, [char]
mov bh, 0
mov bl, 2
int 10h

jmp readChar

; Create new line
newLine:
call getPosition
mov [row], dh
mov [column], dl
mov ah, 2
mov bh, 0
mov dh, [row]
inc dh
mov dl, 0
int 10h
jmp readChar

; Delete current character
goPrevChar:
call getPosition
mov [row], dh
mov [column], dl
cmp dl, 0
je goPrevLine
mov ah, [column]
dec ah
mov dl, ah
mov dh, [row]
mov ah, 2
mov bh, 0
int 10h
mov ah, 0xa
mov al, 0
mov bh, 0
mov bl, 0
mov cx, 1
int 10h
jmp readChar

; Delete current line
goPrevLine:
call getPosition
cmp dh, 0
jle readChar
mov ah, 2
mov bh, 0
dec dh
mov dl, [maxColumns]
int 10h
jmp readChar

; Get current cursor position FUNCTION
getPosition:
mov ah, 3
mov bh, 0
int 10h
ret


times 510 - ($ - $$) db 0
db 0x55, 0xaa