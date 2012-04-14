;*****************************************************************************
;
;									A3-Copter
;					CS2610 - Assembly Language Lab project
;					Group : #16
;					1) Abhiram R
;					2) Akhilesh Godi
;					3) Anup Santosh	
;
;*****************************************************************************



.MODEL small
.STACK 100H

;-----------------------------------------------------------------------------
;								DATA SEGMENT
;-----------------------------------------------------------------------------

.DATA

	CR 			equ 13d 		;Carriage Return ASCII value
	LF			equ 10d		;Next Line ASCII Value
	VideoSeg equ 0B800H      ; video segment
	row 		dw 0
	col 		dw 0
	print_row 	dw 100
	print_col 	dw 100
	current_copter_row dw 0  
	current_copter_col dw 0
	image_width dw 29    ; actual length in the image is 30
	image_height dw 15
	image_file 	db "heli.txt", 0 ; Place the heli.txt file in the MASM FOLDER
	image_file_2 db "heli2.txt", 0
	turn 		dw 0
	file_handle dw ?
	buffer 		dw ?
	msg 		db "GAME OVER$"
	gameOverMsg db "GAME OVER$"
	newGameMsg db "- New Game$"
	exitGameMsg db "- Exit Game$"
	scoreMsg db "Score$"
	score 		dw 0
	
	col_copter	dw	00h				;REUSED - Rename
	row_copter	dw	00h				;REUSED - Rename
	ncol		dw		00h
	nrow		dw		00h
	detect_collision db 0
	delay1 		dw 00h
	delay2 		dw 00h
	delay3 		dw 00h
	delay4 		dw 00h
	tempend 	dw	00h
	tempcol 	dw  00h
	linecol 	dw  00h
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
	topcurve 	db 320 dup(0)
	filename 	db "curve3.txt"
	randnum	 	db 00h

	obscol1		dw	300
	obscol2		dw	300
	obscol3		dw	300
	obscol4		dw	300
	obscol5		dw	300
	rand1		dw	00h
	rand2		dw	00h
	rand3		dw	00h
	rand4		dw	00h
	rand5		dw	00h
	obsflag		db 00h

	obsdelay	dw	141
	obscount1	dw	00h
	obscount2	dw  00h
	obscount3	dw	00h
	obscount4	dw	00h
	obscount5	dw	00h
	
	colorflag	dw	00h
	count_ dw 00h
	linecol_ dw 30
	startcol dw 30
	startrow	dw 00h
	endrow		dw 00h
	endcol		dw	00H
	colr		db  1110b
	row3	dw 00h
	crow	dw	00h
	toptitle	db	320 dup(0)
	titlefile	db	"curve3.txt"

	AnyKey       DB     17,"press any key ..."
	NoMouse      DB     29,"mouse driver is not installed"
	CursorX      DW     5           ; text cursor X position
	CursorY      DW     5           ; text cursor Y position
	MouseX       DW     1           ; current mouse X position
	MouseY       DW     1           ; current mouse Y position
	MouseXo      DW    -1           ; last mouse X position
	MouseYo      DW    -1           ; last mouse Y position
	Buttons      DW     0           ; mouse buttons status
	FColor       DB    14           ; foreground color
	BColor       DB     1           ; background color

	C 	dw 	9100
	C1 	dw 	4304
	D 	dw 	4063
	D1 	dw 	3834
	E 	dw 	3619
	F 	dw 	3416
	F1 	dw 	3224
	G 	dw 	3043
	G1 	dw 	2873
	A 	dw 	2711
	A1 	dw 	2559
	B 	dw 	2415

;-----------------------------------------------------------------------------
;								CODE SEGMENT
;-----------------------------------------------------------------------------

.CODE

;-----------------------------------------------------------------------------
;							PROCEDURES AND MACROS
;-----------------------------------------------------------------------------
movCursor macro row, col
	mov ah, 2
	mov dh, row
	mov dl, col
	mov bh, 0
	int 10h
endm
readanddraw	proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov al,2
	mov dx,offset titlefile
	mov ah,3dh
	int 21h
	mov bx,ax
	mov cx,320
	mov dx,offset toptitle
	mov ah,3fh
	int 21h

	mov ah,3eh
	int 21h

	lea si,toptitle
	mov startcol,00h
	mov endcol,00h
	mov colr,1111b
nextl_:
	mov startrow,0
	mov bl,[si]
	mov bh,00h
	mov endrow,bx
	inc si
	call drawline
	
	mov startrow,bx
	add startrow,154
	mov endrow,200
	call drawline

	inc startcol
	inc endcol
	cmp endcol,320
	jb nextl_
	

	pop dx
	pop cx
	pop bx
	pop ax
	ret
readanddraw	endp
drawa	proc
	mov cx,linecol_
	mov startcol,cx

nextline1:
	mov cx,startcol
	mov dx,60
	mov al,0100b
	mov ah,0Ch

nextcol1:
	mov count_,00h
	inc cx
