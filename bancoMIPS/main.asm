# =============================================
# Sistema Bancário DodgersBank - ARQUIVO ÚNICO
# Grupo: João Lucas, João Victor, Miguel, Thiago
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    # ==================== CONSTANTES DO SISTEMA ====================
    MAX_CLIENTES: .word 50
    MAX_TRANSACOES: .word 50
    LIMITE_CREDITO_PADRAO: .word 150000
    TAMANHO_CLIENTE: .word 80
    TAMANHO_TRANSACAO: .word 32
    JUROS_INTERVALO: .word 60
    TAXA_JUROS: .word 100
    
    # ==================== STRINGS DO SISTEMA ====================
    banner: .asciiz "dodgersbank-shell>> "
    newline: .asciiz "\n"
    msg_loading: .asciiz "=== Sistema Bancario DodgersBank ===\n"
    msg_comando_invalido: .asciiz "Comando invalido\n"
    msg_sucesso: .asciiz "Operacao realizada com sucesso\n"
    msg_pagamento_sucesso: .asciiz "Pagamento realizado com sucesso\n"
    
    # Mensagens de clientes
    msg_cliente_cadastrado: .asciiz "Cliente cadastrado com sucesso. Numero da conta "
    msg_cpf_existente: .asciiz "Ja existe conta neste CPF\n"
    msg_conta_em_uso: .asciiz "Numero da conta ja em uso\n"
    msg_erro_limite_clientes: .asciiz "Erro: limite de clientes atingido!\n"
    msg_cliente_inexistente: .asciiz "Falha: cliente inexistente\n"
    msg_saldo_insuficiente: .asciiz "Falha: saldo insuficiente\n"
    msg_limite_insuficiente: .asciiz "Falha: limite insuficiente\n"
    msg_conta_fechada: .asciiz "Conta fechada com sucesso\n"
    msg_saldo_devedor: .asciiz "Falha: saldo devedor ainda nao quitado\n"
    
    # Comandos
    cmd_cadastrar: .asciiz "conta_cadastrar"
    cmd_sacar: .asciiz "sacar"
    cmd_depositar: .asciiz "depositar"
    cmd_salvar: .asciiz "salvar"
    cmd_recarregar: .asciiz "recarregar"
    cmd_formatar: .asciiz "formatar"
    
    # Caracteres especiais
    traco: .asciiz "-"
    espaco: .asciiz " "
    
    # Nome do arquivo
    arquivo_dados: .asciiz "banco_data.bin"

    # ==================== VARIÁVEIS DO SISTEMA ====================
    num_clientes: .word 0
    input_buffer: .space 256
    clientes_array: .space 4000      # 50 clientes × 80 bytes
    
    # Buffers temporários
    buffer_conta: .space 16
    op1_buffer: .space 64
    op2_buffer: .space 64
    op3_buffer: .space 64
    
    # Data e hora do sistema
    data_sistema: .asciiz "01/01/2025"
    hora_sistema: .asciiz "00:00:00"
    sim_time: .word 0

.text
.globl main

# ==================== PONTO DE ENTRADA ====================
__start:
    j main

main:
    # Mensagem de inicialização
    li $v0, 4
    la $a0, msg_loading
    syscall

main_loop:
    # Loop principal do terminal
    jal exibir_banner
    jal ler_comando
    jal processar_comando
    j main_loop

# ==================== FUNÇÕES BÁSICAS ====================
exibir_banner:
    li $v0, 4
    la $a0, banner
    syscall
    jr $ra

ler_comando:
    la $a0, input_buffer
    li $a1, 256
    li $v0, 8
    syscall
    jr $ra

# ==================== PROCESSAMENTO DE COMANDOS ====================
processar_comando:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Remove newline do input
    la $a0, input_buffer
    jal remover_newline
    
    # Verifica se é comando vazio
    la $t0, input_buffer
    lb $t1, 0($t0)
    beqz $t1, processar_fim
    
    # Tenta identificar o comando
    la $a0, input_buffer
    la $a1, cmd_cadastrar
    jal comparar_strings
    beq $v0, 1, executar_cadastrar
    
    la $a0, input_buffer
    la $a1, cmd_sacar
    jal comparar_strings
    beq $v0, 1, executar_sacar
    
    la $a0, input_buffer
    la $a1, cmd_depositar
    jal comparar_strings
    beq $v0, 1, executar_depositar
    
    la $a0, input_buffer
    la $a1, cmd_salvar
    jal comparar_strings
    beq $v0, 1, executar_salvar
    
    la $a0, input_buffer
    la $a1, cmd_recarregar
    jal comparar_strings
    beq $v0, 1, executar_recarregar
    
    la $a0, input_buffer
    la $a1, cmd_formatar
    jal comparar_strings
    beq $v0, 1, executar_formatar
    
    # Comando não reconhecido
    li $v0, 4
    la $a0, msg_comando_invalido
    syscall
    
    j processar_fim

