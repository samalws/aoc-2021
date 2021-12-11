section .text
 global _start

_start:
call readFile
call main1
mov rax, [numFlashes]
call printDecNum
call printNewline
call main2
mov rax, rcx
call printDecNum
call printNewline
call exit


main1:
mov rcx, 0

mainLoop1:
push rcx
call tick
pop rcx
inc rcx
cmp rcx, 100
je retTag
jmp mainLoop1


main2:
mov rcx, 101

mainLoop2:
mov rdx, [numFlashes]
push rcx
push rdx
call tick
pop rdx
pop rcx
mov rax, [numFlashes]
sub rax, rdx
cmp rax, (rows-2)*(cols-1)
je retTag
inc rcx
jmp mainLoop2


tick:
call incAll
call repeatFlash
call resetFlashes
ret


incAll:
mov ecx, 0

incAllLoop:
mov al, crabs[ecx]
cmp al, paddingVal
je incAllLoopInc
inc al
mov crabs[ecx], al

incAllLoopInc:
inc ecx
cmp ecx, crabsLen
je retTag
jmp incAllLoop


repeatFlash:
call flash
cmp rdx, 0
je retTag
mov rbx, [numFlashes]
add rbx, rdx
mov [numFlashes], rbx
jmp repeatFlash


flash:
mov ecx, 0
mov rdx, 0

flashLoop:
mov al, crabs[ecx]
cmp al, paddingVal
je flashLoopInc
cmp al, flashedVal
je flashLoopInc
cmp al, flashVal
jl flashLoopInc
mov al, flashedVal
mov crabs[ecx], al
inc rdx
push rdx
call incNeighbors
pop rdx

flashLoopInc:
inc ecx
cmp ecx, crabsLen
je retTag
jmp flashLoop 


incNeighbors:
mov eax, -cols
mov ebx, -1

incNeighborsLoop:
mov edx, eax
add edx, ebx
add edx, ecx
push rax
mov al, crabs[edx]
cmp al, paddingVal
je incNeighborsInc
cmp al, flashedVal
je incNeighborsInc
inc al
mov crabs[edx], al

incNeighborsInc:
pop rax
add eax, cols
cmp eax, cols
jle incNeighborsLoop
mov eax, -cols
inc ebx
cmp ebx, 1
jg retTag
jmp incNeighborsLoop


resetFlashes:
mov ecx, 0

resetFlashesLoop:
mov al, crabs[ecx]
cmp al, flashedVal
jne resetFlashesLoopInc
mov al, resetVal
mov crabs[ecx], al

resetFlashesLoopInc:
inc ecx
cmp ecx, crabsLen
je retTag
jmp resetFlashesLoop


retTag:
ret


printDecNum:
; num stored in rax
mov ebx, decNumMsg+lenDecNumMsg-1

printDecNumLoop:
cmp ebx, decNumMsg
jl printDecNumAfterLoop
mov rcx, 10
mov rdx, 0
div rcx
add dl, '0'
mov [ebx], dl
sub ebx, 1
jmp printDecNumLoop

printDecNumAfterLoop:
mov edx, lenDecNumMsg
mov ecx, decNumMsg
jmp print


printNewline:
mov ecx, newline
mov edx, 1
jmp print


printSpace:
mov ecx, space
mov edx, 1
jmp print


print:
; msg stored in ecx
; len stored in edx
mov ebx, 1
mov eax, 4
int 0x80
ret


exit:
mov eax, 0
int 0x80


readFile:
mov ebx, fileName
mov eax, 5 ; open
mov ecx, 0 ; read-only
int 0x80
mov ebx, eax ; file descriptor
mov eax, 3   ; read
mov ecx, crabs+cols+1
mov edx, 1000 ; max length
int 0x80
jmp parseFile


parseFile:
mov ecx, 0
mov al, paddingVal

parseFileLoop:
mov al, crabs[ecx]
cmp al, 0xa
je parseFileLoopNewline
sub al, '0'
jmp parseFileLoopInc

parseFileLoopNewline:
mov al, paddingVal

parseFileLoopInc:
mov crabs[ecx], al
inc ecx
cmp ecx, crabsLen
je retTag
jmp parseFileLoop



section .data
paddingVal equ 0xFF
flashedVal equ 0xFE
flashVal equ 10
resetVal equ 0
rows equ 12
cols equ 11
crabsLen equ rows*cols+1
crabs times crabsLen db 0xa
numFlashes dq 0

decNumMsg times 20 db 0
lenDecNumMsg equ $ - decNumMsg

space db ' '
newline db 0xa

fileName db "inputs/D11.txt"
