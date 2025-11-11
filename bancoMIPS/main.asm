# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva, Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: main.asm
# Programa Principal - Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

# Inclui todos os módulos do sistema bancário
.include "constantes.asm"
.include "funcoes_string.asm"
.include "clientes.asm"
.include "comandos.asm"
.include "transacoes.asm"
.include "salvar_dados.asm"
.include "arquivo.asm"
.include "data_hora.asm"

.data
    # ==================== VARIÁVEIS GLOBAIS ====================
    .globl num_clientes
    .globl clientes_array
    .globl input_buffer

    # Contador de clientes (inteiro)
    num_clientes: .word 0

    # Buffer de entrada para leitura do terminal (256 bytes)
    input_buffer: .space 256

    # Array de clientes: 50 clientes × 80 bytes = 4000 bytes
    clientes_array: .space 4000

    # Arrays paralelos (50 x 4 bytes = 200 bytes cada)
    debts_array: .space 200          # dívida do cartão (centavos)
    last_interest: .space 200        # timestamp (segundos) da última incidência de juros
    trans_count_debito: .space 200   # contador de transações débito por cliente
    trans_count_credito: .space 200  # contador de transações crédito por cliente

    # Log global de transações: 500 entradas × 16 bytes = 8000 bytes
    trans_log: .space 8000
    trans_log_head: .word 0          # índice circular para o log

    # Simulated time (segundos) usado pelo comando data_hora / juros
    .globl sim_time
    sim_time: .word 0

.text
    # ==================== FUNÇÕES GLOBAIS ====================
    .globl main, exibir_banner, ler_comando, encerrar, __start

# -------------------------------------------------------------
# __start: ponto de entrada padrão do MARS
# -------------------------------------------------------------
__start:
    j main      # Garante que o MARS inicie a execução no nosso main

# -------------------------------------------------------------
# main: inicialização e loop principal do shell DodgersBank
# -------------------------------------------------------------
main:
    # Mensagem de inicialização
    li $v0, 4
    la $a0, msg_loading
    syscall

    # Inicializa os dados (tenta recarregar arquivo salvo)
    jal inicializar_dados

main_loop:
    # Exibe o prompt
    jal exibir_banner

    # Lê o comando digitado pelo usuário
    jal ler_comando

    # Processa o comando (parser em comandos.asm)
    jal processar_comando

    # Volta ao início do loop
    j main_loop

# -------------------------------------------------------------
# exibir_banner: exibe o prompt do terminal
# -------------------------------------------------------------
exibir_banner:
    li $v0, 4
    la $a0, banner               # definido em constantes.asm (ex: "dodgersbank-shell>> ")
    syscall
    jr $ra

# -------------------------------------------------------------
# ler_comando: captura uma linha de texto do usuário
# -------------------------------------------------------------
ler_comando:
    li $v0, 8                    # syscall para leitura de string
    la $a0, input_buffer
    li $a1, 256
    syscall                      # aguarda até o usuário pressionar Enter
    jr $ra

# -------------------------------------------------------------
# encerrar: finaliza o programa
# -------------------------------------------------------------
encerrar:
    li $v0, 10                   # syscall 10 = exit
    syscall

# ==================== FIM DO ARQUIVO =========================
