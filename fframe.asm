.model small
.stack 100h
.data
col		dw	00h
row		dw	00h
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
obsrow		dw	00h
obscol		dw	00h
obstaclecol dw	00h
linestart	dw	00h
lineend		dw	00h
count1		dw	00h
count2		dw	00h
topcurve db 320 dup(0)
filename db "curve1.txt"

.code

start:
		mov ax,@data
		mov ds,ax
				
		call setmode
		call readcurve
		mov linecolor,0011b
		mov linecol,50
		mov linestart,30
		mov lineend,70
		call moveframe

		mov ax,4c00h
		int 21h

setmode	proc
				
		mov al,13h
		mov ah,00h
		int 10h
		ret

setmode	endp

drawvertline proc
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
drawvertline endp

drawcurve proc
				
		lea si,topcurve
		mov linecol,00h
		mov lineend,00h
		mov linecolor,0011b
nextline:
		mov linestart,0
		mov bl,[si]
		mov bh,00h
		mov lineend,bx
		inc si
				
		call drawvertline

		mov linestart,bx
		add linestart,154
		mov lineend,200
		call drawvertline 

		inc linecol
		cmp linecol,320
		jb nextline

		ret
drawcurve endp

delay	proc
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
delay	endp

moveframe 	proc
		call drawcurve
		
nextobstacle:
		mov count2,00h
		mov obstaclecol,299
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

		jmp nextobstacle
		ret
moveframe	endp

movecurve	proc	
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
movecurve	endp	

drawobstacle proc
		mov bx,obsrow
		mov count1,00h
		mov linestart,bx
		add bx,70
		mov lineend,bx
		mov bx,obscol
		mov linecol,bx
nextline1:
		call drawvertline
		inc linecol
		inc count1
		cmp count1,20
		jbe nextline1

		ret
drawobstacle endp

moveobstacle proc
		mov obsrow,50
		mov bx,obstaclecol
		mov obscol,bx
		call drawobstacle

nextpos:
		mov linecolor,0000b
		call drawobstacle
		dec obscol
		mov linecolor,0011b
		call drawobstacle
		
		ret
moveobstacle endp
readcurve	proc
		mov al, 2
		mov dx, offset filename
		mov ah, 3dh
		int 21h

		mov bx, ax
		mov cx, 320
		mov dx, offset topcurve
		mov ah, 3fh
		int 21h

		mov ah, 3eh
		int 21h
		ret
readcurve	endp

end start		
