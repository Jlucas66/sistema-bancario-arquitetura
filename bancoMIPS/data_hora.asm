# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: data_hora.asm
# Módulo de Data e Hora do Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    .globl data_atual, hora_atual, segundos_decorridos
    data_atual: .space 16       # Exemplo: "09/11/2025"
    hora_atual: .space 16       # Exemplo: "20:45:12"
    segundos_decorridos: .word 0  # Contador de segundos (para juros e controle)

    msg_data_ok: .asciiz "Data e hora configuradas com sucesso.\n"
    msg_data_invalida: .asciiz "Erro: data ou hora invalida.\n"

.text
    .globl configurar_data_hora
    .globl atualizar_relogio
    .globl mostrar_data_hora

# -------------------------------------------------------------
# configurar_data_hora
# -------------------------------------------------------------
# Entrada: $a0 = string data (DDMMAAAA)
#          $a1 = string hora (HHMMSS)
# -------------------------------------------------------------
configurar_data_hora:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0  # data
    move $s1, $a1  # hora

    # Copia as strings para as variáveis globais
    la $a0, data_atual
    move $a1, $s0
    jal strcpy

    la $a0, hora_atual
    move $a1, $s1
    jal strcpy

    # Reinicia o contador de segundos
    sw $zero, segundos_decorridos

    li $v0, 4
    la $a0, msg_data_ok
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# -------------------------------------------------------------
# atualizar_relogio
# -------------------------------------------------------------
# Incrementa os segundos automaticamente.
# Deve ser chamado periodicamente no loop principal.
# -------------------------------------------------------------
atualizar_relogio:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    # Usa syscall 30 (time)
    li $v0, 30
    syscall
    move $s0, $a0   # $a0 contém o tempo atual em milissegundos

    # Converte milissegundos para segundos
    li $t0, 1000
    div $s0, $t0
    mflo $t1          # t1 = segundos

    # Incrementa contador se passou 1 segundo
    lw $t2, segundos_decorridos
    blt $t1, $t2, fim_atualizar
    beq $t1, $t2, fim_atualizar
    sw $t1, segundos_decorridos

    # TODO: incrementar string hora_atual (não implementado totalmente)
    # Para simplificação: apenas reconhece passagem de segundos

fim_atualizar:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


# -------------------------------------------------------------
# mostrar_data_hora
# -------------------------------------------------------------
# Exibe a data e hora atuais configuradas no sistema.
# -------------------------------------------------------------
mostrar_data_hora:
    li $v0, 4
    la $a0, data_atual
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, hora_atual
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    jr $ra

# =============================================
# Fim do arquivo data_hora.asm
# =============================================
