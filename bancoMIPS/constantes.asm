# =============================================
# Grupo: João Lucas de Araújo, João Victor de Araújo Silva,  Miguel Cavalcanti Rufino, Thiago Rozendo
# Arquivo: constantes.asm
# Constantes e Definições Globais - Sistema Bancário DodgersBank
# UFRPE 2025.2 - Arquitetura e Organização de Computadores
# =============================================

.data
    # ==================== CONSTANTES NUMÉRICAS ====================
    .globl MAX_CLIENTES
    .globl LIMITE_CREDITO_PADRAO
    .globl MAX_TRANSACOES
    .globl TAM_CLIENTE
    .globl TAXA_JUROS
    .globl TEMPO_JUROS

    MAX_CLIENTES:         .word 50          # Limite de clientes simultâneos
    MAX_TRANSACOES:       .word 50          # Máximo de transações de cada tipo por cliente
    LIMITE_CREDITO_PADRAO:.word 150000      # 1500,00 reais em centavos
    TAM_CLIENTE:          .word 80          # Tamanho de registro de cliente (bytes)
    TAXA_JUROS:           .float 0.01       # Juros de 1%
    TEMPO_JUROS:          .word 60          # 1% a cada 60 segundos (simulação)

    # ==================== STRINGS DE INTERFACE ====================
    .globl banner
    .globl newline
    .globl msg_loading
    .globl msg_sucesso
    .globl msg_comando_invalido
    .globl msg_erro_limite_clientes
    .globl msg_conta_em_uso
    .globl msg_cpf_existente
    .globl msg_cliente_cadastrado
    .globl msg_arquivo_salvo
    .globl msg_arquivo_carregado
    .globl msg_erro_arquivo
    .globl msg_conta_invalida
    .globl msg_saldo_insuficiente
    .globl msg_limite_insuficiente
    .globl msg_pagamento_ok
    .globl msg_conta_fechada
    .globl msg_falha_saldo_ou_credito
    .globl msg_dados_formatados

    banner:                 .asciiz "dodgersbank-shell>> "
    newline:                .asciiz "\n"
    msg_loading:            .asciiz "=== Sistema Bancario DodgersBank ===\n"
    msg_comando_invalido:   .asciiz "Comando invalido\n"
    msg_sucesso:            .asciiz "Operacao realizada com sucesso\n"
    msg_erro_limite_clientes:.asciiz "Erro: limite maximo de clientes atingido\n"
    msg_conta_em_uso:       .asciiz "Numero da conta ja em uso\n"
    msg_cpf_existente:      .asciiz "Ja existe conta neste CPF\n"
    msg_cliente_cadastrado: .asciiz "Cliente cadastrado com sucesso. Numero da conta "
    msg_arquivo_salvo:      .asciiz "Dados salvos em arquivo com sucesso.\n"
    msg_arquivo_carregado:  .asciiz "Dados recarregados do arquivo.\n"
    msg_erro_arquivo:       .asciiz "Erro ao abrir arquivo de dados.\n"
    msg_conta_invalida:     .asciiz "Conta invalida ou inexistente.\n"
    msg_saldo_insuficiente: .asciiz "Falha: saldo insuficiente.\n"
    msg_limite_insuficiente:.asciiz "Falha: limite insuficiente.\n"
    msg_pagamento_ok:       .asciiz "Pagamento realizado com sucesso.\n"
    msg_conta_fechada:      .asciiz "Conta fechada com sucesso.\n"
    msg_falha_saldo_ou_credito: .asciiz "Falha: saldo ou limite ainda nao quitado.\n"
    msg_dados_formatados:   .asciiz "Todos os dados foram formatados (memoria limpa).\n"

    # ==================== COMANDOS SUPORTADOS ====================
    .globl cmd_cadastrar
    .globl cmd_salvar
    .globl cmd_recarregar
    .globl cmd_formatar
    .globl cmd_sacar
    .globl cmd_depositar
    .globl cmd_alterar_limite
    .globl cmd_conta_fechar
    .globl cmd_data_hora
    .globl cmd_transferir_debito
    .globl cmd_transferir_credito
    .globl cmd_pagar_fatura
    .globl cmd_extrato_debito
    .globl cmd_extrato_credito

    cmd_cadastrar:          .asciiz "conta_cadastrar"
    cmd_salvar:             .asciiz "salvar"
    cmd_recarregar:         .asciiz "recarregar"
    cmd_formatar:           .asciiz "formatar"
    cmd_sacar:              .asciiz "sacar"
    cmd_depositar:          .asciiz "depositar"
    cmd_alterar_limite:     .asciiz "alterar_limite"
    cmd_conta_fechar:       .asciiz "conta_fechar"
    cmd_data_hora:          .asciiz "data_hora"
    cmd_transferir_debito:  .asciiz "transferir_debito"
    cmd_transferir_credito: .asciiz "transferir_credito"
    cmd_pagar_fatura:       .asciiz "pagar_fatura"
    cmd_extrato_debito:     .asciiz "debito_extrato"
    cmd_extrato_credito:    .asciiz "credito_extrato"

    # ==================== ARQUIVO BINÁRIO ====================
    .globl nome_arquivo
    nome_arquivo:           .asciiz "dados_banco.bin"

# =============================================
# Fim do arquivo constantes.asm
# =============================================
