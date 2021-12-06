section .text
  global _start

_start:
mov rax, 80
call dayRoutine
mov rax, 256-80
call dayRoutine
call exit


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



section	.data
nums dq 0, 119, 45, 48, 40, 48, 0, 0, 0
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
