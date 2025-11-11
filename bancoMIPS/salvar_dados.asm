# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: salvar_dados.asm
# Rotinas de persistência de dados binários - DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    filename: .asciiz "dados.bin"
    msg_erro_salvar: .asciiz "Erro ao salvar dados no arquivo.\n"
    msg_erro_carregar: .asciiz "Erro ao carregar dados do arquivo.\n"

.text
    .globl salvar_dados
    .globl carregar_dados

# -------------------------------------------------------------
# salvar_dados
# -------------------------------------------------------------
# Salva num arquivo binário o número de clientes e o array completo.
# -------------------------------------------------------------
salvar_dados:
    # Abre arquivo para escrita binária (syscall 13)
    li $v0, 13
    la $a0, filename      # nome do arquivo
    li $a1, 1             # modo 1 = escrita
    li $a2, 0             # flag padrão
    syscall
    move $s0, $v0         # guarda descritor do arquivo
    bltz $s0, erro_salvar # erro ao abrir

    # Escreve num_clientes (4 bytes)
    li $v0, 15
    move $a0, $s0
    la $a1, num_clientes
    li $a2, 4
    syscall

    # Escreve clientes_array (4000 bytes)
    li $v0, 15
    move $a0, $s0
    la $a1, clientes_array
    li $a2, 4000
    syscall

    # Fecha o arquivo
    li $v0, 16
    move $a0, $s0
    syscall

    jr $ra

erro_salvar:
    li $v0, 4
    la $a0, msg_erro_salvar
    syscall
    jr $ra

# -------------------------------------------------------------
# carregar_dados
# -------------------------------------------------------------
# Lê o arquivo binário salvo e restaura num_clientes e clientes_array.
# -------------------------------------------------------------
carregar_dados:
    # Abre arquivo para leitura binária (syscall 13)
    li $v0, 13
    la $a0, filename
    li $a1, 0             # modo 0 = leitura
    li $a2, 0
    syscall
    move $s0, $v0
    bltz $s0, erro_carregar

    # Lê num_clientes
    li $v0, 14
    move $a0, $s0
    la $a1, num_clientes
    li $a2, 4
    syscall

    # Lê clientes_array
    li $v0, 14
    move $a0, $s0
    la $a1, clientes_array
    li $a2, 4000
    syscall

    # Fecha o arquivo
    li $v0, 16
    move $a0, $s0
    syscall

    jr $ra

erro_carregar:
    li $v0, 4
    la $a0, msg_erro_carregar
    syscall
    jr $ra

# =============================================
# Fim do arquivo salvar_dados.asm
# =============================================
