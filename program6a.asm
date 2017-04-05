TITLE  Program 6A    (program6a.asm)

; Author: Carlos Lopez-Molina
; Course: CS261 / Project ID: 6A           Date: 03/19/17
; *Program 6 Part A*
; Description: Program that gets 10 valid integers from the user and stores the numeric values in an array. The program then displays the integers, their sum, and their average.
; NOTE: User must enter 10 valid 32 bit integers error checking is done for each input (size, number).

INCLUDE Irvine32.inc

MAX = 4294967295 ;highest 32 bit num

;getString Macro: should display a prompt, then get the user’s keyboard input into a memory location
getString   MACRO   buffer, buffer1, buffer2
	mov		edx, OFFSET buffer
	call	WriteString

	mov		edx, OFFSET   buffer1
	mov		ecx, (SIZEOF buffer1) - 1
	call	ReadString
	mov		buffer2, eax
ENDM

;displayString MACRO: should the string stored in a specified memory location
displayString   MACRO   buffer
	mov		edx, OFFSET buffer 
	call	WriteString
ENDM

.data
intro		BYTE	"PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures",0
intro2		BYTE	"Written by: Carlos Lopez-Molina",0
intro3		BYTE	"Please provide 10 unsigned decimal integers.",0
intro4		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
intro5		BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0
rtotal		BYTE	"Running subtotal is: ",0
prompt		BYTE	"Please enter an unsigned number: ",0
error		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",0
againPrmpt	BYTE	"Please try again: ",0
showNums	BYTE	"You entered the following numbers:",0
sum			BYTE	"The sum of these numbers is: ", 0
avg			BYTE	"The average is: ",0
thanks		BYTE	"Thanks for playing!",0
array		BYTE	10 DUP(0)
num			DWORD	0
numArray	DWORD	10 DUP(?)
strArray	BYTE	20 DUP(?)

.code
main PROC

	;introduction
	push	OFFSET intro
	push	OFFSET intro2
	push	OFFSET intro3
	push	OFFSET intro4
	push	OFFSET intro5
	call	introduction

	;Convert string -> num
	push	OFFSET numArray
	push	OFFSET error
	push	OFFSET prompt
	push	OFFSET array
	push	num
	call	ReadVal
	call	CrLf

	;Convert num -> string
	push	OFFSET showNums
	push	OFFSET numArray
	push	OFFSET strArray
	call	WriteVal

	;Display sum and average
	push	OFFSET numArray
	push	OFFSET sum
	push	OFFSET avg
	call	Calculate
	call	CrLf

	;goodbye
	push	OFFSET thanks
	call	goodbye

	exit   ; exit to operating system
main ENDP

;---------------------------------------------------------------
; Procedure that outputs instructions that begin the program
; receives: offset of 5 strings
; returns: none
; preconditions: none
; registers changed: none
;---------------------------------------------------------------
introduction	PROC
    push	ebp
    mov     ebp,esp
    pushad

	;intro
    mov     edx, [ebp + 24]
    call	WriteString
    call	CrLf

	;intro2
    mov     edx, [ebp + 20]
    call	WriteString
    call    CrLf
	call    CrLf

	;intro3
    mov     edx, [ebp + 16]
    call	WriteString
   	call    CrLf

	;intro4
    mov     edx, [ebp + 12]
    call	WriteString
   	call    CrLf

	;intro5
    mov     edx, [ebp + 8]
    call	WriteString
	call    CrLf
	call    CrLf

    popad
    pop     ebp

    ret     2
introduction	ENDP

;---------------------------------------------------------------
; Procedure This procedure will read 10 inputs from the user and convert the string to an integer. Should invoke the getString macro to get the user’s string of digits. It should then convert the digit string to numeric, while validating the user’s input
; receives: offset of int array, prompt, int variable, size of string
; returns: none
; preconditions:  valid int
; registers changed: eax, esi, ebp,  edx
;---------------------------------------------------------------
ReadVal		PROC
    push	ebp
    mov     ebp, esp
    mov     esi, [ebp + 12]     ; points to the user's number
    mov     edi, [ebp + 24]     ; will hold the user's string as a number
    mov     ecx, 10				;set the outer loop
L1:
    pushad
    jmp		Try

again:
    mov		esi, [ebp + 12]      ; points to the user's number
Try:
    getString	prompt, array, [ebp + 8]      ; get the string from the user
    mov			edx, 0
    mov			ecx, [ebp + 8]   ;set the loop = size of the string
	
    cld

count:
    lodsb						;load the first byte
    cmp			ecx, 0
    je			done
    cmp			al, 48          ;is the value less than 0
    jl			badnum
    cmp			al, 57          ;is the value greater than 9
    jg			badnum
    jmp			save   
      
;error input
badnum:                     
    mov			edx, [ebp + 20]
    call		WriteString
	call		CrLf
    jmp			again
         
save:                
    sub			al, 48         ;convert to it's ASCII  equivalent
    push		eax               
    push		ecx
    mov			eax, edx         
    mov			ecx, 10        ;multiply edx by 10
    mul			ecx
    mov			edx, eax
    pop			ecx
    pop			eax

    push		ebx            ;add to the accumulator
    movsx		ebx, al
    add			edx, ebx
    pop			ebx
    loop		count

    mov			[edi],edx      ;save the converted string into an array as a numeric value
    popad
    cmp			ecx, 0         ;stop the outer loop
    je			done
    add			edi, 4         ;next position in the array
    loop		L1

