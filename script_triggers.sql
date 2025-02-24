CREATE TRIGGER TRIGGER_EMPRESTIMOS
ON emprestimos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE EMPRESTIMOS
	SET ATRASOU = 'Sim'
    WHERE STATUS = 'Vencido'

    UPDATE clientes
	SET status = 
    CASE 
        WHEN EXISTS (SELECT 1 FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Vencido') THEN 'Bloqueado'
        WHEN EXISTS (SELECT 1 FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Em andamento') THEN 'Ativo'
        ELSE 'Inativo'
    END;
END
GO

CREATE TRIGGER TRIGGER_CLIENTES
ON CLIENTES
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE clientes
	SET score = 
    CASE 
        WHEN renda_mensal >= 10000 THEN LEAST(1000, GREATEST(0, 500 + ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Quitado') * 25) 
                                                                    - ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND atrasou = 'Sim') * 250)))
        WHEN renda_mensal >= 7500 THEN LEAST(1000, GREATEST(0, 400 + ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Quitado') * 25) 
                                                                    - ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND atrasou = 'Sim') * 250)))
        WHEN renda_mensal >= 5000 THEN LEAST(1000, GREATEST(0, 300 + ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Quitado') * 25) 
                                                                    - ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND atrasou = 'Sim') * 250)))
        WHEN renda_mensal >= 2500 THEN LEAST(1000, GREATEST(0, 200 + ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Quitado') * 25) 
                                                                    - ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND atrasou = 'Sim') * 250)))
        ELSE LEAST(1000, GREATEST(0, 100 + ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND status = 'Quitado') * 25) 
                                      - ((SELECT COUNT(*) FROM emprestimos WHERE emprestimos.id_cliente = clientes.id AND atrasou = 'Sim') * 250)))
    END;
END
GO

CREATE TRIGGER TRIGGER_SOLICITACOES
ON solicitacoes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE SOLICITACOES
    SET SOLICITACOES.SCORE_CLIENTE = CLIENTES.SCORE
    FROM SOLICITACOES
    INNER JOIN CLIENTES ON SOLICITACOES.ID_CLIENTE = CLIENTES.ID
    WHERE SOLICITACOES.ID IN (SELECT ID FROM inserted);

    UPDATE SOLICITACOES
    SET VALOR_MAXIMO = CLIENTES.RENDA_MENSAL * (CAST(CLIENTES.SCORE AS DECIMAL(10,1)) / 200)
    FROM SOLICITACOES
    INNER JOIN CLIENTES ON SOLICITACOES.ID_CLIENTE = CLIENTES.ID
    WHERE SOLICITACOES.ID IN (SELECT ID FROM inserted);

    UPDATE SOLICITACOES
    SET STATUS = 'Negado',
        Observacoes = 'Período do empréstimo inválido.'
    WHERE (DATA_VENCIMENTO < GETDATE() OR DATA_EMPRESTIMO >= DATA_VENCIMENTO) AND STATUS = 'Em análise';

    UPDATE SOLICITACOES
    SET STATUS = 'Negado',
        Observacoes = 'Valor do empréstimo excede o limite de crédito do cliente.'
    WHERE VALOR_SOLICITADO > VALOR_MAXIMO AND STATUS = 'Em análise';
END
GO

CREATE TRIGGER TRIGGER_SOLICITACOES_INSERT
ON solicitacoes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	INSERT INTO EMPRESTIMOS (ID_SOLICITACAO, ID_CLIENTE, VALOR_EMPRESTIMO, TAXA_JUROS_MENSAL, VALOR_RETORNO, DATA_EMPRESTIMO, DATA_VENCIMENTO)
    SELECT 
        SOLICITACOES.ID, 
        SOLICITACOES.ID_CLIENTE, 
        SOLICITACOES.VALOR_SOLICITADO, 
        2.5, 
        SOLICITACOES.VALOR_SOLICITADO * 1.025, 
        SOLICITACOES.DATA_EMPRESTIMO, 
        SOLICITACOES.DATA_VENCIMENTO
    FROM SOLICITACOES
    WHERE SOLICITACOES.STATUS = 'Aprovado' 
    AND SOLICITACOES.ID IN (SELECT ID FROM inserted)
	AND NOT EXISTS (SELECT 1 FROM EMPRESTIMOS WHERE EMPRESTIMOS.ID_SOLICITACAO = SOLICITACOES.ID);
END
GO