nextrow1:
	int 10h
	inc dx
	inc count_
	cmp count_,2
	jbe nextrow1

	cmp cx,43
	jbe nextcol1
	
	inc startcol
	cmp startcol,33
	jbe nextline1

	mov cx,linecol_
	mov startcol,cx

nextline2:
	mov cx,startcol
	mov dx,60
	mov al,0100b
	mov ah,0Ch

nextcol2:
	mov count_,00h
	dec cx
nextrow2:
	int 10h
	inc dx
	inc count_
	cmp count_,2
	jbe nextrow2

	cmp cx,20
	jge nextcol2
	
	inc startcol
	cmp startcol,33
	jbe nextline2


	mov dx,80

nextrow3:
	mov cx,25
nextcol3:
	int 10h
	inc cx
	cmp cx,40
	jbe nextcol3
	inc dx
	cmp dx,75
	jbe nextrow3
	ret
drawa	endp

draw3 proc
	mov cx,55
	mov al,0010b
	mov ah,0ch
	mov dx,60
nextrow6:
	mov cx,55
nextcol6:
	int 10h
	inc cx
	cmp cx,75
	jbe nextcol6

	inc dx
	cmp dx,63
	jbe nextrow6
	
	mov row3,60
nextline7:
	mov cx,75
	mov dx,row3
nextpx1:
	int 10h
	dec cx
	inc dx
	cmp cx,55
	jge nextpx1
	inc row3
	cmp row3,63
	jbe nextline7
	
	
	sub dx,4
	mov bx,dx
	sub dx,3
	mov row3,dx
nextline8:
	mov cx,55
	mov dx,row3
nextpx2:
	int 10h
	inc cx
	inc dx
	cmp cx,75
	jbe nextpx2
	inc row3
	cmp row3,bx
	jbe nextline8
	
	sub dx,2
	mov bx,dx
	sub dx,3
nextline9:
	mov cx,75
nextcol9:
	int 10h
	dec cx
	cmp cx,55
	jge nextcol9
	inc dx
	cmp dx,bx
	jbe nextline9
	ret

draw3	endp
drawc	proc
	mov colr,0100b

	mov startcol,100
	mov endcol,103
	mov startrow,60
	mov endrow,100
	call drawline

	mov startcol,103
	mov endcol,120
	mov startrow,60
	mov endrow,63
	call drawline

	mov startcol,103
	mov endcol,120
	mov startrow,97
	mov endrow,100
	call drawline
	ret

drawc	endp

drawo	proc
	mov colr,0001b

	mov startcol,125
	mov endcol,127
	mov startrow,60
	mov endrow,100
	call drawline

	mov startcol,143
	mov endcol,145
	mov startrow,60
	mov endrow,100
	call drawline

	mov startcol,127
	mov endcol,143
	mov startrow,60
	mov endrow,63
	call drawline

	mov startcol,127
	mov endcol,143
	mov startrow,97
	mov endrow,100
	call drawline


	ret
drawo	endp

drawp	proc
	mov colr,0100b

	mov startcol,150
	mov endcol,153
	mov startrow,60
	mov endrow,101
	call drawline

	mov startcol,153
	mov endcol,170
	mov startrow,60
	mov endrow,63
	call drawline

	mov startcol,167
	mov endcol,170
	mov startrow,60
	mov endrow,80
	call drawline

	mov startcol,153
	mov endcol,170
	mov startrow,77
	mov endrow,80
	call drawline
	ret
drawp	endp

drawt	proc
	mov colr,0100b

	mov startcol,175
	mov endcol,195
	mov startrow,60
	mov endrow,63
	call drawline

	mov startcol,184
	mov endcol,187
	mov startrow,60
	mov endrow,101
	call drawline

	ret
drawt	endp

drawe	proc
	mov colr,1111b

	mov startcol,200
	mov endcol,203
	mov startrow,60
	mov endrow,100
	call drawline

	mov startcol,200
	mov endcol,220
	mov startrow,60
	mov endrow,63
	call drawline

	mov startcol,200
	mov endcol,220
	mov startrow,97
	mov endrow,100
	call drawline

	mov startcol,200
	mov endcol,210
	mov startrow,79
	mov endrow,82
	call drawline

	ret
drawe	endp

drawr	proc
	mov colr,0001b

	mov startcol,225
	mov endcol,235
	mov startrow,30
	mov endrow,130
	call drawline

	mov startcol,235
	mov endcol,285
	mov startrow,30
	mov endrow,40
	call drawline

	mov startcol,275
	mov endcol,285
	mov startrow,30
	mov endrow,80
	call drawline

	mov startcol,225
	mov endcol,285
	mov startrow,70
	mov endrow,80
	call drawline
	
	mov al,0001h
	mov ah,0ch
	mov dx,65
	mov cx,225
	mov crow,63
nextpxl:
	int 10h
	inc dx
	inc cx
	cmp dx,150
	jg	nextline_
	cmp cx,305
	jg nextline_
	jmp nextpxl

nextline_:
	inc crow
	mov dx,crow
	mov cx,225
	cmp crow,77
	jbe nextpxl


	ret

