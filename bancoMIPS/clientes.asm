# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: clientes.asm
# Gerenciamento de Clientes do Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    # ---------------- ESTRUTURA DE CLIENTE ----------------
    # Cada cliente ocupa 80 bytes:
    # 0–11   : CPF (string)
    # 12–18  : Conta (string)
    # 20–51  : Nome (string)
    # 52–55  : Saldo (int centavos)
    # 56–59  : Limite crédito
    # 60–63  : Dívida cartão
    # 64–79  : reservado

.text
    .globl cadastrar_cliente
    .globl buscar_cliente_por_cpf
    .globl buscar_cliente_por_conta
    .globl gerar_digito_verificador

# -------------------------------------------------------------
# cadastrar_cliente
# -------------------------------------------------------------
# Entrada:
#   $a0 = endereço CPF
#   $a1 = endereço CONTA (6 dígitos)
#   $a2 = endereço NOME
# -------------------------------------------------------------
cadastrar_cliente:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    # Verifica se limite de clientes foi atingido
    la $t0, num_clientes
    lw $t1, 0($t0)
    la $t2, MAX_CLIENTES
    lw $t3, 0($t2)
    bge $t1, $t3, erro_limite_clientes

    # Verifica se CPF já existe
    move $a3, $a0
    jal buscar_cliente_por_cpf
    bnez $v0, erro_cpf_existente

    # Verifica se conta já existe
    move $a3, $a1
    jal buscar_cliente_por_conta
    bnez $v0, erro_conta_existente

    # Calcula endereço base do cliente novo
    la $t4, clientes_array
    lw $t1, num_clientes
    li $t5, 80
    mul $t6, $t1, $t5
    add $t4, $t4, $t6

    # --- Salva CPF ---
    move $t7, $a0
    move $a0, $t4
    move $a1, $t7
    jal copiar_string

    # --- Salva Conta ---
    addi $t4, $t4, 12
    move $t7, $a1
    move $a0, $t4
    move $a1, $t7
    jal copiar_string

    # --- Gera DV ---
    move $a0, $t7
    jal gerar_digito_verificador
    move $t8, $v0        # dígito verificador

    # --- Salva Nome ---
    addi $t4, $t4, 8
    move $a0, $t4
    move $a1, $a2
    jal copiar_string

    # --- Inicializa valores ---
    addi $t4, $t4, 32
    sw $zero, 0($t4)        # saldo = 0
    la $t9, LIMITE_CREDITO_PADRAO
    lw $t9, 0($t9)
    sw $t9, 4($t4)          # limite padrão
    sw $zero, 8($t4)        # dívida = 0

    # Incrementa contador de clientes
    la $t0, num_clientes
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)

    # Mensagem sucesso
    li $v0, 4
    la $a0, msg_cliente_cadastrado
    syscall

    j fim_cadastro

erro_limite_clientes:
    li $v0, 4
    la $a0, msg_erro_limite_clientes
    syscall
    j fim_cadastro

erro_cpf_existente:
    li $v0, 4
    la $a0, msg_cpf_existente
    syscall
    j fim_cadastro

erro_conta_existente:
    li $v0, 4
    la $a0, msg_conta_em_uso
    syscall
    j fim_cadastro

fim_cadastro:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# -------------------------------------------------------------
# buscar_cliente_por_cpf
# -------------------------------------------------------------
buscar_cliente_por_cpf:
    la $t0, clientes_array
    lw $t1, num_clientes
    li $t2, 0
    li $t3, 80
loop_busca_cpf:
    bge $t2, $t1, nao_encontrado
    mul $t4, $t2, $t3
    add $t5, $t0, $t4
    move $a0, $a3
    move $a1, $t5
    jal comparar_strings
    beq $v0, 1, encontrado_cpf
    addi $t2, $t2, 1
    j loop_busca_cpf
encontrado_cpf:
    move $v0, $t5
    jr $ra
nao_encontrado:
    move $v0, $zero
    jr $ra

# -------------------------------------------------------------
# buscar_cliente_por_conta
# -------------------------------------------------------------
buscar_cliente_por_conta:
    la $t0, clientes_array
    lw $t1, num_clientes
    li $t2, 0
    li $t3, 80
loop_busca_conta:
    bge $t2, $t1, nao_encontrado_conta
    mul $t4, $t2, $t3
    add $t5, $t0, $t4
    addi $t5, $t5, 12
    move $a0, $a3
    move $a1, $t5
    jal comparar_strings
    beq $v0, 1, encontrado_conta
    addi $t2, $t2, 1
    j loop_busca_conta
encontrado_conta:
    move $v0, $t5
    jr $ra
nao_encontrado_conta:
    move $v0, $zero
    jr $ra

# -------------------------------------------------------------
# gerar_digito_verificador
# -------------------------------------------------------------
gerar_digito_verificador:
    li $t0, 0
    li $t2, 2
    addi $sp, $sp, -8
    sw $ra, 0($sp)

    jal comprimento_string
    move $t3, $v0
    addi $t3, $t3, -1

loop_dv:
    bltz $t3, fim_dv
    add $t4, $a0, $t3
    lb $t5, 0($t4)
    addi $t5, $t5, -48
    mul $t6, $t5, $t2
    add $t0, $t0, $t6
    addi $t2, $t2, 1
    addi $t3, $t3, -1
    j loop_dv

fim_dv:
    li $t7, 11
    div $t0, $t7
    mfhi $t8
    move $v0, $t8
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# =============================================
# Fim do arquivo clientes.asm
# =============================================
