# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: arquivo.asm
# Funções auxiliares de persistência / inicialização - DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    # (As mensagens principais estão em constantes.asm)
    # Aqui podemos definir strings locais se necessário (opcional).
    load_on_start_msg: .asciiz "Inicializando: tentando recarregar dados salvos (se houver)...\n"

.text
    .globl salvar         # wrapper simples (chamável do parser)
    .globl recarregar     # wrapper simples (chamável do parser)
    .globl inicializar_dados  # chama recarregar no arranque, opcional

# -------------------------------------------------------------
# salvar
# -------------------------------------------------------------
# Wrapper que chama a rotina salvar_dados (implementada em salvar_dados.asm)
# Uso: jal salvar
# -------------------------------------------------------------
salvar:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Chama a rotina que efetivamente grava o conteúdo em arquivo
    jal salvar_dados

    # Exibe mensagem de confirmação (constantes.asm tem msg_arquivo_salvo)
    li $v0, 4
    la $a0, msg_arquivo_salvo
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# -------------------------------------------------------------
# recarregar
# -------------------------------------------------------------
# Wrapper que chama a rotina carregar_dados (implementada em salvar_dados.asm)
# Uso: jal recarregar
# -------------------------------------------------------------
recarregar:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal carregar_dados

    # Exibe mensagem de confirmação (constantes.asm tem msg_arquivo_carregado)
    li $v0, 4
    la $a0, msg_arquivo_carregado
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# -------------------------------------------------------------
# inicializar_dados
# -------------------------------------------------------------
# Rotina opcional que pode ser chamada no início do main para tentar
# recarregar automaticamente os dados salvos. Não é chamada automaticamente
# para não alterar seu main.asm sem sua permissão.
# Uso: jal inicializar_dados
# -------------------------------------------------------------
inicializar_dados:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    # Mensagem informativa (opcional)
    li $v0, 4
    la $a0, load_on_start_msg
    syscall

    # Tenta recarregar (chama a rotina principal de leitura)
    jal carregar_dados

    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# =============================================
# Fim do arquivo arquivo.asm
# =============================================
