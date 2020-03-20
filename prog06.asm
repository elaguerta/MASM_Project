TITLE Sum and Average of 10 Integers     (prog06.asm)

; Author: Elaine Laguerta 
; Last Modified: 14 March 2020
; OSU email address: laguerte@oregonstate.edu
; Course number/section: CS 271/400
; Project Number: 6                Due Date: 15 March 2020
; Description:
; This program gets 10 signed integers from the user as keyboard input, converts the strings 
; to numeric form, and stores the numeric values in an array. It displays the integers,
; and writes their sum and average to the console. 
; Implementation Notes: This program implements macros mGetString and mDisplayString. These macros use the 
;						ReadString and WriteString procedures from the Irvine32.inc Library 
;						to read from keyboard and write to console.

INCLUDE Irvine32.inc

; macro definitions
;___________________________________________________________________________________________________________
mGetString	MACRO	promptAddr, destAddr, buffer
; mGetString displays the prompt string stored at promptAddr.
; It then stores the user's keyboard input into memory location destAddr.  
; Receives:			promptAddr, destAddr, and buffer as macro arguments. 
;					Note that promptAddr and destAddr are addresses. 
; Pre-conditions:	String at promptAddr is string data of type BYTE terminated with a null byte. 
;					Memory at destAddr is allocated as type BYTE, with sufficient number of bytes 
;					for expected user input, with the final byte reserved for a null byte.
;					The programmer should account for 1 additional byte for the final null byte.
;					Parameter buffer is the number of bytes allocated at destAddr, including the null byte.
; Post-conditions:	The characters entered by the user will be saved as string data
;					at address destAddr. A maximum number of buffer - 1 characters will be saved,
;					terminated by a null byte.
; Registers changed: None.
		push	ecx							; save registers
		push	edx
		mov		edx, promptAddr				; precondition for WriteString
		call	WriteString					; display string at prompt to console
		mov		edx, destAddr				; precondition for ReadString
		mov		ecx, buffer					; precondition for ReadString
		call	ReadString					; keyboard input up to SIZEOF dest bytes -1 stored at dest
		pop		edx							; restore registers
		pop		ecx
ENDM

;_____________________________________________________________________________________________________________
mDisplayString	MACRO	strAddr
; mDisplayString displays the string data stored at strAddr.
; Receives:			strAddr, the offset of string data.  
; Pre-conditions:	String at strAddr is terminated with a null byte. 
; Post-conditions:	String data at strAddr is printed to console until the first null byte. 
; Registers changed: None.
		push	edx
		mov		edx, strAddr				; precondition for WriteString
		call	WriteString					; display string at prompt to console
		pop		edx
ENDM
;_____________________________________________________________________________________________________________

.data
intArray	SDWORD	10 DUP(?)		; array for storing 10 signed 32 bit integers
header		BYTE	"Programming Assignment 6: Practice with Macros and Keyboard Input",10,13,
					"Written by Elaine Laguerta",10,13,10,13,0
instr1		BYTE	"Please enter 10 signed decimal integers.", 10,13,
					"Each number needs to be small enough in magnitude to be stored as a signed ",
					"integer in a 32-bit register.", 10,13,0
instr2		BYTE	"After you have entered 10 numbers, I will display a list of your numbers, ", 10, 13,
					"their sum, and their average value.", 10, 13, 10, 13, 0
numPrompt	BYTE	"Enter a signed number: ",0		
invalidMsg	BYTE	"You did not enter a signed number or your number was too big. Try again.", 10, 13,0
listStr		BYTE	"Here are your numbers: ",0
sumStr		BYTE	"The sum of these numbers is: ",0
avgStr		BYTE	"The rounded average is: ",0

.code
main PROC

; display header and instructions, by invoking mDisplayString macro
	mDisplayString	OFFSET header		; display header
	mDisplayString	OFFSET instr1		; display instructions 
	mDisplayString	OFFSET instr2

; get numbers
	mov		ecx, LENGTHOF intArray		; loop counter for filling intArray with user values
	mov		esi, OFFSET intArray		; esi gets address of intArray[0]
	L1:
	push	OFFSET numPrompt			; push readVal args to stack
	push	OFFSET invalidMsg
	push	esi 
	call	readVal						; call readVal to store next number nin intArray[ecx]
	add		esi, 4						; increment destination address by 4 for DWORD
	loop	L1							; get next value from user
	call	Crlf						

; display array
	push	OFFSET intArray				; push displayList args to stack
	push	LENGTHOF intArray
	push	OFFSET listStr
	call	displayList					; display intArray 
	call	Crlf

