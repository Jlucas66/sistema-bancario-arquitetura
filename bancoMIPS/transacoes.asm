# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: transacoes.asm
# Módulo de Transações do Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    msg_saque_ok: .asciiz "Saque realizado com sucesso.\n"
    msg_deposito_ok: .asciiz "Deposito realizado com sucesso.\n"
    msg_transferencia_ok: .asciiz "Transferencia concluida com sucesso.\n"
    msg_limite_ok: .asciiz "Limite alterado com sucesso.\n"

    msg_erro_saldo: .asciiz "Falha: saldo insuficiente.\n"
    msg_erro_limite: .asciiz "Falha: limite insuficiente.\n"
    msg_erro_conta: .asciiz "Falha: conta inexistente.\n"

.text
    .globl sacar
    .globl depositar
    .globl alterar_limite
    .globl transferir_debito
    .globl transferir_credito

# -------------------------------------------------------------
# sacar
# -------------------------------------------------------------
# Entrada: $a0 = número da conta (inteiro)
#          $a1 = valor a sacar (inteiro, em centavos)
# -------------------------------------------------------------
sacar:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0      # conta
    move $s1, $a1      # valor

    jal buscar_cliente_por_conta
    move $t0, $v0
    bltz $t0, erro_conta_saque

    li $t1, 80
    mul $t2, $t0, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2

    lw $t4, 72($t3)      # saldo atual
    blt $t4, $s1, erro_saldo_saque

    sub $t4, $t4, $s1
    sw $t4, 72($t3)

    li $v0, 4
    la $a0, msg_saque_ok
    syscall
    j fim_saque

erro_saldo_saque:
    li $v0, 4
    la $a0, msg_erro_saldo
    syscall
    j fim_saque

erro_conta_saque:
    li $v0, 4
    la $a0, msg_erro_conta
    syscall

fim_saque:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra


# -------------------------------------------------------------
# depositar
# -------------------------------------------------------------
# Entrada: $a0 = número da conta (inteiro)
#          $a1 = valor a depositar (inteiro, em centavos)
# -------------------------------------------------------------
depositar:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0
    move $s1, $a1

    jal buscar_cliente_por_conta
    move $t0, $v0
    bltz $t0, erro_conta_dep

    li $t1, 80
    mul $t2, $t0, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2

    lw $t4, 72($t3)
    add $t4, $t4, $s1
    sw $t4, 72($t3)

    li $v0, 4
    la $a0, msg_deposito_ok
    syscall
    j fim_dep

erro_conta_dep:
    li $v0, 4
    la $a0, msg_erro_conta
    syscall

fim_dep:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra


# -------------------------------------------------------------
# alterar_limite
# -------------------------------------------------------------
# Entrada: $a0 = número da conta (inteiro)
#          $a1 = novo limite (inteiro, em centavos)
# -------------------------------------------------------------
alterar_limite:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0
    move $s1, $a1

    jal buscar_cliente_por_conta
    move $t0, $v0
    bltz $t0, erro_limite_conta

    li $t1, 80
    mul $t2, $t0, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2

    sw $s1, 76($t3)

    li $v0, 4
    la $a0, msg_limite_ok
    syscall
    j fim_alt_lim

erro_limite_conta:
    li $v0, 4
    la $a0, msg_erro_conta
    syscall

fim_alt_lim:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra


# -------------------------------------------------------------
# transferir_debito
# -------------------------------------------------------------
# Entrada: $a0 = conta_destino, $a1 = conta_origem, $a2 = valor (centavos)
# -------------------------------------------------------------
transferir_debito:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    move $s0, $a0    # destino
    move $s1, $a1    # origem
    move $s2, $a2    # valor

    # Busca origem
    move $a0, $s1
    jal buscar_cliente_por_conta
    move $s3, $v0
    bltz $s3, erro_transferencia_cliente

    li $t1, 80
    mul $t2, $s3, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2
    lw $t4, 72($t3)
    blt $t4, $s2, erro_transferencia_saldo
    sub $t4, $t4, $s2
    sw $t4, 72($t3)

    # Busca destino
    move $a0, $s0
    jal buscar_cliente_por_conta
    move $s3, $v0
    bltz $s3, erro_transferencia_cliente

    li $t1, 80
    mul $t2, $s3, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2
    lw $t4, 72($t3)
    add $t4, $t4, $s2
    sw $t4, 72($t3)

    li $v0, 4
    la $a0, msg_transferencia_ok
    syscall
    j fim_transf

erro_transferencia_cliente:
    li $v0, 4
    la $a0, msg_erro_conta
    syscall
    j fim_transf

erro_transferencia_saldo:
    li $v0, 4
    la $a0, msg_erro_saldo
    syscall

fim_transf:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra


# -------------------------------------------------------------
# transferir_credito
# -------------------------------------------------------------
# Entrada: $a0 = conta_destino, $a1 = conta_origem, $a2 = valor (centavos)
# -------------------------------------------------------------
transferir_credito:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    move $a0, $s1
    jal buscar_cliente_por_conta
    move $s3, $v0
    bltz $s3, erro_transf_credito_cliente

    li $t1, 80
    mul $t2, $s3, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2
    lw $t4, 76($t3)
    blt $t4, $s2, erro_transf_limite
    sub $t4, $t4, $s2
    sw $t4, 76($t3)

    move $a0, $s0
    jal buscar_cliente_por_conta
    move $s3, $v0
    bltz $s3, erro_transf_credito_cliente

    li $t1, 80
    mul $t2, $s3, $t1
    la $t3, clientes_array
    add $t3, $t3, $t2
    lw $t4, 72($t3)
    add $t4, $t4, $s2
    sw $t4, 72($t3)

    li $v0, 4
    la $a0, msg_transferencia_ok
    syscall
    j fim_transf_credito

erro_transf_credito_cliente:
    li $v0, 4
    la $a0, msg_erro_conta
    syscall
    j fim_transf_credito

erro_transf_limite:
    li $v0, 4
    la $a0, msg_erro_limite
    syscall

fim_transf_credito:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# =============================================
# Fim do arquivo transacoes.asm
# =============================================