drawr	endp
drawline	proc
	mov cx,startcol
	mov al,colr
	mov ah,0ch
nextcl:
	mov dx,startrow
nextrw:
	int 10h
	inc dx
	cmp dx,endrow
	jbe nextrw

	inc cx
	cmp cx,endcol
	jbe nextcl

	ret
drawline endp
	
colorscreen	proc
	mov dx,0
nextrow4:
	mov cx,0
	mov al,1110b
	mov ah,0ch

nextcol4:
	int 10h
	inc cx
	cmp cx,320
	jb nextcol4
	
	inc dx
	cmp dx,200
	jb nextrow4
	ret
colorscreen endp
;-----------------------------------------------------------------------------
;	DRAW A PIXEL - PARAMETERS - COLOR, ROW, COL
;-----------------------------------------------------------------------------
DrawPixel macro color, pixel_row, pixel_col
	    push 	ax
	    push 	cx
	    push 	dx
	    mov 	ax, color
	    mov 	dx, pixel_row
	    mov 	cx, pixel_col
	    mov 	ah, 0ch
	    int 	10h    
	    pop 	dx
	    pop		cx
	    pop 	ax

endm
;-----------------------------------------------------------------------------
;	SETS VIDEO MODE
;-----------------------------------------------------------------------------
SetMode	PROC
					
		mov 	al,13h
		mov 	ah,00h
		int 	10h
		ret
		
SetMode	ENDP
;-----------------------------------------------------------------------------
;	PROCEDURE TO DRAW VERTICAL LINES
; linecolor - used to pass color of the line
; linestart - used to pass starting pixel of th  eline
; lineend - used to pass end pixel of the line
; linecol - used to pass column of line
;-----------------------------------------------------------------------------
DrawVertLine PROC
		mov 	ax,linecolor
		mov 	cx,linecol
		mov 	dx,linestart
		mov 	ah,0ch
		vnext:
				int 	10h
				inc 	dx
				cmp 	dx,lineend
				jbe 	vnext
	ret
DrawVertLine ENDP
;-----------------------------------------------------------------------------
;	DRAW THE CURVE
;-----------------------------------------------------------------------------
DrawCurve PROC
				
		lea 	si,topcurve 
		mov 	linecol,00h
		mov		lineend,00h
		mov 	linecolor,1010b
		cmp colorflag,00h
		je	nextline
		mov linecolor,1111b
		nextline:
				mov linestart,0
				mov bl,[si]
				mov bh,00h
				mov lineend,bx
				inc si
					
		call 	DrawVertLine

		mov 	linestart,bx
		add 	linestart,154
		mov 	lineend,200
		call 	drawvertline 

		inc 	linecol
		cmp 	linecol,320
		jb 		nextline

	ret