; calculate sum of array
	push		OFFSET intArray			; push sumArray args to stack
	push		LENGTHOF intArray
	call		sumArray				; after call, the sum of array is in eax

; display sum
	mDisplayString OFFSET sumStr		; display label for sum
	push		eax						; push writeVal argument, the sum in eax
	call		writeVal				; display sum
	call		Crlf

; calculate average
	push		OFFSET intArray			; push avgArray args
	push		LENGTHOF intArray
	call		avgArray				; average of array in eax

; display average 
	mDisplayString OFFSET avgStr		; display label for average
	push		eax						; push writeVal argument, the average in eax
	call		writeVal				; display average
	call		Crlf
	exit								; exit to operating system 

main ENDP

;_____________________________________________________________________________________________________________
avgArray PROC
; avgArray returns the average of an array of signed integers
; Receives: arrayAddr, sizeArray on the stack
; Preconditions: arrayAddr points to the first element of an array of length sizeArray. 
;				 Elements are signed, 32-bit integers.
; Post-conditions: average of arrayAddr is returned in eax
; Implementation:  Assumes the sum of an array fits in a 32 bit register.
;					Average is rounded down to the next whole integer.
; Registers changed: eax gets integer average of array, rounded down.
	push	ebp				; set up activation fram
	mov		ebp, esp
	push	esi				; save registers	
	mov		esi, [ebp + 12] ; esi gets arrayAddr
	mov		ebx, [ebp + 8]	; ebx gets sizeArray
	push	esi				; push args for sumArray
	push	ebx
	call	sumArray		; sum of array in eax
	cdq						; sign extend into edx 
	idiv		ebx				; Divide sum by sizeArray (in ebx). Quotient in eax.

	pop		esi				; restore registers
	pop		ebp
	ret		8				; release 2 4-byte arguments and return.
							; Quotient returned in eax. 

avgArray ENDP

;_____________________________________________________________________________________________________________
sumArray PROC
; sumArray returns the sum of an array of signed integers
; Receives: arrayAddr, sizeArray on the stack
; Pre-conditions:  arrayAddr points to the first element of an array of length sizeArray.
;				   Elements are signed, 32-bit integers.
; Post-conditions: sum of arrayAddr returned in eax
; Implementation: assume the sum of the array fits in a 32 bit register
; Registers changed: eax gets the sum of array
	push	ebp				; set up activation frame
	mov		ebp, esp
	push	esi				; save registers
	push	edi
	push	ecx
	mov		esi, [ebp + 12]	;esi gets arrayAddr
	mov		eax, 0			; intialize sum returned in eax
	mov		ecx, [ebp + 8]	; set counter to sizeArray

	L1:
	add		eax, [esi]		; add next element in array to sum so far (in eax)
	add		esi, 4			; point esi to next element
	loop	L1				; continue to next element

	pop		ecx				; restore registers
	pop		edi
	pop		esi
	pop		ebp	
	ret		8				; release 2 arguments and return
							; sum saved in eax
sumArray ENDP

