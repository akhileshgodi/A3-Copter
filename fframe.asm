
	.model small
	.stack 100h

CR equ 13d 		;Carriage Return ASCII value
LF equ 10d		;Next Line ASCII Value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											DATA SEGMENT														   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data
	col		dw	00h
	row		dw	00h
	ncol	dw	00h
	nrow	dw	00h
	tempend dw	00h
	tempcol dw  00h
	linecol dw  00h
	testend		dw	00h
	testrow		dw	00h
	linecolor	db	00h
	obsrow		db	00h
	obscol		dw	00h
	obstaclecol dw	00h
	linestart	dw	00h
	lineend		dw	00h
	count1		dw	00h
	count2		dw	00h
	topcurve db 320 dup(0)
	filename db "curve1.txt"
	randnum	 db 00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;											CODE SEGMENT														   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code

	START:

		mov ax,@data
		mov ds,ax
				
		call SetMode
		call ReadCurve
		
		mov linecolor,0011b
		mov linecol,50
		mov linestart,30
		mov lineend,70
		
		call MoveFrame

		mov ax,4c00h
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
	; Procedure to move frame (moving curve and obstacle)
	; Procedure calls MoveCurve and MoveObstacle

	MoveFrame 	PROC
		
		call DrawCurve
		
		nextobstacle:
			mov count2,00h
			mov obstaclecol,299
			call RandomNum
			mov bl,randnum
			mov obsrow,bl
		nextframe:
			inc count2
			mov testrow,00h
			mov testend,30
			call MoveCurve
			mov testrow,169
			mov testend,200
			call MoveCurve
			call MoveObstacle
			;call delay
			dec obstaclecol
	
			cmp count2,320
			jbe	nextframe
	
			jmp nextobstacle
			ret
	MoveFrame	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	; Procedure to move the top and bottom curves
	; checks color of pixels in next column and moves accordingly
	MoveCurve	PROC	
	
		mov col,00h
		nextcol:
			mov bx,testrow
			mov row,bx
			cmp col,319
			je lastcol

			mov bx,col
			inc bx
			mov ncol,bx
			jmp nextrow

		lastcol:
			mov ncol,00h

		nextrow:
			mov ah,0dh
			mov cx,col
			mov dx,row
			int 10h
		
		cmp al,0000b
		je continue
		cmp al,0011b
		jne goout
	
	continue:
		mov ah,0dh
		mov cx,ncol
		mov dx,row
		int 10h

		mov bl,al
		mov ah,0ch
		mov al,bl
		mov cx,col
		mov dx,row
		int 10h

		inc row
		mov bx,testend
		cmp row,bx
		jbe nextrow

		inc col
		cmp col,319
		jbe nextcol
	goout:
		ret
	MoveCurve	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Procedure  to draw vertical line
	; linecolor - used to pass color of the line
	; linestart - used to pass STARTing pixel of th  eline
	; lineend - used to pass end pixel of the line
	; linecol - used to pass column of line
	DrawVertLine PROC
		
		mov al,linecolor
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
	; Procedure to draw curve
	DrawCurve PROC
					
		lea si,topcurve		;The 320 bytes read from the file stored in topcurve. Load eff address to si
		mov linecol,00h		
		mov lineend,00h
		mov linecolor,0011b
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
			call DrawVertLine 
	
			inc linecol
			cmp linecol,320
			jb nextline
	
	ret
	DrawCurve ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; moves the obstacle by one column forward
	; obstaclecol variable used to pass column of the obstacle	
	MoveObstacle PROC
		mov bx,obstaclecol
		mov obscol,bx
		call DrawObstacle

		nextpos:
		mov linecolor,0000b
		call DrawObstacle
		dec obscol
		mov linecolor,0011b
		call DrawObstacle
		
		ret
	MoveObstacle ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; draws one obstacle
	; top left pixel passed as obsrow,obscol
	DrawObstacle PROC
		mov bh,0
		mov bl,obsrow
		mov count1,00h
		mov linestart,bx
		add bx,70
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
	RandomNum	PROC
		mov ah,2ch
		int 21h
		mov randnum,dl
		ret
	RandomNum	ENDP
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


end START		
