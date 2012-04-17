.model small
.stack 100h
.data
filename1 db "curve.txt"
handle dw ?
data_size dw 10
topcurve1 db 	18,18,18,17,17,17,17,17,16,16
topcurve2 db 	15,15,15,16,16,16,17,17,17,18
topcurve3 db 	18,19,19,19,19,20,20,20,20,20
topcurve4 db 	21,21,21,21,22,22,22,23,23,23
topcurve5 db  	24,24,25,25,25,25,25,26,26,27
topcurve6 db 	27,27,27,27,27,27,28,28,28,29
topcurve7 db 	29,29,29,29,30,30,30,30,30,30
topcurve8 db 	29,29,29,29,29,29,29,29,28,28
topcurve9 db	27,27,27,26,26,26,25,25,24,24
topcurve10 db	24,24,24,24,24,24,24,23,23,23
topcurve11 db	23,22,22,22,22,22,21,21,21,20
topcurve12 db	19,19,19,19,18,18,18,17,17,17
topcurve13 db	16,16,16,16,16,16,16,15,15,15
topcurve14 db	15,15,15,15,16,16,16,17,17,17
topcurve15 db	17,17,17,17,18,18,18,18,18,18
topcurve16 db	19,19,20,20,20,20,20,20,21,21
topcurve17 db   22,22,22,22,22,23,23,23,23,23
topcurve18 db   24,24,24,24,24,25,25,26,26,27
topcurve19 db	28,28,28,28,28,28,28,29,29,29
topcurve20 db	30,30,30,30,29,29,29,29,29,29
topcurve21 db	28,28,27,27,28,28,28,29,29,29
topcurve22 db	27,26,25,25,25,25,24,24,24,24
topcurve23 db	25,25,26,26,26,26,27,27,28,28
topcurve24 db	27,27,26,26,26,25,25,25,24,24
topcurve25 db 	23,23,23,23,23,23,22,22,22,22
topcurve26 db 	21,21,21,21,21,21,20,20,20,20
topcurve27 db  	19,19,19,18,18,17,17,17,17,17
topcurve28 db 	16,16,16,16,16,16,15,15,15,15
topcurve29 db 	16,16,16,17,17,17,18,18,18,19
topcurve30 db 	19,19,19,19,20,20,20,20,21,21
topcurve31 db 	21,21,21,22,22,21,21,21,20,20
topcurve32 db 	19,19,19,19,19,19,19,18,18,18


data1 db "blah blah"
.code
start:
	mov ax,@data
	mov ds,ax

	mov ah,3dh
	mov al,2
	;mov cx,0
	mov dx,offset filename1
	mov ah,3dh
	int 21h

	mov handle,ax
	mov bx,ax
	mov dx,offset topcurve1
	mov cx,320
	mov ah,40h
	int 21h
	
	mov bx,handle
	mov ah,3eh
	int 21h

	mov ax,4c00h
	int 21h
end start
