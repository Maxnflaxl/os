org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A
%define BUFFER_SIZE 128   ; Max input characters

start:
    jmp main

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in AL
    or al, al           ; check for null terminator
    jz .done

    mov ah, 0x0E        ; BIOS interrupt to print character
    mov bh, 0           ; Set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret


;
; Echo function - Reads input, echoes it, and prints full line after Enter
;
echo:
    mov di, 0             ; DI is our buffer index

.echo_loop:
    mov ah, 0x00          ; BIOS keyboard interrupt - wait for keypress
    int 0x16              ; AL = key pressed

    cmp al, 0x08          ; Check if Backspace (0x08)
    je .handle_backspace  

    cmp al, 0x0D          ; Check if Enter (0x0D)
    je .print_buffer      

    cmp di, BUFFER_SIZE   ; Check if buffer is full
    jae .echo_loop        ; Ignore extra input if full

    ; Store character in buffer
    mov [input_buffer + di], al
    inc di                ; Move to next position in buffer

    ; Print character immediately
    mov ah, 0x0E
    int 0x10

    jmp .echo_loop        ; Keep reading characters

.handle_backspace:
    cmp di, 0             ; If at start, ignore
    je .echo_loop

    dec di                ; Move buffer index back

    ; Print backspace (erase last char on screen)
    mov al, 0x08          ; Backspace
    mov ah, 0x0E
    int 0x10
    mov al, ' '           ; Erase character visually
    int 0x10
    mov al, 0x08          ; Move cursor back again
    int 0x10

    jmp .echo_loop

.print_buffer:
    ; Print newline first
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    int 0x10

    ; Null-terminate the buffer
    mov byte [input_buffer + di], 0

    ; Print stored input
    mov si, input_buffer
    call puts

    ret

; Function to print a newline (carriage return + line feed)
print_newline:
    mov al, 0x0D          ; Carriage return
    mov ah, 0x0E
    int 0x10

    mov al, 0x0A          ; Line feed
    int 0x10
    ret

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    
    ; Setup stack
    mov ss, ax
    mov sp, 0x7C00  

    ; Print "Welcome to mxOS" message
    mov si, msg_welcome
    call puts
    call print_newline

    ; Print "Type something: "
    mov si, msg_echo
    call puts

    ; Call echo function
    call echo

    hlt

.halt:
    jmp .halt

msg_welcome: db '--- Welcome to mxOS ---', 0
msg_echo: db 'Type something: ', 0
input_buffer: times BUFFER_SIZE db 0  ; Reserve space for user input

times 510-($-$$) db 0
dw 0AA55h