executar_cadastrar:
    # Extrai parâmetros: conta_cadastrar-CPF-CONTA-NOME
    la $a0, input_buffer
    jal extrair_parametros_cadastro
    
    # Cadastra cliente
    la $a0, op1_buffer    # CPF
    la $a1, op2_buffer    # CONTA
    la $a2, op3_buffer    # NOME
    jal cadastrar_cliente
    
    j processar_fim

executar_sacar:
    # Simula saque
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j processar_fim

executar_depositar:
    # Simula depósito
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j processar_fim

executar_salvar:
    # Salva dados
    jal salvar_dados
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j processar_fim

executar_recarregar:
    # Recarrega dados
    jal carregar_dados
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j processar_fim

executar_formatar:
    # Formata sistema
    jal formatar_sistema
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    j processar_fim

processar_fim:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== FUNÇÕES DE STRING ====================
comparar_strings:
    move $t0, $a0
    move $t1, $a1
comp_loop:
    lb $t2, 0($t0)
    lb $t3, 0($t1)
    bne $t2, $t3, comp_diferente
    beqz $t2, comp_igual
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j comp_loop
comp_igual:
    li $v0, 1
    jr $ra
comp_diferente:
    li $v0, 0
    jr $ra

remover_newline:
    move $t0, $a0
rn_loop:
    lb $t1, 0($t0)
    beqz $t1, rn_fim
    beq $t1, 10, rn_encontrado
    addi $t0, $t0, 1
    j rn_loop
rn_encontrado:
    sb $zero, 0($t0)
rn_fim:
    jr $ra

strcpy:
    move $t0, $a0
    move $t1, $a1
strcpy_loop:
    lb $t2, 0($t1)
    sb $t2, 0($t0)
    beqz $t2, strcpy_fim
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j strcpy_loop
strcpy_fim:
    jr $ra

string_para_int:
    li $v0, 0
    li $t1, 10
conv_loop:
    lb $t0, 0($a0)
    beqz $t0, conv_fim
    blt $t0, 48, prox_char
    bgt $t0, 57, prox_char
    sub $t0, $t0, 48
    mul $v0, $v0, $t1
    add $v0, $v0, $t0
prox_char:
    addi $a0, $a0, 1
    j conv_loop
conv_fim:
    jr $ra

int_para_string:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $s0, 12($sp)
    
    move $s0, $a1
    add $t0, $a1, 15
    sb $zero, 0($t0)
    
    bnez $a0, nao_zero
    li $t1, '0'
    sb $t1, 0($s0)
    sb $zero, 1($s0)
    j int_str_fim

nao_zero:
    move $t1, $a0
    add $t2, $s0, 15
conv_digitos:
    beqz $t1, inverter_string
    li $t3, 10
    div $t1, $t3
    mfhi $t4
    mflo $t1
    addi $t4, $t4, '0'
    addi $t2, $t2, -1
    sb $t4, 0($t2)
    j conv_digitos

inverter_string:
    move $t5, $s0
copia_digitos:
    lb $t6, 0($t2)
    beqz $t6, int_str_fim
    sb $t6, 0($t5)
    addi $t5, $t5, 1
    addi $t2, $t2, 1
    j copia_digitos

int_str_fim:
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $s0, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# ==================== EXTRAÇÃO DE PARÂMETROS ====================
extrair_parametros_cadastro:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0
    li $s1, '-'
    move $s2, $s0

procurar_primeiro_traco:
    lb $t0, 0($s2)
    beq $t0, $s1, encontrou_primeiro_traco
    beqz $t0, extrair_fim
    addi $s2, $s2, 1
    j procurar_primeiro_traco

encontrou_primeiro_traco:
    addi $s2, $s2, 1
    
    # Extrai CPF
    la $a0, op1_buffer
    move $a1, $s2
    li $a2, '-'
    jal extrair_ate_delimitador
    move $s2, $v0
    
    # Extrai CONTA
    la $a0, op2_buffer
    move $a1, $s2
    li $a2, '-'
    jal extrair_ate_delimitador
    move $s2, $v0
    
    # Extrai NOME
    la $a0, op3_buffer
    move $a1, $s2
    li $a2, 0
    jal extrair_ate_delimitador

extrair_fim:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

extrair_ate_delimitador:
    move $t0, $a0
    move $t1, $a1
    move $t2, $a2