;_____________________________________________________________________________________________________________
writeVal PROC
; writeVal converts a numeric integer value to a string of digits in base 10. It invokes the mDisplayString macro to 
; write the value to the console. It displays negative signs for negative numbers.
; Receives:			numVal: 32-bit signed integer, passed on the stack.
; Pre-conditions:	String at promptAddr is string data of type BYTE terminated with a null byte. 
;					numVal is a signed 32-bit integer
; Post-conditions:	String at labelAddr and numVal are written to the console without line breaks.
; Implementation:	Calls macro mDisplayString.
;					Values conversion to string releases the least significant digit   
;					first. Therefore, the string represenation is built up backwards,
;					from the null byte at the highest address, from least significant
;					digit to most significant digit, terminating at the low address
;					of the final converted string. 
;					Negative numbers are converted by negating the value, converting their magnitudes, and 
;					prepending with a '-'. 
;					The negative number 80000000h is handled as a special case. Since it does not have a 
;					two's complement representation, we add 1, get the positive magnitude, add 1 to the
;					conversion, and prepend the result with a '-'.
; Registers changed: None
		

		push		ebp								; set up activation frame
		mov			ebp, esp
		push		eax								; save registers
		push		ebx
		push		ecx
		push		edx								
		push		edi 

		sub			esp, 12							; create 12 bytes of local storage for converting numVal to String
													; Conversion needs at most 12 bytes: (1) sign, (10) digits, (1) null 

		; convert numVal to a string
		mov			ebx, [ebp + 8]					; ebx gets numVal
		mov			edi, esp						
		add			edi, 12							; edi starts from the (high address) end of the local strng 
		std											; direction flag: backwards
		
		; store null byte at the (high address) end
		mov			al, 0							; begin by storing a null byte to terminate the string
		stosb										; edi at next lowest byte	
		
		; clear ecx - it will be used as a flag to indicate the negative number with largest magnitude
		mov			ecx, 0							

		; convert numVal
		cmp			ebx, 0							; if numVal is positive, skip to digits
		jge			digits	
		cmp			ebx, 80000000h					; if numVal is largest magnitude negative, add 1 and set ecx to 1
		jne			negate
		inc			ebx
		mov			ecx, 1

		negate:
		neg			ebx								; numVal is negative. Find its positive magnitude
		
		digits:
		mov			eax, ebx						; move remaining value to convert from ebx to eax
		cdq											; sign extend eax into edx for division
		mov			ebx, 10							; divide by 10, digits will be from least to greatest significance
		div			ebx								; next digit in dl, remainder to convert in eax
		mov			ebx, eax						; move remainder to convert to ebx for next iteration
		mov			al, dl							; move next digit to al
		add			al, 48							; convert digit in al to ASCII
		cmp			ecx, 1							; if ecx was set, it was the largest magnitude negative
		jne			store_byte
		inc			al								; value was largest magnitude negative. increment to 
		mov			ecx, 0							; restore magnitude, and clear ecx
		store_byte:
		stosb										; store digit in next (lower in memory) byte
		cmp			ebx, 0							; quotient of 0 means conversion is complete
		jg			digits							; if not, continue with remaining value to convert

		end_str:									; edi is at one byte lower than beginning of converted string
		mov			ebx, [ebp + 8]					; reset ebx to the original numVal
		cmp			ebx, 0							; compare numVal value with 0
		jge			display							; if positive, continue display it as is
		mov			al, 45							; if numVal is negative, prepend the string with '-'
		stosb										; edi is at one byte lower than the '-'

		display:
		add				edi, 1				; move edi to beginning of converted string
		mDisplayString	edi					; display the converted string

		return:
		add			esp, 12							; release local string buffer
		pop			edi								; restore registers
		pop			edx
		pop			ecx
		pop			ebx
		pop			eax
		pop			ebp
		ret			4						; release 1 argument and return

writeVal ENDP

