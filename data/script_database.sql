DROP TABLE IF EXISTS USUARIOS;

CREATE TABLE USUARIOS (
        ID INT IDENTITY(1,1) PRIMARY KEY,        
        EMAIL VARCHAR(255) UNIQUE NOT NULL,
        HASH_SENHA VARCHAR(72) NOT NULL,
        NOME VARCHAR(100) NOT NULL,
        CPF CHAR(14),
        DATA_NASCIMENTO DATE,
        TELEFONE CHAR(14),
		ESTADO VARCHAR(255),
        CIDADE VARCHAR(255),
        BAIRRO VARCHAR(255),
        LOGRADOURO VARCHAR(255),
        NUMERO INT,
        COMPLEMENTO VARCHAR(255),
        CEP CHAR(9), 
        TIPO VARCHAR(8) CHECK (TIPO IN ('Admin', 'User')) DEFAULT 'User',
        DATA_CADASTRO DATETIME DEFAULT GETDATE(),
        DATA_ATUALIZACAO DATETIME,
        OBSERVACOES VARCHAR(MAX),
);
CREATE UNIQUE INDEX CPFS_UNICOS ON USUARIOS(CPF) WHERE CPF IS NOT NULL;
CREATE UNIQUE INDEX TELEFONES_UNICOS ON USUARIOS(TELEFONE) WHERE TELEFONE IS NOT NULL;