extrair_loop:
    lb $t3, 0($t1)
    beqz $t3, extrair_fim2
    beq $t3, $t2, extrair_fim2
    sb $t3, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j extrair_loop
extrair_fim2:
    sb $zero, 0($t0)
    addi $v0, $t1, 1
    jr $ra

# ==================== FUNÇÕES DE CLIENTES ====================
calcular_digito_verificador:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0
    li $s1, 0
    li $s2, 2
    li $s3, 10

calc_dig_loop:
    beqz $s0, calc_dig_fim
    div $s0, $s3
    mfhi $t0
    mflo $s0
    mul $t1, $t0, $s2
    add $s1, $s1, $t1
    addi $s2, $s2, 1
    j calc_dig_loop

calc_dig_fim:
    li $t2, 11
    div $s1, $t2
    mfhi $t3
    li $t4, 10
    beq $t3, $t4, digito_x
    addi $v0, $t3, '0'
    j calc_dig_end
digito_x:
    li $v0, 'X'
calc_dig_end:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

cadastrar_cliente:
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    # Verifica limite de clientes
    lw $t0, num_clientes
    lw $t1, MAX_CLIENTES
    bge $t0, $t1, erro_limite_clientes
    
    # Converte conta para inteiro
    move $a0, $s1
    jal string_para_int
    move $s3, $v0
    
    # Verifica se conta já existe
    move $a0, $s3
    jal buscar_cliente_por_conta
    bgez $v0, erro_conta_em_uso
    
    # Calcula dígito verificador
    move $a0, $s3
    jal calcular_digito_verificador
    move $s4, $v0
    
    # Armazena cliente
    la $s6, clientes_array
    lw $s5, num_clientes
    li $t0, 80
    mul $t1, $s5, $t0
    add $s6, $s6, $t1
    
    # ESTRUTURA DO CLIENTE (80 bytes):
    # 0-10: CPF (11 bytes)
    # 11-21: Conta + DV (11 bytes)
    # 22-71: Nome (50 bytes)
    # 72-75: Saldo (4 bytes)
    # 76-79: Limite crédito (4 bytes)
    
    # Armazena CPF
    move $a0, $s6
    move $a1, $s0
    jal strcpy
    
    # Armazena conta
    addi $a0, $s6, 11
    move $a1, $s1
    jal strcpy
    
    # Adiciona dígito verificador
    addi $t2, $s6, 17
    sb $s4, 0($t2)
    
    # Armazena nome
    addi $a0, $s6, 22
    move $a1, $s2
    jal strcpy
    
    # Inicializa saldo (0)
    sw $zero, 72($s6)
    
    # Inicializa limite de crédito padrão
    lw $t0, LIMITE_CREDITO_PADRAO
    sw $t0, 76($s6)
    
    # Incrementa contador
    lw $t0, num_clientes
    addi $t0, $t0, 1
    sw $t0, num_clientes
    
    # Mensagem de sucesso
    li $v0, 4
    la $a0, msg_cliente_cadastrado
    syscall
    
    # Mostra número da conta com DV
    move $a0, $s3
    la $a1, buffer_conta
    jal int_para_string
    li $v0, 4
    la $a0, buffer_conta
    syscall
    
    li $v0, 4
    la $a0, traco
    syscall
    
    li $v0, 11
    move $a0, $s4
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    j cadastrar_fim

erro_limite_clientes:
    li $v0, 4
    la $a0, msg_erro_limite_clientes
    syscall
    j cadastrar_fim

erro_conta_em_uso:
    li $v0, 4
    la $a0, msg_conta_em_uso
    syscall

cadastrar_fim:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addi $sp, $sp, 32
    jr $ra

buscar_cliente_por_conta:
    la $t0, clientes_array
    lw $t1, num_clientes
    li $t2, 0
buscar_loop:
    beq $t2, $t1, buscar_nao_encontrado
    li $t3, 80
    mul $t4, $t2, $t3
    add $t5, $t0, $t4
    lw $t6, 0($t5)
    beq $t6, $a0, buscar_encontrado
    addi $t2, $t2, 1
    j buscar_loop
buscar_encontrado:
    move $v0, $t2
    jr $ra
buscar_nao_encontrado:
    li $v0, -1
    jr $ra

# ==================== SISTEMA DE ARQUIVOS ====================
salvar_dados:
    # Simula salvamento
    jr $ra

carregar_dados:
    # Simula carregamento
    jr $ra

formatar_sistema:
    # Zera contador de clientes
    sw $zero, num_clientes
    jr $ra

# ==================== FINALIZAÇÃO ====================
encerrar:
    li $v0, 10
    syscall

# ==================== FIM DO SISTEMA ====================