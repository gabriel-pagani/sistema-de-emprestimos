DROP TABLE IF EXISTS EMPRESTIMOS;
DROP TABLE IF EXISTS SOLICITACOES;
DROP TABLE IF EXISTS CLIENTES;

CREATE TABLE CLIENTES (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	NOME VARCHAR(255) NOT NULL,
	CPF VARCHAR(14) UNIQUE CHECK (CPF LIKE '___.___.___-__') NOT NULL,
	DATA_NASCIMENTO DATE NOT NULL,
	TELEFONE VARCHAR(14) UNIQUE CHECK (TELEFONE LIKE '(%)_____-____') NOT NULL,
	EMAIL VARCHAR(255) UNIQUE CHECK (EMAIL LIKE '%_@_%._%') NOT NULL,
	ENDERECO VARCHAR(255) NOT NULL,
	CIDADE VARCHAR(255) NOT NULL,
	ESTADO VARCHAR(255) NOT NULL,
	CEP VARCHAR(10) CHECK (cep LIKE '_____-___') NOT NULL,
	RENDA_MENSAL DECIMAL(10,2) NOT NULL,
	STATUS VARCHAR(10) CHECK (STATUS IN ('Ativo', 'Inativo', 'Bloqueado')) DEFAULT 'Inativo',
	SCORE INT DEFAULT 0, 
	DATA_CADASTRO DATE DEFAULT GETDATE(),
	OBSERVACOES TEXT,
);

CREATE TABLE SOLICITACOES (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ID_CLIENTE INT FOREIGN KEY REFERENCES CLIENTES(ID),
	SCORE_CLIENTE INT DEFAULT 0,
	VALOR_MAXIMO DECIMAL(10,2) DEFAULT 0, 
	VALOR_SOLICITADO DECIMAL(10,2) NOT NULL,
	DATA_EMPRESTIMO DATE NOT NULL,
	DATA_VENCIMENTO DATE NOT NULL,
	STATUS VARCHAR(15) CHECK (STATUS IN ('Aprovado', 'Negado', 'Em análise')) DEFAULT 'Em análise',
	OBSERVACOES TEXT,
);

CREATE TABLE EMPRESTIMOS (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ID_SOLICITACAO INT FOREIGN KEY REFERENCES SOLICITACOES(ID),
	ID_CLIENTE INT FOREIGN KEY REFERENCES CLIENTES(ID),
	VALOR_EMPRESTIMO DECIMAL(10,2) NOT NULL,  
	TAXA_JUROS_MENSAL DECIMAL(5,2) NOT NULL,
	VALOR_RETORNO DECIMAL(10,2) NOT NULL,
	DATA_EMPRESTIMO DATE NOT NULL,
	DATA_VENCIMENTO DATE NOT NULL,
	STATUS VARCHAR(15) CHECK (STATUS IN ('Em andamento', 'Quitado', 'Cancelado', 'Vencido')) DEFAULT 'Em andamento',
	ATRASOU VARCHAR(3) CHECK (ATRASOU IN ('Sim', 'Não')) DEFAULT 'Não',
	OBSERVACOES TEXT,
);