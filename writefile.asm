.model small
.stack 100h
.data
filename1 db "curve1.txt",0
handle dw 00h
data_size dw 320
topcurve1 db 	30,30,30,30,30,30,30,30,30,30
topcurve2 db 	29,29,29,29,29,29,29,29,29,29
topcurve3 db 	28,28,28,28,28,28,28,28,28,28
topcurve4 db 	27,27,27,27,27,27,27,27,27,27
topcurve5 db  	26,26,26,26,26,26,26,26,26,26
topcurve6 db 	25,25,25,25,25,25,25,25,25,25
topcurve7 db 	24,24,24,24,24,24,24,24,24,24
topcurve8 db 	23,23,23,23,23,23,23,23,23,23
topcurve9 db	22,22,22,22,22,22,22,22,22,22
topcurve10 db	21,21,21,21,21,21,21,21,21,21
topcurve11 db	20,20,20,20,20,20,20,20,20,20
topcurve12 db	19,19,19,19,19,19,19,19,19,19
topcurve13 db	18,18,18,18,18,18,18,18,18,18
topcurve14 db	17,17,17,17,17,17,17,17,17,17
topcurve15 db	16,16,16,16,16,16,16,16,16,16
topcurve16 db	15,15,15,15,15,15,15,15,15,15
topcurve17 db   15,15,15,15,15,15,15,15,15,15
topcurve18 db   16,16,16,16,16,16,16,16,16,16
topcurve19 db	17,17,17,17,17,17,17,17,17,17
topcurve20 db	18,18,18,18,18,18,18,18,18,18
topcurve21 db	19,19,19,19,19,19,19,19,19,19
topcurve22 db	20,20,20,20,20,20,20,20,20,20
topcurve23 db	21,21,21,21,21,21,21,21,21,21
topcurve24 db	22,22,22,22,22,22,22,22,22,22
topcurve25 db 	23,23,23,23,23,23,23,23,23,23
topcurve26 db 	24,24,24,24,24,24,24,24,24,24
topcurve27 db  	25,25,25,25,25,25,25,25,25,25
topcurve28 db 	26,26,26,26,26,26,26,26,26,26
topcurve29 db 	27,27,27,27,27,27,27,27,27,27
topcurve30 db 	28,28,28,28,28,28,28,28,28,28
topcurve31 db 	29,29,29,29,29,29,29,29,29,29
topcurve32 db 	30,30,30,30,30,30,30,30,30,30


.code
start:
	mov ax,@data
	mov ds,ax

	mov ah,3ch
	mov cx,0
	mov dx,offset filename1
	mov ah,3ch
	int 21h

	mov handle,ax
	mov dx,offset topcurve1
	mov cx,data_size
	mov ah,40h
	int 21h
	
	mov ax,4c00h
	int 21h
end start