;_____________________________________________________________________________________________________________
readVal PROC
; readVal gets a string of digits fromt the user. It converts the digit string to numeric, while validating
; the user's input to be in the range of a signed 32-bit integer. If string is not a valid digit string 
; optionally prepended by a positive or negative sign, displays message at msgAddr.
; Trailing or leading whitespace is not considered valid. 
; Receives:			promptAddr, msgAddr, numDest, : 32-bit addresses passed on the stack.
; Pre-conditions:	String at promptAddr is string data of type BYTE terminated with a null byte. 
;					Memory at numDest is allocated as type SDWORD. 
; Post-conditions:	String data at promptAddr is printed to console until the first null byte. 
;					Valid string input is stored at strDest as null-terminated string data.
;					Valid user input is stored at numAddr as a signed 32-bit integer. 
;					If input is invalid, displays string at msgAddr
; Implementation:	Only 12 characters of user input are examined for a valid number.
;					Calls macro mGetString to temporarily store the digit string inputted by the user. 
;					Calls macro mDisplayString do display the title and prompt. 
; Registers changed: None.
		push		ebp								; set up activation frame
		mov			ebp, esp
		push		ecx								; save registers
		push		ebx
		push		edx
		push		esi
		push		edi
		
		sub			esp, 16							; create 16 local bytes of read buffer for reading value
		mov			esi, esp						; esi gets beginning of read buffer
		mov			edi, [ebp + 8]					; edi gets numDest

		prompt:
		mov			esi, esp						; esi gets beginning of read buffer
		mGetString	[ebp + 16], esi, 13				; Look at 12 characters from the user. Longest valid strings are
													; (1) sign, (10) digits. Add a 12th character to check for an invalid
													; additional digit. The 13th character is reserved for the null byte. 
		mov			SDWORD PTR [edi], 0				; reset destAddr to 0 
		mov			ebx, 1							; ebx will hold 1 or -1 for evaluating sign of integer by multiplying
													; initialize to 1 for positive integer

		; validate user input
		cld											; direction = forward. esi still points to beginning of read buffer 					
		lodsb										; look at first byte in buffer
		mov			ecx, 10							; loop counter for up to 10 digits

		; see if the first character is a sign indicator
		check_sign:
		cmp			al, 43							; compare to '+'
		jne			sign2
		lodsb										; if it's a '+', look at the next character
		jmp			check_digits					; check if the next character is a null	
		
		sign2:
		cmp			al, 45							; compare to '-'
		jne			check_digits
		mov			ebx, -1							; the first char is '-', indicating negative. 
		lodsb										; store a -1 in ebx and load the next character

		
		; look at up to 10 subsequent characters, to check at least 1, up to 10 consecutive digit characters
		
		check_digits:	
		cmp			al, 0							; if null byte, check null byte conditions
		je			null_byte
		cmp			al, 48							; compare to '0'
		jl			invalid
		cmp			al, 57							; compare to '9'
		jg			invalid

		valid:										; byte at al is a valid digit char
		mov			edx, [edi]						; edx gets numeric value so far
		imul		edx, 10							; shift all digits to next significant base 10 place
													; every subsequent digit will be shifted the previous digit to the next 10's place.
		jo			invalid							; if the 10x resulted in losing significant bits, overflow is set
													; and number is invalid
		sub			al, 48							; convert ASCII digit byte to decimal
		imul		bl								; multiply by 1 if positive, -1 if negative. The product is in ax.
		movsx		eax, ax							; extend sign the product into eax 
		add			eax, edx						; add to value so far
		jo			invalid							; if the addition caused overflow, number is invalid 
		mov			[edi], eax						; number is valid so far, save updated numeric value 
		mov			eax, 0							; clear eax for next iteration
		lodsb										; get next character 
		loop		check_digits					; check for more digits

		; check for a null byte after minimum 1 digit, max 10 digits
		null_byte:		
		cmp			al, 0							; after consecutive digits, next character must be null.
		jne			invalid							; if not, input is invalid
		cmp			ecx, 10							; if we see a null byte on the first digit spot, input is invalid
		je			invalid 
		jmp			return							; otherwise, we're seing null after up to 10 consecutive digits, so
													; input is valid and has been saved in [edi]. jump to return

		; not valid. Display invalid message and try again 
		invalid:
		mDisplayString	[ebp + 12]						; call macro mDisplayString with msgAddr
		jmp				prompt							; try again from prompt

		return:
		add			esp, 16							; release 16 bytes allocated local buffer 
		pop			edi								; restore registers
		pop			esi								
		pop			edx
		pop			ebx
		pop			ecx
		pop			ebp								; release activation frame
		ret			12								; release 3 arguments and return

readVal ENDP


;_____________________________________________________________________________________________________________
displayList	PROC
;	pList:		PTR	DWORD,	; [ebp + 44] pointer to the list
;	listSize:	DWORD,		; [ebp + 40] number of elements in list
;	titleAddr:	PTR BYTE	; [ebp + 36] address of the string to print as the title 
	
; displayList displays a list of unsigned integers. 
; This code is adapted from the OSU CS 271/400,
; Winter 2020, Lecture 20 slides, slide # 3. 
; The list is accessed using register indirect addressing.
; Receives:		(3) stack parameters: offset of the list, 
;				list size, and offset of the title string
; Returns:		Prints list to console, returns nothing
;__________________________________________________________
	pushad								; push all general purpose registers
	mov		ebp, esp
	mov		esi, [ebp + 44]				; offset of the list
	mov		ecx, [ebp + 40]				; number of elements in list				
	sub		esp, 4						; create local variable for delimeter
	mov		BYTE PTR [ebp - 4], 2Ch		; delimiter is 1 comma and 2 spaces between each number
	mov		BYTE PTR [ebp - 3], 20h
	mov		BYTE PTR [ebp - 2], 20h
	mov		BYTE PTR [ebp - 1], 0

	mDisplayString [ebp+36]			; print Title		
	call	Crlf

more:
	mov		eax,[esi]			; get current element
	push	eax
	call	writeVal			; write the value to the console
	cmp		ecx, 1				; if this is the last value in the array, skip the delimeter
	je		skip_delim
	mov		eax, esp			; print delimeter, stored at top of stack
	mDisplayString eax
	skip_delim:
	add		esi, 4				; get next element
	loop	more

endMore:
	mov		esp, ebp			; remove locals
	popad						; restore registers
	ret		12					; release 3 arguments and return
displayList	ENDP

END main

