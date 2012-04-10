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
	col_copter		dw	00h				;REUSED - Rename
	row_copter		dw	00h				;REUSED - Rename
	ncol	dw	00h
	nrow	dw	00h
	delay1 dw 00h
	delay2 dw 00h
	delay3 dw 00h
	delay4 dw 00h
	tempend dw	00h
	tempcol dw  00h
	linecol dw  00h
	testend		dw	00h
	testrow		dw	00h
	linecolor	dw	00h
	obsrow		db	00h
	obscol		dw	00h
	obstaclecol dw	00h
	linestart	dw	00h
	lineend		dw	00h
	count1		dw	00h
	count2		dw	00h
	count3		dw	00h
	topcurve db 320 dup(0)
	filename db "curve1.txt"
	randnum	 db 00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											CODE SEGMENT														   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
.code

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;MACROS START HERE:
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
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

START:
	
	mov ax, @data
	mov ds, ax
	
	mov al, 13h
	mov ah, 0
	int 10h			; set screen to 256 colors, 320x200 pixels.

	;-------------- 
	;FRAME IS DRAWN
	
	call SetMode
	call ReadCurve
	mov linecolor,1010b
	mov linecol,50
	mov linestart,30
	mov lineend,70

	call MoveFrame
	
	;---------------
	;Draw the Initial Copter
	mov current_copter_row, 100
	mov current_copter_col, 70
	
	DrawCopter current_copter_row, current_copter_col
	DrawCopter 200,140
	;------------------	

	comment/*
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
		
		go_down:
			push bx
			mov bx, current_copter_row
			sub bx , 5	
			mov current_copter_row, bx
			mov dx, current_copter_col
			;DrawCopter bx , dx
			pop bx
			jmp check_esc_key
			
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
			/*	
		mov ah, 0
		int 16h
			
		mov ax, 4c00h
		int 21h
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;;;;																												 ;;;;
;;;;						 				PROCEDURES ARE LISTED BELOW											     ;;;;
;;;;																												 ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
	
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; To set video mode
	SetMode	PROC
					
		mov al,13h
		mov ah,00h
		int 10h
		ret
		
	SetMode	ENDP
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; procedure  to draw vertical line
	; linecolor - used to pass color of the line
	; linestart - used to pass starting pixel of th  eline
	; lineend - used to pass end pixel of the line
	; linecol - used to pass column of line
	DrawVertLine PROC
		mov ax,linecolor
		mov cx,linecol
		mov dx,linestart
		mov ah,0ch
		vnext:
			int 10h
			inc dx
			cmp dx,lineend
			jbe vnext
	ret
	DrawVertLine ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; procedure to draw curve
	DrawCurve PROC
				
		lea si,topcurve 
		mov linecol,00h
		mov lineend,00h
		mov linecolor,1010b
		nextline:
			mov linestart,0
			mov bl,[si]
			mov bh,00h
			mov lineend,bx
			inc si
					
		call DrawVertLine

		mov linestart,bx
		add linestart,154
		mov lineend,200
		call drawvertline 

		inc linecol
		cmp linecol,320
		jb nextline

	ret
	DrawCurve ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	; procedure to put delay in loops
	Delay	PROC
		mov delay1,00h
		waitloop1:
			inc delay1
			mov delay2,00h
		waitloop2:		
			inc delay2
			mov delay3,00h

		waitloop3:
			inc delay3
			mov delay4,00h
		waitloop4:	
			inc delay4
			cmp delay4,65000
			jbe waitloop4
	
		cmp delay3,65000
		jbe waitloop3

		cmp delay2,65000
		jbe waitloop2

		cmp delay1,65000
		jbe waitloop1

		ret
	Delay	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Procedure to move frame (moving curve and obstacle)
	; procedure calls movecurve and moveobstacle

	MoveFrame PROC
		call drawcurve
		
		nextobstacle:
			mov count2,00h
			
			mov linecolor,1010b
			mov obstaclecol,299
			call randomnum
			mov bl,randnum
			mov obsrow,bl
		nextframe:
			inc count2
			mov testrow,00h
			mov testend,30
			call movecurve
			mov testrow,169
			mov testend,200
			call movecurve
			call moveobstacle
			dec obstaclecol
	
			cmp count2,320
			jbe	nextframe
			
			mov count3,00h
			mov linecolor,0000b
			mov linecol,298
			mov linestart,31
			mov lineend,169
		nextl:	
			;inc linecol
			;call drawvertline
			;cmp count3,20
			;jbe nextl
			
			;mov linecolor,1010b
			jmp nextobstacle
	MoveFrame	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	ReadCurve	PROC
		mov al, 2				;al has access or sharing modes
		mov dx, offset filename ;DS:DX - ASCIZ file name
		mov ah, 3dh				;Open existing file
		int 21h					;Do it.
		
		;Read from the file
		mov bx, ax				;Pass on the file handle returned after opening the file to bx	
		mov cx, 320				;Number of bytes to read
		mov dx, offset topcurve	;Buffer for data
		mov ah, 3fh				;Read from file to buffer
		int 21h					;Do it.

		mov ah, 3eh				;Close the file
		int 21h					;Do it.

		ret
	ReadCurve	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
 	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	; Procedure to move the top and bottom curves
	; checks color of pixels in next column and moves accordingly
	MoveCurve	PROC	
	
		mov col_copter,00h
		nextcol:
			mov bx,testrow
			mov row_copter,bx
			cmp col_copter,319
			je lastcol

			mov bx,col_copter
			inc bx
			mov ncol,bx
			jmp nextrow

		lastcol:
			mov ncol,00h

		nextrow:
			mov ah,0dh
			mov cx,col_copter
			mov dx,row_copter
			int 10h
		
		cmp al,0000b
		je continue
		cmp al,1010b
		jne goout
	
	continue:
		mov ah,0dh
		mov cx,ncol
		mov dx,row_copter
		int 10h

		mov bl,al
		mov ah,0ch
		mov al,bl
		mov cx,col_copter
		mov dx,row_copter
		int 10h

		inc row_copter
		mov bx,testend
		cmp row_copter,bx
		jbe nextrow

		inc col_copter
		cmp col_copter,319
		jbe nextcol
	goout:
		ret
	MoveCurve	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; draws one obstacle
	; top left pixel passed as obsrow,obscol
	DrawObstacle PROC
		mov bh,0
		mov bl,obsrow
		mov count1,00h
		mov linestart,bx
		add bx,55
		mov lineend,bx
		mov bx,obscol
		mov linecol,bx
	nextline1:
		call DrawVertLine
		inc linecol
		inc count1
		cmp count1,20
		jbe nextline1

		ret
	DrawObstacle ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; moves the obstacle by one column forward
	; obstaclecol variable used to pass column of the obstacle
	MoveObstacle PROC
		mov bx,obstaclecol
		mov obscol,bx
	;	call drawobstacle

	nextpos:
		dec obscol
		mov linecolor,1010b
		call drawobstacle
		
		mov ax,obscol
		add ax,20
		mov linecol,ax
		mov ah,0
		mov al,obsrow
		mov linestart,ax
		add ax,55
		mov lineend,ax
		mov linecolor,0000b
		call drawvertline

		mov linecolor,1010b
		ret
	MoveObstacle ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	RandomNum PROC
		mov ah,2ch
		int 21h
		mov dh,00h
		mov ax,dx
		mov dl,50
		div dl
		add ah,40

		mov randnum,ah

		ret
	RandomNum ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

end START