DrawCurve ENDP
;-----------------------------------------------------------------------------
;	THE DELAY PROCEDURE
;-----------------------------------------------------------------------------
Delay	PROC
	push ax
    push bx
    push cx
    push dx
    
    mov dx,0000H
    mov cx,0000H
    delaying2:
    inc bx
    delaying:   
            inc dx
        	delaying1:   
                inc cx
             cmp cx,7FEEH
             jl delaying1
    	    cmp dx,2FFFH
            jl delaying
        	cmp bx,5
        	jl delaying2
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
Delay	ENDP
;-----------------------------------------------------------------------------
;	PROCEDURE TO MOVE THE FRAME AND THE OBSTACLE
;	CALLS - MOVECURVE AND MOVEOBSTACLE
;-----------------------------------------------------------------------------
comment/*
MoveFrame PROC
		call drawcurve
		
		nextobstacle:
			mov 	count2,00h
			mov 	linecolor,1010b
			mov 	obstaclecol,299
			call 	randomnum
			mov 	bl,randnum
			mov 	obsrow,bl
		nextframe:
			inc		count2
			mov 	testrow,00h
			mov 	testend,30
			call 	movecurve
			mov 	testrow,169
			mov 	testend,200
			call 	movecurve
			call 	moveobstacle
			dec 	obstaclecol
	
			cmp	 	count2,320
			jbe		nextframe
			
			mov	 	count3,00h
			mov 	linecolor,0000b
			mov 	linecol,298
			mov 	linestart,31
			mov 	lineend,169
		nextl:	
			;inc 	linecol
			;call 	drawvertline
			;cmp 	count3,20
			;jbe	nextl
			
			;mov	linecolor,1010b
			jmp 	nextobstacle
MoveFrame	ENDP
/*
;-----------------------------------------------------------------------------
;	READS THE CURVE FROM THE FILE
;-----------------------------------------------------------------------------
ReadCurve	PROC
		mov 	al, 2				;al has access or sharing modes
		mov 	dx, offset filename ;DS:DX - ASCIZ file name
		mov 	ah, 3dh				;Open existing file
		int 	21h					;Do it.
		
		;Read from the file
		;mov 
		mov 	bx, ax				;Pass on the file handle returned after opening the file to bx	
		mov 	cx, 320				;Number of bytes to read
		mov 	dx, offset topcurve	;Buffer for data
		mov 	ah, 3fh				;Read from file to buffer
		int 	21h					;Do it.

		mov 	ah, 3eh				;Close the file
		int 	21h					;Do it.

		ret
ReadCurve	ENDP

randobjects proc
		cmp obscol1,300
		jne	obs2
		cmp obsflag,0
		je tempjmp1
		mov obscol1,299
		mov obscount1,00h
		call randomnum
		mov bl,randnum
		mov bh, 0
		mov rand1,bx
		jmp tempjmp1
		
obs2:	cmp obscol2,300
		jne	obs3
		cmp obsflag,0
		je tempjmp1
		mov obscol2,299
		mov obscount2,00h
		call randomnum
		mov bl,randnum
		mov bh, 0
		mov rand2,bx
tempjmp1:	jmp obs6

obs3:	cmp obscol3,300
		jne	obs4
		cmp obsflag,0
		je obs6
		mov obscol3,299
		mov obscount3,00h
		call randomnum
		mov bl,randnum
		mov bh, 0
		mov rand3,bx	
		jmp obs6
obs4:
		cmp obscol4,300
		jne	obs5
		cmp obsflag,0
		je obs6
		mov obscol4,299
		mov obscount4,00h
		call randomnum
		mov bl,randnum
		mov bh, 0
		mov rand4,bx
		jmp obs6
obs5:		
		cmp obscol5,300
		jne	obs6
		cmp obsflag,0
		je obs6
		mov obscol5,299
		mov obscount5,00h
		call randomnum
		mov bl,randnum
		mov bh, 0
		mov rand5,bx
obs6:	
		cmp obscol1,300
		je	nextobs1
		mov bx,obscol1
		mov obstaclecol,bx
		mov bx,rand1
		mov obsrow,bl
		call moveobstacle
		dec obscol1
		inc obscount1
		cmp obscount1,320
		jbe nextobs1
		mov obscol1,300
nextobs1:
		cmp obscol2,300
		je	nextobs2
		mov bx,obscol2
		mov obstaclecol,bx
		mov bx,rand2
		mov obsrow,bl
		call moveobstacle
		dec obscol2
		inc obscount2
		cmp obscount2,320
		jbe nextobs2
		mov obscol2,300
nextobs2:
		cmp obscol3,300
		je	nextobs3
		mov bx,obscol3
		mov obstaclecol,bx
		mov bx,rand3
		mov obsrow,bl
		call moveobstacle
		dec obscol3
		inc obscount3
		cmp obscount3,320
		jbe nextobs3
		mov obscol3,300
nextobs3:
		cmp obscol4,300
		je	nextobs4
		mov bx,obscol4
		mov obstaclecol,bx
		mov bx,rand4
		mov obsrow,bl
		call moveobstacle
		dec obscol4
		inc obscount4
		cmp obscount4,320
		jbe nextobs4
		mov obscol4,300
nextobs4:
		cmp obscol5,300
		je	goout0
		mov bx,obscol5
		mov obstaclecol,bx
		mov bx,rand5
		mov obsrow,bl
		call moveobstacle
		dec obscol5
		inc obscount5
		cmp obscount5,320
		jbe goout0
		mov obscol,300

goout0:
		ret

randobjects	endp

;-----------------------------------------------------------------------------
; Procedure to move the top and bottom curves
; checks color of pixels in next column and moves accordingly
;-----------------------------------------------------------------------------
MoveCurve	PROC	
		mov 	col_copter,00h
		nextcol:
			mov		bx,testrow
			mov 	row_copter,bx
			cmp 	col_copter,319
			je 		lastcol

			mov		bx,col_copter
			inc		bx
			mov 	ncol,bx
			jmp 	nextrow

		lastcol:
			mov 	ncol,00h

		nextrow:
			mov		ah,0dh
			mov 	cx,col_copter
			mov 	dx,row_copter
			int		10h
		
		cmp 	al,0000b
		je 		continue_
		cmp 	al,1010b
		jne 	goout
	
	continue_:
		mov 	ah,0dh
		mov 	cx,ncol
		mov 	dx,row_copter
		int 	10h
		
		cmp al,0000b
		je continue9
		cmp	al,1010b
		jne goout
	continue9:
		mov 	bl,al
		mov 	ah,0ch
		mov 	al,bl
		mov 	cx,col_copter
		mov 	dx,row_copter
		int 	10h
	goout:
		inc 	row_copter
		mov 	bx,testend
		cmp 	row_copter,bx
		jbe 	nextrow
	
		inc 	col_copter
		cmp 	col_copter,319
		jbe 	nextcol
	
		ret
MoveCurve	ENDP

;-----------------------------------------------------------------------------
; DRAWS ONE OBSTACLE
; top left pixel passed as obsrow,obscol
;-----------------------------------------------------------------------------
DrawObstacle PROC

		push 	ax
		push 	bx
	
	
		mov 	row, 0
		mov 	col, 0
	
		mov 	al, obsrow
		mov 	ah, 0
		mov 	print_row, ax
	
		mov 	bx, obscol
		mov 	print_col, bx
	
		outerLoop4:
		
			innerLoop4:
		
				DrawPixel 1010b, print_row, print_col
				inc 	col
				inc 	print_col
			
				mov 	ax, col
				cmp 	ax, 20
				jle 	innerLoop4
			
			inc 	row
			inc 	print_row
			
			mov 	col, 0
			mov 	print_col, bx
			
			mov 	ax, row
			cmp 	ax, 55
			jle 	outerLoop4
		
	
		mov 	row, 0
		mov 	col, 0
		
		pop 	bx
		pop 	ax
		ret

DrawObstacle ENDP
;-----------------------------------------------------------------------------
; MOVES THE OBSTACLE BY ONE COLUMN FORWARD
; obstaclecol variable used to pass column of the obstacle
;-----------------------------------------------------------------------------

MoveObstacle PROC
		mov 	bx,obstaclecol
		mov		obscol,bx
	;	call 	drawobstacle

	nextpos:
		dec 	obscol
		mov 	linecolor,1010b
		call 	drawobstacle
		
		mov 	ax,obscol
		add 	ax,20
		mov 	linecol,ax
		mov 	ah,0
		mov 	al,obsrow
		mov 	linestart,ax
		add 	ax,55
		mov 	lineend,ax
		mov 	linecolor,0000b
		call 	drawvertline

		mov 	linecolor,1010b
		ret
MoveObstacle ENDP
;-----------------------------------------------------------------------------
; RANDOM NUMBER GENERATOR - RESULT IN randnum
;-----------------------------------------------------------------------------
RandomNum PROC
		mov 	ah,2ch
		int 	21h
		mov 	dh,00h
		mov 	ax,dx
		mov 	dl,50
		div 	dl
		add 	ah,40

		mov 	randnum,ah

		ret
RandomNum ENDP

;*****************************************************************************
;-----------------------------------------------------------------------------
; This procedure outputs a character in AL w. color attr. in CursorX/CursorY
; starting with the screen position CursorX/CursorY 
;-----------------------------------------------------------------------------
PutChar      PROC    
         push 	di            ; save the registers
         push 	es
         push 	ax

         mov 	di, VideoSeg   ; establish the ES segment
         mov 	es, di

         xor	ax, ax         ; clear AX
         mov 	al, BYTE PTR CursorY    ; load the row number in AX
         xchg 	ah, al        ; multiply AX by 256
         shr 	ax, 1          ; AX = CursorY*128
         mov 	di, ax         ; store the result in DI
         shr 	ax, 1          ; AX = CursorY*64
         shr 	ax, 1          ; AX = CursorY*32   
         add 	di, ax         ; DI:=CursorY*(128+32)=CursorY*160
         xor 	ax, ax         ; clear AX
         mov 	al, BYTE PTR CursorX    ; load the column number in AX
         shl 	ax, 1          ; multiply the column by 2
         add 	di, ax         ; DI:=offset of the screen byte

         pop 	ax             ; restore AX
         mov 	ah, BColor
         shl 	ah, 1
         shl	ah, 1
         shl 	ah, 1
         shl 	ah, 1
         add 	ah, FColor     ; now AH contains the color attributes

         mov 	es:[di], ax    ; store char/attribute
         inc 	CursorX       

         pop 	es             ; restore the registers
         pop 	di
         ret                ; return to the calling program
PutChar ENDP               ; end of the procedure

;-----------------------------------------------------------------------------
; WRTIES A TEXT LINE POINTED BY SI ON TEH SCREEN
;-----------------------------------------------------------------------------
WriteLn PROC               ; writes a line on the screen starting with
                                ; position X/Y = CursorX/CursorY
                                ; SI points to the string 
         push 	ax
         push 	cx
         push 	si

         xor 	cx, cx
         mov 	cl, [si]       ; CL := Length(Str)
         inc 	si

	outchar:
	     mov 	al, [si]       ; AL := next character
         call 	PutChar       ; output char to the screen
         inc 	si             ; offset of the next character
         loop	outchar

	outdone:
	     pop 	si
         pop 	cx
         pop 	ax
     ret
WriteLn ENDP    
;-----------------------------------------------------------------------------
; MOUSE FUNCTIONS - InitMouse, ShowMouse, HideMouse
;-----------------------------------------------------------------------------
InitMouse  PROC
        push 	ax
        push 	si
   	    mov 	ax, 0
        int 	33h
        clc
        cmp 	ax, 0          ; AX=0 if mouse driver is not installed
        jnz 	mend
        mov 	si, offset NoMouse
   	    call 	WriteLn       ; print "mouse driver is not installed"
        mov 	si, offset AnyKey
        mov 	CursorX, 5
        mov 	CursorY, 6
        call 	WriteLn       ; print "press any key ..."
        mov 	ax, 0          ; wait for a key
        int 	16h
        stc
	mend:    pop 	si
             pop 	ax
             ret
InitMouse ENDP
	
ShowMouse    PROC
        push 	ax
        mov 	ax, 1
        int 	33h
        pop 	ax
        ret
ShowMouse    ENDP

HideMouse    PROC
        push 	ax
        mov 	ax, 2
        int 	33h
        pop 	ax
        ret
HideMouse    ENDP

;*****************************************************************************
;-----------------------------------------------------------------------------
; THE DRAWCOPTER PROCEDURE - TAKES IN THE CURRENT POSITION FROM 
;	current_copter_row and current_copter_col
;-----------------------------------------------------------------------------

DrawCopter PROC
			
		push ax
		push bx
		push cx
		push dx
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
		
		mov row, 0
		mov col, 0
		mov print_row, 0
		mov print_col, 0
		
		
		cmp turn, 0
		jne otherFile
		; Opening the file for reading - NOTE : The file must be in the appropriate folder
		mov 	al,0        
		mov 	dx,offset image_file
		mov 	ah,03dh
		int 	21h
		mov 	turn, 1
		jmp begin
		
		otherFile :
			mov 	al,0        
			mov 	dx,offset image_file_2
			mov 	ah,03dh
			int 	21h
			mov 	turn, 0
			
		; If file is not read, jump to error
		begin:
		jc 		erro
		mov 	file_handle,ax 
	
		; The read cycle - Basically, numbers are read from the file, and corresponding colors are drawn on the screen
			read:
				mov 	bx,file_handle    
				mov 	dx,offset buffer
				mov 	al,0
				mov 	cx,1
				mov 	ah,3Fh
				int 	21h
				
				cmp 	ax, 0
				je 		erro
				
				mov 	dx,buffer 
				cmp 	dx, '0'
				jle 	continue2
				
				;cmp 	dx, 'Z'
				;jg 		continue_3
				;sub 	dx, 48
				
				mov 	dh, 0      
				mov 	ax, current_copter_row
				mov 	print_row, ax
				mov 	ax, row
				add 	print_row, ax
				mov 	ax, current_copter_col
				mov 	print_col, ax
				mov 	ax, col
				add 	print_col, ax
				DrawPixel 	dx,print_row,print_col
						
			continue2 :
				mov 	dx, col
				cmp 	dx, image_width
				jne 	continue4
				inc		row
				mov 	ax, -1
				mov 	col, ax
				
			continue4 :
				inc 	col
				jmp 	read
				
		erro:	
			mov bx, file_handle
			mov ah, 3eh
			int 21h
			pop dx
			pop cx
			pop bx
			pop ax
			ret
DrawCopter ENDP

;-----------------------------------------------------------------------------
; CLEARS THE COPTER FROM THE SCREEN - TAKES CURRENT COORDS FROM GLOBAL DEF
;-----------------------------------------------------------------------------

ClearCopter PROC
		comment/*
		int i = currentrow
		int j = currentcol
		while( i <  copterwidth )
		{
			while ( j < copterheight )
			{
				clear pixel i,j
				j++
			}
			i++
			j = currentcol
		}/*
		push 	ax
		push 	bx
	
		inc 	image_width ; because the actual width is 1 + image_width
	
		mov 	row, 0
		mov 	col, 0
	
		mov 	ax, current_copter_row
		mov 	print_row, ax
	
		mov 	bx, current_copter_col
		mov 	print_col, bx
	
		outerLoop:
		
			innerLoop:
		
				DrawPixel 0000b, print_row, print_col
				inc 	col
				inc 	print_col
			
				mov 	ax, col
				cmp 	ax, image_width
				jle 	innerLoop
			
			inc 	row
			inc 	print_row
			
			mov 	col, 0
			mov 	print_col, bx
			
			mov 	ax, row
			cmp 	ax, image_height
			jle 	outerLoop
		
			
		dec 	image_width	; undoing change to image_width so that drawCopter can be called again without error
	
		mov 	row, 0
		mov 	col, 0
		
		pop 	bx
		pop 	ax
		ret
ClearCopter ENDP

;-----------------------------------------------------------------------------
; DETECTS COLLISION BETWEEN COPTER AND THE ENVIRONMENT
;-----------------------------------------------------------------------------
DetectCollision PROC
	
		push ax
		push bx
		push cx
		push dx
		
		
		;for row:
		;	for all the col from column to column+29:
		;	  check if the pixel colour at (row-1,col) == pixel colour ar (row,col)
		mov cx, current_copter_col	
		mov ax, current_copter_row
		mov dx,ax
		dec dx			;dx will now have row-1 and cx will have col
		mov si,cx
		add si,30
		loop1:
			cmp cx,si
			jge outerloop2
			;Retrieve color of the pixel at the location
			mov ah,0Dh
			int 10h			;al will now have the required pixel color
			cmp al, 1010b		
			je collided
			inc cx
			jmp loop1
		
		outerloop2:
		;for x = "column+29":
		;	for all the ro from row to row+15
		;	  check if the pixel color at ( ro ,x) == pixel color ar (ro,x+1)
		mov cx,current_copter_col
		add cx,30		;29+1 = 30
		mov dx,current_copter_row
		mov si,dx
		add si,15
		loop2:
			cmp dx,si
			jge outerloop3
			mov ah,0dh
			int 10h
			cmp al, 1010b
			je collided
			inc dx
			jmp loop2
		
		outerloop3:
		;for x = "row+14"
		;	for all the col from column to column+14:
		;	  check if the pixel colour at (x+1,col) == pixel colour ar (x,col)
		mov cx, current_copter_col	
		mov ax, current_copter_row
		mov dx,ax
		add dx,15			;dx will now have row+15 and cx will have col
		mov si,cx
		add si,30
		loop3:
			cmp cx,si
			jge done
			;Retrieve color of the pixel at the location
			mov ah,0Dh
			int 10h			;al will now have the required pixel color
			cmp al, 1010b		
			je collided
			inc cx
			jmp loop3
		
		collided: 
			mov detect_collision, 1 
        done:
        	pop dx
        	pop cx
        	pop bx
        	pop ax
			ret
DetectCollision ENDP
gameOverProc PROC
				
	movCursor 10, 14
		
	mov dx, offset gameOverMsg
	mov ah, 09
	int 21h
	
	movCursor 12, 14
	
	mov dx, offset newGameMsg
	mov ah, 09
	int 21h
	
	movCursor 14, 14
	
	mov dx, offset exitGameMsg
	mov ah, 09
	int 21h
	
	movCursor 24, 0

	RET
gameOverProc ENDP

ClearScreen PROC
		comment/*
		int i = currentrow
		int j = currentcol
		while( i <  copterwidth )
		{
			while ( j < copterheight )
			{
				clear pixel i,j
				j++
			}
			i++
			j = currentcol
		}/*
		push 	ax
		push 	bx
	
	
		mov 	row, 0
		mov 	col, 0
	
		mov 	ax, 0
		mov 	print_row, ax
	
		mov 	bx, 0
		mov 	print_col, bx
	
		outerLoop1:
		
			innerLoop1:
		
				DrawPixel 0000b, print_row, print_col
				inc 	col
				inc 	print_col
			
				mov 	ax, col
				cmp 	ax, 320	
				jle 	innerLoop1
			
			inc 	row
			inc 	print_row
			
			mov 	col, 0
			mov 	print_col, bx
			
			mov 	ax, row
			cmp 	ax, 200
			jle 	outerLoop1
		
	
		mov 	row, 0
		mov 	col, 0
		
		pop 	bx
		pop 	ax
		ret
ClearScreen ENDP
;------------------------------------------------------

;----------------------------------------------------------	
resetAll proc


	mov row, 0
	mov col, 0
	mov print_row , 100
	mov print_col , 100
	mov current_copter_row , 0  
	mov current_copter_col, 0
	mov turn ,0
	
	mov col_copter,	00h				;REUSED - Rename
	mov row_copter,	00h				;REUSED - Rename
	mov ncol,		00h
	mov nrow,		00h
	mov detect_collision, 0
	mov delay1 , 00h
	mov delay2 	, 00h
	mov delay3 	,00h
	mov delay4 	, 00h
	mov tempend ,	00h
	mov tempcol , 00h
	mov linecol ,  00h
	mov testend	,00h
	mov testrow		,	00h
	mov linecolor	,	00h
	mov obsrow	,	00h
	mov obscol	,	00h
	mov obstaclecol ,	00h
	mov linestart,	00h
	mov lineend	,	00h
	mov count1	,00h
	mov count2	,	00h
	mov count3	,	00h
	mov randnum	 , 00h

	mov obscol1		,	300
	mov obscol2		,	300
	mov obscol3	,	300
	mov obscol4		,	300
	mov obscol5	,	300
	mov rand1	,	00h
	mov rand2	,	00h
	mov rand3	,	00h
	mov rand4	,	00h
	mov rand5	,	00h
	mov obsflag	, 00h

	mov obsdelay	,141
	mov obscount1	,	00h
	mov obscount2	,  00h
	mov obscount3	,	00h
	mov obscount4	,	00h
	mov obscount5	,00h
	
	mov startcol, 30
	mov startrow	, 00h
	mov endrow		, 00h
	mov endcol		,	00H
	mov colr		, 1110b
	mov score, 0


	ret

resetAll endp

;-------------------------------------------------------------

NewGame PROC

	;call resetAll
	; disable mouse pointer
	mov ax, 2 
	int 33h
	call readcurve
	mov linecolor,1010b
	mov linecol,50
	mov linestart,30
	mov lineend,70
	
GAMELOOP:
	call drawcurve
	mov obsdelay,81
		
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
			mov testend,33
			call movecurve
			mov testrow,169
			mov testend,200
			call movecurve
		;	call moveobstacle
			cmp obsdelay,80
			jbe noobject
			mov obsdelay,00h
			call randomnum
			mov bl,randnum
			mov bh,00h
			mov ax,bx
			mov dl,2
			div dl
			mov obsflag,ah
noobject:	
			inc obsdelay
			call randobjects
			mov obsflag,00h
		;	dec obstaclecol
			
			;*******************************************
			mov ax,3
			int 33h
			cmp bx,1
			je flag1
			jmp flag2
	flag1 :	call DetectCollision;Check if the pixels around the copter are gonna collide
			cmp detect_collision, 1
		   	je dummyjmp2
			;If yes Kaboom! GAME OVER otherwise keep polling.
			mov dx,9100
			call MakeSound
			inc score
			call ClearCopter;Erase the present copter first
			mov dx,current_copter_row
			dec dx	;TODO : Adjust accordingly so that the speed does not become horrible 
			dec dx
			
			mov current_copter_row,dx
			call DrawCopter
			;call delay
			jmp skip
			
		   dummyjmp2 : jmp GameOver
		   dummyjmp1 : jmp nextframe
	flag2: cmp bx,2
		   jne flag3
		   
	pause : ;call delay
			mov ax,3
			int 33h
	looped:	cmp bx,1
			je flag1
			jmp pause
		   
	flag3: ;Check if pixels around the copter are such that collision might occur
		   ;If yes Kaboom! GAME OVER otherwise keep polling.
		   call DetectCollision
		   cmp detect_collision, 1
		   je GameOver
		   mov dx,9100
		   call MakeSound
		   inc score
		   call ClearCopter;Erase the present copter
		   mov dx, current_copter_row
		   inc dx		;Falling down : TODO - Adjust gravity accordingly.
		   inc dx
		   mov current_copter_row,dx
		   call DrawCopter
		   ;call delay
	skip:		
			
			;*******************************************
			
			;print score
			movCursor 5, 1
			
			mov dx, offset scoreMsg
			mov ah, 09
			int 21h
			
			movCursor 6, 2
			
			mov dx, 0
			mov ax, score
			mov cx, 10
			div cx
			mov cx, ax
			call printNumber
			
			cmp count2,320
			jbe	dummyjmp1
		
			mov count3,00h
			mov linecolor,0000b
			mov linecol,298
			mov linestart,31
			mov lineend,169
	nextl:
			jmp nextobstacle
	
	call DrawCopter

	JMP GAMELOOP

GameOver:	
	call gameOverProc

	ret
NewGame ENDP
;------------------------------------------------------------------------------
;	 Prints the number in decimal form on the screen
;    Requires cx to have the number to be printed
;    Requires p_x,p_y to have the coordinates where it has to be printed
;-------------------------------------------------------------------------------
printNumber proc near
        mov ax,cx
        mov cx,10
        mov bx,0
  
         
        sstack:          
            mov dx, 0
            div cx   
            add dx, '0'
            push dx
            inc bx
    
            cmp ax, 0                       
                jnz sstack
                   
        print1:
            pop dx
            mov ah,2 
            int 21h  
        
            dec bx
            cmp bx,0
                jnz print1

        ret
printNumber endp

MakeSound PROC			;Assumes dx has the note's freq.
		
		push ax
		push bx
		push cx
		
        mov     al, 182         ; Prepare the speaker for the
        out     43h, al         ; note.
        
        mov     ax, dx       	; Frequency number (in decimal)
                                ; dx will be passed as a parameter - has the ferequency of the sound.
                                
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 00000011b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 1          ; Pause for duration of note.

		pause1:
		mov     cx, 65535

		pause2:
        dec     cx
        jne     pause2
        dec     bx
        jne     pause1
        in      al, 61h         ; Turn off note (get value from
                  
                                ;  port 61h).-
        and     al, 11111100b   ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.
        pop cx
        pop bx
        pop ax
        ret
MakeSound ENDP

;*****************************************************************************
; THE GAME LOOP IS HERE
;*****************************************************************************


START:
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	call setMode
	call readcurve
	mov colorflag,1
	call drawcurve
	mov colorflag,0
	call drawa
	call draw3
	call drawc
	call drawo
	call drawp
	call drawt
	call drawe
	call drawr
	
	mov ax, 0
	int 33h
	mov ax, 1
	int 33h
	
	polla:
		mov ax, 3
		int 33h
		cmp bx, 1
		jne polla
	call ClearScreen
	loopa:
	call resetAll
	mov current_copter_row, 100
	mov current_copter_col, 70
	
	
	
	; reset mouse and get its status: 
	mov ax, 0
	int 33h

	call clearscreen
	call NewGame
		
		; display mouse cursor: 

	mov ax, 0
	int 33h 
	mov ax, 1 
	int 33h
	pollloop :
		mov ax, 3
		int 33h
		cmp bx, 1
		jne pollloop
	cmp dx, 96
	jle pollloop
	cmp dx,  104
	jge isexit
		
	jmp loopa
		
	isexit :
		cmp dx, 112
		jle pollloop
		cmp dx, 120
		jge pollloop
		
	call HideMouse	
	call clearScreen
	
	mov al,0h
	mov ah,0
	int 10h
	
	mov ax, 4c00h
	int 21h

END START


