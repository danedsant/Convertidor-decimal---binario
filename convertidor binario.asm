; Convertidor  Binario y Decimal
; Daniel Villalba v-27.506.542


.model small
.stack 100h
.data

    ; Mensajes del menu
    menuPrincipal      db 10, 13, '-------------------', 10, 13
                       db 'Convertidor', 10, 13
                       db '1-Binario a Decimal', 10, 13
                       db '2-Decimal a Binario', 10, 13
                       db '3-Cerrar', 10, 13
                       db 'Ingresa una opcion: $'
                                              
    opcionInvalida     db 10, 13, 'Ingresa una opcion valida.$'

    ;Mensajes para Binario a Decimal 
    
    mensajeSolicitud   db 10, 13, 'Ingresa un numero binario de 4 o 8 bits: $'
    mensajeError       db 10, 13, 'Error: el numero tiene que ser de 4 u 8 bits y contener solo 0 y 1$'
    mensajeResultado   db 10, 13, 'El numero decimal es: $' 
    
    ;buffer para la entrada de datos
    buffer             db 9, ?, 9 DUP(?)   ;buffer binario             
    potencias          dw 128, 64, 32, 16, 8, 4, 2, 1  
                                           
                                           
    ;Mensajes para Decimal a Binario 
    
    mensajeDecimal     db 10, 13, 'Ingresa un numero decimal (entre 0 y 255) : $'
    mensajeResultadoB  db 10, 13, 'El numero binario es: $'
    bufferDecimal      db 5, ?, 5 DUP(?) ; Buffer para entrada decimal

.code
main proc
    mov ax, @data
    mov ds, ax

inicio_menu:


    ;Mostrar el menú principal
    mov ah, 9
    lea dx, menuPrincipal
    int 21h

    ;Leer la opción
    mov ah, 1
    int 21h

    ;Comparar la opción
    cmp al, '1'
    je ConvertirBinarioEnDecimal
    
    cmp al, '2'
    je ConvertirDecimalEnBinario

    cmp al, '3'
    je finalizar

    ;volver al menu si no es valida la opcion
    mov ah, 9
    lea dx, opcionInvalida
    int 21h
    jmp inicio_menu


ConvertirBinarioEnDecimal:
    
    ;muestra mensaje para ingresar numero
    mov ah, 9
    lea dx, mensajeSolicitud
    int 21h
     
    ;lee el numero 
    mov ah, 0Ah
    lea dx, buffer
    int 21h
    
    ;asigna la cantidad de numeros a convertir (8 o 4)
    mov cl, [buffer + 1]
    xor ch, ch
    
    ;verifica si es 8 o 4 
    cmp cx, 4
    je preparar_conversion
    cmp cx, 8
    je preparar_conversion
    jmp error_entrada 
    
    

preparar_conversion:

    lea si, buffer + 2 ;apunta al primer numero ingresado
    lea di, potencias  ;apunta al arreglo de potencia
    mov bx, 0
    cmp cx, 4
    jne bucleConversion
    add di, 8

bucleConversion:

;valida que el caracter sea 0 o 1
    mov al, [si]
    cmp al, '0'
    jb error_entrada
    cmp al, '1'
    ja error_entrada
    
;suma la potencia correspondiente si es 1
    cmp al, '1'
    jne saltar_suma
    mov ax, [di]
    add bx, ax  
    

saltar_suma: ;omite la suma de la potencia si hay 0
    inc si
    add di, 2
    loop bucleConversion
    jmp mostrar_resultado  
    

error_entrada: ; muestra mensaje de error y regresa al menu
    mov ah, 9
    lea dx, mensajeError
    int 21h
    jmp inicio_menu
                   
                   
mostrar_resultado:
    mov ah, 9
    lea dx, mensajeResultado
    int 21h
    mov ax, bx
    call imprimir_decimal ; Llamada a un procedimiento para imprimir
    jmp inicio_menu

ConvertirDecimalEnBinario:

    ; Solicitar número decimal
    mov ah, 9
    lea dx, mensajeDecimal
    int 21h

    ; Leer entrada decimal
    mov ah, 0Ah
    lea dx, bufferDecimal
    int 21h

    ;Prepara para converir a numero
    lea si, bufferDecimal + 2
    mov cl, [bufferDecimal + 1]
    xor ch, ch
    xor bx, bx 
    
    convertir_a_numero:   ;Convierte el texto a numero
        mov ax, bx       
        mov bl, 10       
        mul bl           
        mov bx, ax       

        mov al, [si]     
        sub al, '0'      
        xor ah, ah       
        add bx, ax       
        inc si
    loop convertir_a_numero
                            
                            
    ;muestra mensaje para el resultado.
    mov ah, 9
    lea dx, mensajeResultadoB
    int 21h
      
    ;prepara para convertir  
    mov ax, bx      
    mov cx, 0       
    mov bx, 2       
                  
                  
    bucle_dividir:   ;divide los numeros y los guarda en la pila
        xor dx, dx      
        div bx          
        push dx         
        inc cx          
        cmp ax, 0       
        jne bucle_dividir

    imprimir_binario: ; imprime el numero binario en la pantalla
        pop dx          
        add dl, '0'     
        mov ah, 2       
        int 21h    
    loop imprimir_binario

    jmp inicio_menu


imprimir_decimal proc
    xor cx, cx
    mov bx, 10

convertir_en_cadena: ; convierte el numero en texto para mostrarlo en pantalla
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne convertir_en_cadena

imprimir_digitos: ; imprime en pantalla el numero en decimal
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop imprimir_digitos
    ret
imprimir_decimal endp


finalizar:    ;termina el programa

    mov ah, 4Ch
    int 21h 
    
end main