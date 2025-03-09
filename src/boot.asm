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
    lodsb               ; Load next character into AL
    or al, al           ; Check for null terminator
    jz .done
    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0           ; Page 0
    int 0x10            ; Print character
    jmp .loop
.done:
    pop bx
    pop ax
    pop si
    ret

main:
    ; Set up segment registers
    mov ax, 0
    mov ds, ax          ; Data segment
    mov es, ax          ; Extra segment
    
    ; Set up stack (initially below 0x7C00)
    mov ss, ax
    mov sp, 0x7C00  

    ; Print welcome message
    mov si, msg_welcome
    call puts

    ; Load kernel from floppy (sector 2)
    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; Read 1 sector (adjust if kernel > 512 bytes)
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2 (1-based, after bootloader)
    mov dh, 0           ; Head 0
    mov dl, 0           ; Drive 0 (floppy)
    mov bx, 0x1000      ; Destination (ES:BX = 0x1000)
    int 0x13            ; BIOS disk interrupt
    jc .disk_error      ; Jump if error

    ; Set up stack for kernel at 0x100:0xFFFE
    cli                 ; Disable interrupts
    mov ax, 0x100       ; Segment 0x100 (0x1000 base)
    mov ss, ax          ; Stack segment
    mov sp, 0xFFFE      ; Stack pointer at top of segment
    sti                 ; Re-enable interrupts

    ; Jump to kernel
    jmp 0x100:0x0000    ; Physical address 0x1000

.disk_error:
    mov si, msg_error
    call puts
    jmp .halt

.halt:
    jmp .halt

msg_welcome: db '--- Welcome to mxOS ---', ENDL, 0
msg_error: db 'Disk read error!', ENDL, 0

times 510-($-$$) db 0
dw 0xAA55