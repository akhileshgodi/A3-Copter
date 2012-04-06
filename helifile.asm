;----------------------------------------------------------
;	This file contains two macros :
;		DrawPixel( row, col ) and DrawCopter(row, col)
;	The global definitions made are important for the
;	functioning of DrawCopter
;-----------------------------------------------------------

.model small

.stack 100h

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
			jle continue_2
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
			continue_2 :
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
	
endm

start:
	mov ax, @data
	mov ds, ax
	mov al, 13h
	mov ah, 0
	int 10h
	
	mov current_copter_row, 100
	mov current_copter_col, 70
	
	DrawCopter current_copter_row, current_copter_col


	mov cx, 4c00h
	int 21h

end start
