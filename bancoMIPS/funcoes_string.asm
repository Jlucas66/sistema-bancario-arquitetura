# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: funcoes_string.asm
# Funções utilitárias de manipulação de strings
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.text
    # ==================== FUNÇÕES GLOBAIS ====================
    .globl comparar_strings
    .globl remover_newline
    .globl copiar_string
    .globl string_vazia
    .globl concatenar_string
    .globl comprimento_string

# -------------------------------------------------------------
# comparar_strings
# -------------------------------------------------------------
# Compara duas strings terminadas em null.
# Entrada:
#   $a0 = endereço da string 1
#   $a1 = endereço da string 2
# Saída:
#   $v0 = 1 se são iguais, 0 se diferentes
# -------------------------------------------------------------
comparar_strings:
loop_cmp:
    lb $t0, 0($a0)         # caractere da string1
    lb $t1, 0($a1)         # caractere da string2
    bne $t0, $t1, not_equal
    beqz $t0, equal        # se ambos são '\0', terminou e são iguais
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j loop_cmp
equal:
    li $v0, 1
    jr $ra
not_equal:
    li $v0, 0
    jr $ra

# -------------------------------------------------------------
# remover_newline
# -------------------------------------------------------------
# Substitui o caractere '\n' por '\0' (terminador)
# Entrada:
#   $a0 = endereço da string
# Saída:
#   string modificada (sem newline)
# -------------------------------------------------------------
remover_newline:
loop_rm:
    lb $t0, 0($a0)
    beqz $t0, end_rm
    li $t1, 10             # código ASCII de '\n'
    beq $t0, $t1, replace
    addi $a0, $a0, 1
    j loop_rm
replace:
    sb $zero, 0($a0)       # substitui por null
end_rm:
    jr $ra

# -------------------------------------------------------------
# copiar_string
# -------------------------------------------------------------
# Copia string de origem ($a1) para destino ($a0)
# -------------------------------------------------------------
copiar_string:
loop_cp:
    lb $t0, 0($a1)
    sb $t0, 0($a0)
    beqz $t0, end_cp
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j loop_cp
end_cp:
    jr $ra

# -------------------------------------------------------------
# string_vazia
# -------------------------------------------------------------
# Retorna 1 se a string for vazia (primeiro char = '\0'), senão 0
# Entrada: $a0 = endereço da string
# Saída:   $v0 = 1 se vazia, 0 se não
# -------------------------------------------------------------
string_vazia:
    lb $t0, 0($a0)
    beqz $t0, str_empty
    li $v0, 0
    jr $ra
str_empty:
    li $v0, 1
    jr $ra

# -------------------------------------------------------------
# concatenar_string
# -------------------------------------------------------------
# Concatena $a1 no final de $a0
# Entrada:
#   $a0 = destino (string base)
#   $a1 = origem (string a ser concatenada)
# -------------------------------------------------------------
concatenar_string:
    move $t0, $a0
find_end:
    lb $t1, 0($t0)
    beqz $t1, copy_part
    addi $t0, $t0, 1
    j find_end

copy_part:
    lb $t2, 0($a1)
    sb $t2, 0($t0)
    beqz $t2, concat_done
    addi $t0, $t0, 1
    addi $a1, $a1, 1
    j copy_part
concat_done:
    jr $ra

# -------------------------------------------------------------
# comprimento_string
# -------------------------------------------------------------
# Calcula o comprimento (tamanho) de uma string (sem contar '\0')
# Entrada: $a0 = endereço da string
# Saída: $v0 = comprimento (número de caracteres)
# -------------------------------------------------------------
comprimento_string:
    move $t0, $a0        # ponteiro para a string
    li $v0, 0            # contador de caracteres = 0
compr_loop:
    lb $t1, 0($t0)       # lê o byte atual
    beqz $t1, compr_fim  # se for nulo, fim da string
    addi $v0, $v0, 1     # incrementa contador
    addi $t0, $t0, 1     # avança ponteiro
    j compr_loop
compr_fim:
    jr $ra

# =============================================
# Fim do arquivo funcoes_string.asm
# =============================================
