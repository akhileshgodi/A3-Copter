.model small
.stack 100h
.data
count db 0
linestart dw 0
lineend dw 0
linecol	dw 0
linecolr dw 0
firstcol db 0
nextcol  db 0
col dw 0
ncol dw 0
row dw 0
obsrow dw 0
count1 dw 0
linecol2 dw 0
linecol3 dw 0
delay1 dw 00h
delay2 dw 00h
delay3 dw 00h
delay4 dw 00h
topcurve1 db 	30,30,30,30,30,30,30,30,30,30
topcurve2 db 	30,30,30,30,30,30,30,30,30,30
topcurve3 db 	28,28,28,28,28,28,28,28,28,28
topcurve4 db 	28,28,28,28,28,28,28,28,28,28
topcurve5 db  	26,26,26,26,26,26,26,26,26,26
topcurve6 db 	26,26,26,26,26,26,26,26,26,26
topcurve7 db 	24,24,24,24,24,24,24,24,24,24
topcurve8 db 	24,24,24,24,24,24,24,24,24,24
topcurve9 db	22,22,22,22,22,22,22,22,22,22
topcurve10 db	22,22,22,22,22,22,22,22,22,22
topcurve11 db	20,20,20,20,20,20,20,20,20,20
topcurve12 db	20,20,20,20,20,20,20,20,20,20
topcurve13 db	18,18,18,18,18,18,18,18,18,18
topcurve14 db	18,18,18,18,18,18,18,18,18,18
topcurve15 db	16,16,16,16,16,16,16,16,16,16
topcurve16 db	16,16,16,16,16,16,16,16,16,16
topcurve17 db   16,16,16,16,16,16,16,16,16,16
topcurve18 db   16,16,16,16,16,16,16,16,16,16
topcurve19 db	18,18,18,18,18,18,18,18,18,18
topcurve20 db	18,18,18,18,18,18,18,18,18,18
topcurve21 db	20,20,20,20,20,20,20,20,20,20
topcurve22 db	20,20,20,20,20,20,20,20,20,20
topcurve23 db	22,22,22,22,22,22,22,22,22,22
topcurve24 db	22,22,22,22,22,22,22,22,22,22
topcurve25 db 	24,24,24,24,24,24,24,24,24,24
topcurve26 db 	24,24,24,24,24,24,24,24,24,24
topcurve27 db  	26,26,26,26,26,26,26,26,26,26
topcurve28 db 	26,26,26,26,26,26,26,26,26,26
topcurve29 db 	28,28,28,28,28,28,28,28,28,28
topcurve30 db 	28,28,28,28,28,28,28,28,28,28
topcurve31 db 	30,30,30,30,30,30,30,30,30,30
topcurve32 db 	30,30,30,30,30,30,30,30,30,30
.code
start:
		mov ax,@data
		mov ds,ax
		call setmode
		call movecurve
		mov ax,4c00h
		int 21h



setmode proc
	mov al,13h
	mov ah,0
	int 10h
	ret
setmode endp

drawvertline proc
	mov al,linecolr
	mov cx,linecol
	mov dx,linestart
	mov ah,0ch
vnext:
	int 10h
	inc dx
	cmp dx,lineend
	jbe vnext
	ret
drawvertline endp

drawcurve proc
	lea si,topcurve1
	mov linecol,0
nextline:
	mov linestart,0
	mov lineend,200
	mov linecolr,0000b
	call drawvertline
	mov bl,[si]
	mov bh,0
	mov lineend,bx
	inc si
	
	mov linecolr,0011b
	call drawvertline
	
	mov lineend,200
	mov linestart,170
	mov linecolr,0000b
	call drawvertline

	mov linecolr,0011b
	mov linestart,bx
	add linestart,154

	call drawvertline

	inc linecol
	cmp linecol,320
	jb nextline

	ret
drawcurve endp

shiftarray proc
	lea si,topcurve1
	mov bl,[si]
	mov firstcol,bl
	mov cx,1
	mov ax,01h
shiftnext:
	inc cx
	mov bl,[si+1]
	mov [si],bl
	inc si

	cmp cx,320
	jb shiftnext

	mov bl,firstcol
	mov [si],bl
	ret
shiftarray endp

delay	proc
	mov delay1,00h

waitloop1:
	inc delay1
	
	mov delay2,0
waitloop2:
	inc delay2
	
	mov delay3,00h
waitloop3:
	inc delay3
	mov delay4,00h
waitloop4:
	inc delay4
	cmp delay4,65000
;	jbe waitloop4

	cmp delay3,65000
;	jbe waitloop3

	cmp delay2,65000
	jbe waitloop2

	cmp delay1,65000
	jbe waitloop1

	ret
delay endp

;movecurve proc
;	mov linecolr,0011b
;nextscreen:
;	call drawcurve
;	call shiftarray
;	call delay
;	mov linecolr,1100b
;	jmp nextscreen

;	ret
;movecurve endp
movecurve proc
	call drawcurve
	mov linecol3,299
nextframe:
	call movecurve1
	
	call moveobstacle
	dec linecol3
;	call delay
	jmp nextframe
	ret
movecurve endp
movecurve1 proc
	mov col,00h
nextcol1:
	
	mov row,00h
	cmp col,319
	je lastcol
	mov bx,col
	inc bx
	mov ncol,bx
	jmp nextrow1
lastcol:
	mov ncol,00h
nextrow1:
	mov ah,0dh
	mov cx,col
	mov dx,row
	int 10h
	cmp al,0000b
	je continue1
	cmp al,0011b
	jne goout
continue1:
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
	cmp row,30
	jbe nextrow1
	
	inc col 
	cmp col,319
	jbe nextcol1

goout:
	ret	
movecurve1 endp
drawobstacle proc
	mov bx,obsrow
	mov count1,0
	mov linestart,bx
	add bx,70
	mov lineend,bx
	mov bx,linecol2
	mov linecol,bx
nextline2:
	call drawvertline
	inc linecol
	inc count
	cmp count,20
	jbe nextline2
ret
drawobstacle endp

moveobstacle proc
	mov obsrow,50
	mov bx,linecol3
	mov linecol2,bx
	call drawobstacle

nextpos:
	mov linecolr,0000b
	call drawobstacle

	dec linecol2
	mov linecolr,0011b
	call drawobstacle

;	cmp linecol2,0
;	jne nextpos
	ret
moveobstacle endp
end start
