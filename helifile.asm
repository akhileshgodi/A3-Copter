;----------------------------------------------------------
;	This file contains two macros :
;		DrawPixel( row, col ) and DrawCopter(row, col)
;	The global definitions made are important for the
;	functioning of DrawCopter
;-----------------------------------------------------------
%OUT-------------------------------------------------------------------------
%OUT TITLE: A3 Copter Game
%OUT Authors :
%OUT NOTES/TODO: 
%OUT 1. Use masm/tasm to compile
%OUT 2. Check for polling - int 16h -> ax = 00h/01h
%OUT 3. Need to erase the helicopter before redrawing
%OUT 4. Need a workaround for the lag in movement.
%OUT 5. Need to fix bugs in the macro DrawCopter.
%OUT-------------------------------------------------------------------------
	.model small
	.stack 100h

	
CR equ 13d 		;Carriage Return ASCII value
LF equ 10d		;Next Line ASCII Value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											DATA SEGMENT														   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data
	row dw 0
	col dw 0
	print_row dw 100
	print_col dw 100
	current_copter_row dw 0  
	current_copter_col dw 0
	image_width dw 29    ; actual length in the image is 11
	image_file db "heli.txt", 0 ; Place the heli.txt file in the MASM FOLDER
	file_handle dw ?
	buffer dw ?
	msg db " press any key.... $"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											CODE SEGMENT														   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
.code

	DrawPixel macro color, pixel_row, pixel_col
	    push 	ax
	    push 	cx
	    push 	dx

	    mov 	al, color
	    mov 	dx, pixel_row
	    mov 	cx, pixel_col
	    mov 	ah, 0ch
	    int 	10h    
	    pop 	dx
	    pop		cx
	    pop 	ax
	ENDM

	DrawCopter macro copter_row, copter_col
		
		LOCAL READ, ERR
		;LOCAL CONTINUE2,CONTINUE,ERR
		
		;---------------------------------------------------------------
		;	Assumes graphics mode is enabled
		;	Global definitions(must exist) : 
		;	row dw 0
		;	col dw 0
		;	print_row dw 0
		;	print_col dw 0
		;	current_copter_row dw 0
		;	current_copter_col dw 0
		;	image_width dw 29    ; actual length in the image is 30
		;	NOTE : The image width specified here must be consistent 
		;			with what you have specified in the file
		;			Here 29 => 30 numbers in the file represent one row
		;	image_file db "d:\heli.txt", 0
		;	file_handle dw ?
		;	buffer dw ?
		;---------------------------------------------------------------
		
		;pusha
		; First updating the current position of the copter
		mov ax, copter_row
		mov current_copter_row, ax
		mov ax, copter_col
		mov current_copter_col, ax
		
		
		; Opening the file for reading - NOTE : The file must be in the appropriate folder
		mov al,0        
		mov dx,offset image_file
		mov ah,3dh
		int 21h
		
		; If file is not read, jump to error
		jc err
		mov file_handle,ax 
		
		; The read cycle - Basically, numbers are read from the file, and corresponding colors are drawn on the screen
			read:
				mov bx,file_handle    
				mov dx,offset buffer
				mov al,0
				mov cx,1
				mov ah,3Fh
				int 21h
				
				cmp ax, 0
				je err
				
				mov dx,buffer 
				cmp dx, '0'
				jle continue2
				
				;cmp dx, 'Z'
				;jg continue_3
				;sub dx, 48
				
				mov dh, 0      
				mov ax, copter_row
				mov print_row, ax
				mov ax, row
				add print_row, ax
				mov ax, copter_col
				mov print_col, ax
				mov ax, col
				add print_col, ax
				
				DrawPixel dl, print_row, print_col
					
			continue2 :
				mov dx, col
				cmp dx, image_width
				jne continue
				inc row
				mov ax, -1
				mov col, ax
				
			continue :
				inc col
				;continue_3 :
				jmp read
		
		err:	
			
	ENDM
	jmp start
	;MACROS END HERE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

START:
	
	mov ax, @data
	mov ds, ax
	
	mov al, 13h
	mov ah, 0
	int 10h			; set screen to 256 colors, 320x200 pixels.
	
	mov current_copter_row, 100
	mov current_copter_col, 70
	
	;DrawCopter 100,70
	DrawCopter current_copter_row, current_copter_col
	
	
	
	;Go back to the normal mode!
	;mov al,03h
	;mov ah, 0
	;int 10h
	
	; reset mouse and get its status: 
	mov ax, 0
	int 33h
	cmp ax, 0

	; display mouse cursor: 
	mov ax, 1 
	int 33h 

	check_mouse_button:
		mov ax, 3
		int 33h
		cmp ax, 1
		je go_up
		;jmp go_down
		
		go_up:
			push bx
			mov current_copter_row, bx
			add bx , 5	
			mov bx, current_copter_row
			DrawCopter current_copter_row, current_copter_col
			pop bx
			jmp check_esc_key
		comment/*
		
		go_down:
			push bx
			mov bx, current_copter_row
			sub bx , 5	
			mov current_copter_row, bx
			mov dx, current_copter_col
			;DrawCopter bx , dx
			pop bx
			jmp check_esc_key
				/*	
		check_esc_key:
			mov dl, 255
			mov ah, 6
			int 21h
			cmp al, 27      ; esc? 
			jne check_mouse_button
	
	stop:
				
		mov ax, 03h 
		int 10h
				
		mov ah, 1
		mov ch, 0
		mov cl, 8
		int 10h
		
		lea dx, msg
		mov ax, 09
		int 21h
				
		mov ah, 0
		int 16h
			
		mov ax, 4c00h
		int 21h
	

end start
