section .text
 global _start

_start:
call readFile
call initNums
 mov rax, 80
call dayRoutine
 mov rax, 256-80
call dayRoutine
jmp exit


initNums:
mov ecx, 0
mov edx, [indicesSize]

initNumsLoop:
cmp ecx, edx
jl initNumsNoRet
ret

initNumsNoRet:
mov ebx, 0
mov bl, indices[ecx]
shl ebx, 3 ; multiply by 8
mov rax, nums[ebx]
add rax, 1
mov nums[ebx], rax
add ecx, 1
jmp initNumsLoop


dayRoutine:
; rax: days left

; first check if we can break
cmp rax, 0
je printResult
push rax

; save nums[0]
mov rax, [nums]
push rax

call lookAtNums

; mov old nums[0] to end of nums
pop rax
add [nums+lenNums-3*8], rax
mov [nums+lenNums-1*8], rax

; pop & decrement days left and loop
pop rax ; get days left back
sub rax, 1
jmp dayRoutine


lookAtNums:
mov ecx, 0

lookAtNumLoop:
; num is ecx
cmp ecx, lenNums-2*8
jle lookAtNumDontRet
ret

lookAtNumDontRet:
mov rax, nums[ecx+8]
mov nums[ecx], rax

add ecx, 8
jmp lookAtNumLoop


printResult:
mov rax, 0
mov ecx, 0

printResultLoop:
cmp ecx, lenNums
je printResultAfterLoop
mov rbx, nums[ecx]
add rax, rbx
add ecx, 8
jmp printResultLoop

printResultAfterLoop:
call printDecNum
call printNewline
ret


exit:
mov eax,1
int 0x80


helloWorld:
mov edx, len
mov ecx, msg
call print
jmp printNewline


printNumsList:
mov ecx, 0

printNumsListLoop:
cmp ecx, lenNums
jl printNumsListNotRet
jmp printNewline

printNumsListNotRet:
mov rax, nums[ecx]
push rcx
call printDecNum
call printSpace
pop rcx
add ecx, 8
jmp printNumsListLoop


printBinNum:
; num stored in rax
mov ebx, binNumMsg+lenBinNumMsg-1

printBinNumLoop:
cmp ebx, binNumMsg
jl printBinNumAfterLoop
mov cl, al
and cl, 1
add cl, '0'
mov [ebx], cl
shr rax, 1
sub ebx, 1
jmp printBinNumLoop

printBinNumAfterLoop:
mov edx, lenBinNumMsg
mov ecx, binNumMsg
jmp print


printHexaNum:
; num stored in rax
mov ebx, hexaNumMsg+lenHexaNumMsg-1

printHexaNumLoop:
cmp ebx, binNumMsg
jl printHexaNumAfterLoop
mov cl, al
and cl, 0b1111
cmp cl, 9
jg printHexaNumOverNine
add cl, '0'
jmp printHexaNumLoopAround

printHexaNumOverNine:
sub cl, 10
add cl, 'A'

printHexaNumLoopAround:
mov [ebx], cl
shr rax, 4
sub ebx, 1
jmp printHexaNumLoop

printHexaNumAfterLoop:
mov edx, lenHexaNumMsg
mov ecx, hexaNumMsg
jmp print


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

readFile:
mov ebx, fileName
mov eax, 5 ; open
mov ecx, 0 ; read-only
int 0x80
mov ebx, eax ; file descriptor
mov eax, 3   ; read
mov ecx, fileBuf
mov edx, 1000
int 0x80
mov [fileBufAmtFilled], eax
jmp parseFile


parseFile:
mov rax, 0
mov edx, [fileBufAmtFilled]
mov ecx, 0 ; fileBuf index
mov ebx, 0 ; indices index

parseFileLoop:
cmp ecx, edx
jl parseFileDontRet
mov [indicesSize], ebx
ret

parseFileDontRet:
mov al, fileBuf[ecx]
sub al, '0'
mov indices[ebx], rax
add ecx, 2
add ebx, 1
jmp parseFileLoop


section	.data

indices times 1000 db 0
indicesSize dd 0

nums times 9 dq 0
lenNums equ $ - nums

msg db 'Hello, world!'
len equ $ - msg

binNumMsg times 64 db 0
lenBinNumMsg equ $ - binNumMsg

hexaNumMsg times 16 db 0
lenHexaNumMsg equ $ - hexaNumMsg

decNumMsg times 20 db 0
lenDecNumMsg equ $ - decNumMsg

space db ' '
newline db 0xa

fileBuf times 2000 db 0
fileBufLen equ $ - fileBuf
fileBufAmtFilled dd 0

fileName db 'inputs/D6.txt'
fileNameLen equ $ - fileName
