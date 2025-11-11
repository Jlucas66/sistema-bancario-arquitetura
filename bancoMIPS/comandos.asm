# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: comandos.asm
# Interpretador de Comandos do Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    # ==================== BUFFERS PARA PARSING DE COMANDOS ====================
    .globl op1_buffer, op2_buffer, op3_buffer
    op1_buffer: .space 64       # Buffer para opção 1 (CPF, conta ou valor)
    op2_buffer: .space 64       # Buffer para opção 2 (conta, valor ou tipo)
    op3_buffer: .space 64       # Buffer para opção 3 (nome ou complemento)
    msg_confirmar_format: .asciiz "Tem certeza que deseja formatar os dados? (S/N)\n"

.text
    # ==================== FUNÇÕES GLOBAIS ====================
    .globl processar_comando
    .globl extrair_parametros_cadastro

# -------------------------------------------------------------
# processar_comando
# -------------------------------------------------------------
# Interpreta e executa comandos digitados no terminal
# -------------------------------------------------------------
processar_comando:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $a0, input_buffer
    jal remover_newline

    la $t0, input_buffer
    lb $t1, 0($t0)
    beqz $t1, fim_processar

    # ========== COMANDO CONTA_CADASTRAR ==========
    la $a0, input_buffer
    la $a1, cmd_cadastrar
    jal comparar_strings
    beq $v0, 1, executar_cadastrar

    # ========== COMANDO SALVAR ==========
    la $a0, input_buffer
    la $a1, cmd_salvar
    jal comparar_strings
    beq $v0, 1, executar_salvar

    # ========== COMANDO FORMATAR ==========
    la $a0, input_buffer
    la $a1, cmd_formatar
    jal comparar_strings
    beq $v0, 1, executar_formatar

    # ========== COMANDO INVALIDO ==========
    li $v0, 4
    la $a0, msg_comando_invalido
    syscall
    j fim_processar

# -------------------------------------------------------------
# EXECUÇÃO DOS COMANDOS
# -------------------------------------------------------------

executar_cadastrar:
    la $a0, input_buffer
    jal extrair_parametros_cadastro
    la $a0, op1_buffer   # CPF
    la $a1, op2_buffer   # CONTA
    la $a2, op3_buffer   # NOME
    jal cadastrar_cliente
    j fim_processar

executar_salvar:
    jal salvar_dados
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j fim_processar

executar_formatar:
    li $v0, 4
    la $a0, msg_confirmar_format
    syscall

    # Ler resposta
    li $v0, 12           # syscall read_char
    syscall
    move $t0, $v0

    li $t1, 'S'
    beq $t0, $t1, confirmar_formatar
    li $t1, 's'
    beq $t0, $t1, confirmar_formatar

    j fim_processar

confirmar_formatar:
    la $t0, num_clientes
    sw $zero, 0($t0)
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j fim_processar

# -------------------------------------------------------------
# EXTRAÇÃO DE PARÂMETROS DE COMANDO
# -------------------------------------------------------------
extrair_parametros_cadastro:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    move $s0, $a0
    li $s1, '-'
    move $s2, $s0

# Pula até o primeiro '-'
procura_traco:
    lb $t0, 0($s2)
    beq $t0, $s1, achou_traco
    beqz $t0, fim_extracao
    addi $s2, $s2, 1
    j procura_traco
achou_traco:
    addi $s2, $s2, 1

# Extrai CPF
    la $a0, op1_buffer
    move $a1, $s2
    li $a2, '-'
    jal extrair_ate_delimitador
    move $s2, $v0

# Extrai Conta
    la $a0, op2_buffer
    move $a1, $s2
    li $a2, '-'
    jal extrair_ate_delimitador
    move $s2, $v0

# Extrai Nome
    la $a0, op3_buffer
    move $a1, $s2
    li $a2, 0
    jal extrair_ate_delimitador

fim_extracao:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# -------------------------------------------------------------
# extrair_ate_delimitador
# -------------------------------------------------------------
extrair_ate_delimitador:
    move $t0, $a0
    move $t1, $a1
    move $t2, $a2
extrair_loop:
    lb $t3, 0($t1)
    beqz $t3, fim_extr2
    beq $t3, $t2, fim_extr2
    sb $t3, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j extrair_loop
fim_extr2:
    sb $zero, 0($t0)
    addi $v0, $t1, 1
    jr $ra

fim_processar:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# =============================================
# Fim do arquivo comandos.asm
# =============================================
