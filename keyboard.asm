bits 16
org 0x7c00

section .data


section .bss
row resb 4
column resb 4
char resb 1
maxColumns resb 4
lastColumn resb 4
rowForCheck resb 4
columnForCheck resb 4

section .code

; Set video mode
setVideo:
mov ah, 0		; 80x25 16 color text (CGA,EGA,MCGA,VGA)
mov al, 3
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
mov bl, 0xf
int 10h

jmp readChar

; Create new line
newLine:
call getPosition
mov [row], dh
mov [column], dl
mov [lastColumn], dl
mov [columnForCheck], dl
mov [rowForCheck], dh
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
mov ah, [rowForCheck]
sub dh, ah
cmp dh, 1
jng .notGreater
mov ah, [maxColumns]
mov [lastColumn], ah
.notGreater:
mov ah, 2
mov bh, 0
dec dh
mov dl, [lastColumn]
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