done:
    pop			ebp

    ret			20
ReadVal      ENDP

;---------------------------------------------------------------
; Procedure that converts array of ints -> string and will display the string
; receives: offset of int array, str array and prompt
; returns: string array
; preconditions: values in int array
; registers changed: ebp, esi, edi, ecx, ebx, eax, edx
;---------------------------------------------------------------
WriteVal	PROC
    push	ebp
    mov     ebp, esp
    mov     esi, [ebp + 12]     ;Store the int array
    mov     edi, [ebp + 8]      ;Store the str array

    mov     edx, [ebp + 16]     ;Display ints -> string
    call    WriteString
    call    CrLf

    pushad   
    mov     ecx, 10          
      
check:
    push	ecx
    mov		ebx, 1000000000   ;max of a 32 bit register is 4b+

divide: 
    mov     eax, [esi]		;1st num of array
    cmp     eax, 0			;save if num == 0
    je      zero			;jumps
    cmp     eax, ebx         
    jg      Compute         ;if the divisor is less than the number process
    cmp     eax, ebx
    je      equal
    
	;reduce - divide the divisor by 10
    mov     eax, ebx        ;divide the divisor by 10
    mov     ebx, 10
    mov     edx, 0
    div     ebx
    mov     ebx, eax
    jmp     Divide

compute:
    mov     edx, 0          ;divide the number by ebx
    div     ebx
    add     eax, 48         ;convert to ascii
    cld
    stosb					;save the number as a string byte
    cmp     ebx, 100        ;the number is 100 or greater so jump to the special case
    jge     divAgain
    cmp     edx, 0          ;if there is a remainder repeat if not skip to the end

addcoma:
    mov     al, ','        
    stosb
	mov     al, ' '         
    stosb
    add     esi,  4
    pop     ecx
    loop	check
    cmp     ecx, 0
    je      done

doAgain:
    mov     eax, ebx		;reduce ebx to match the number of 10s place is the number
    push	ecx	
    mov     ecx, edx		;save the remainder
    mov		edx, 0
    mov     ebx, 10
    div     ebx
    mov     ebx, eax		;update ebx
    mov     eax, ecx		;now divide the remainder by the updated ebx
    pop     ecx
    mov     edx, 0
    div     ebx
    add     eax, 48
    cld
    stosb
    jmp     done2

done2:
    cmp     edx, 9	
    jg      doAgain			;if remainder > 9: keep reducing
    cmp     edx, 0			;repeat if remainder, else end
    je      addcoma
    mov     eax, edx		;else -> ascii && save
    add     eax, 48			;0
    cld
    stosb
    jmp     addcoma

zero:
    add     eax, 48
    cld
    stosb

    jmp     addcoma

equal:       
    cmp     eax,1
    je      zero			;save if 1
    mov     edx, 0         
    div     ebx
    add     eax, 48			;convert to ascii 0
    cld
    stosb

divAgain:
    push	ecx
    mov     ecx, edx        ;save the remainder
    mov     eax, ebx        ;divide the divisor by 10
    mov     ebx, 10
    mov     edx, 0
    div     ebx
    mov     ebx, eax        ;update the divisor
    mov     eax, ecx        ;restore the remainder
    pop     ecx
    mov     edx, 0
    div     ebx
    add     eax, 48
    cld
    stosb
    cmp     ebx, 1
    je      addcoma
    jmp     divAgain

done:
    displayString   strArray

    popad
    pop		ebp

    ret     12
WriteVal   ENDP

;---------------------------------------------------------------
; Procedure that calculates the average and sum of a set of numbers
; receives: offset of sum, avg, and array
; returns: none
; preconditions:  valid numbers used
; registers changed: eax, esi, ebp,  edx
;---------------------------------------------------------------
Calculate   PROC
    push	ebp
    mov     ebp, esp
    mov     esi, [ebp + 16]
    pushad

    call	CrLf
    mov     ecx, 10
    mov     eax, 0

sumlist:
    add     eax, [esi]			;sum on self
    add     esi, 4
    loop	sumlist
	
	mov		edx, [ebp + 12]      
    call	WriteString         ;display sum
    call	WriteDec
    call	CrLf

    mov     ebx, 10				;total vals
    mov     edx, 0
    div     ebx					;find the average
    
	mov     edx, [ebp + 8]
    call	WriteString         ;display average
    call	WriteDec
    call	CrLf

    popad
    pop		ebp

    ret		12
Calculate   ENDP

;---------------------------------------------------------------
; Procedure ending program and saying goodbye to the user
; receives: Offset thanks
; returns: none
; preconditions: none
; registers changed: ebp, edx
;---------------------------------------------------------------
goodbye      PROC
    push	ebp
    mov     ebp, esp
    push	edx

	;thanks
    mov     edx, [ebp + 8]
    call	WriteString
    call	CrLf

    pop     edx
    pop     ebp

    ret     4
goodbye		ENDP

END main