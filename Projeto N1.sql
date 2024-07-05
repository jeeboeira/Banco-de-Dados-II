--JOB_TClientes(clienteID, nomeCliente, enderecoCliente, cpfCliente);
--JOB_TProdutos(produtoID, nomeProduto);
--JOB_TClienteNF(notaFiscalID, clienteID);
--JOB_TItensNotaFiscal(notaFiscalID, itemID, produtoId, quantidade);


--Item 1 e 2

-- Cria tabela Cliente
create sequence SEQ_JOB_TClientes
START WITH 1
INCREMENT BY 1

create table JOB_TClientes (
    clienteID NUMBER(19) DEFAULT SEQ_JOB_TClientes.nextval
    , nomeCliente VARCHAR2(100)
    , enderecoCliente VARCHAR2(100)
    , cpfCliente VARCHAR2(11),
    
    CONSTRAINT JOB_TClientes_PK PRIMARY KEY(clienteID)
)

-- Cria tabela Produtos
--JOB_TProdutos(produtoID, nomeProduto);
create sequence SEQ_JOB_TProdutos

create table JOB_TProdutos (
    produtoId NUMBER (19) GENERATED ALWAYS AS IDENTITY
    , nomeProduto VARCHAR2(100),

    CONSTRAINT JOB_TProdutos_PK PRIMARY KEY(produtoId)
)

--Cria tabela Cliente - NF
--JOB_TClienteNF(notaFiscalID, clienteID)
Create sequence SQ_JOB_TClienteNF
START WITH 1000
INCREMENT BY 1
NOCACHE
NOCYCLE

create table JOB_TClienteNF (
    notaFiscalID NUMBER(19) DEFAULT SQ_JOB_TClienteNF.nextval
    , clienteID NUMBER(19),

    CONSTRAINT JOB_TClienteNF_PK PRIMARY KEY(notaFiscalID),

    CONSTRAINT JOB_TClienteNF_clienteID_FK
    FOREIGN KEY (clienteID) REFERENCES JOB_TClientes (clienteID)
)


-- Cria tabela Itens Nota Fiscal
--JOB_TItensNotaFiscal(notaFiscalID, itemID, produtoId, quantidade);
create table JOB_TItensNotaFiscal (
    notaFiscalID NUMBER(19)
    , itemId NUMBER (19)
    , produtoId NUMBER(19)
    , quantidade NUMBER(19),

    CONSTRAINT JOB_ItensNotaFiscal_Pk PRIMARY KEY (itemId, notaFiscalID),

    CONSTRAINT JOB_ItensNotaFiscal_notaFiscalID_FK
    FOREIGN KEY (notaFiscalID) REFERENCES JOB_TClienteNF(notaFiscalID),

    CONSTRAINT JOB_ItensNotaFiscal_produtoId_FK
    FOREIGN KEY (produtoId) REFERENCES JOB_TProdutos (produtoId)
)

-- ok

-- ITEM 3

-- Inserir alguns produtos
--JOB_TProdutos(produtoID, nomeProduto);

insert into JOB_TProdutos (nomeProduto)
    VALUES ('Produto1')


-- Inserir alguns Clientes
--JOB_TClientes(clienteID, nomeCliente, enderecoCliente, cpfCliente);

insert into JOB_TClientes (nomeCliente
                            ,enderecoCliente
                            ,cpfCliente)
    VALUES ('Alfredo'
            , 'Rua Alameda, 30'
            , '01234567891')


--Procedure para criar novo pedido 

--cria nota fiscal JOB_TClienteNF (notaFiscalID)
--atrela ao JOB_TClienteNF (clienteID)
-- preenche JOB_TItensNotaFiscal (notaFiscalID, produtoId, quantidade)

--Especificação
CREATE OR REPLACE package pkg_pedido AS
    PROCEDURE prc_insert_pedido (pi_clienteID in JOB_TClientes.clienteID%TYPE
                                , pi_produtoId in JOB_TItensNotaFiscal.produtoId%TYPE
                                , pi_quantidade in JOB_TItensNotaFiscal.quantidade%TYPE
                                , po_mensagem out VARCHAR2);
END pkg_pedido;


--Body
CREATE OR REPLACE package body pkg_pedido AS
    PROCEDURE prc_insert_pedido (pi_clienteID in JOB_TClientes.clienteID%TYPE
                                , pi_produtoId in JOB_TItensNotaFiscal.produtoId%TYPE
                                , pi_quantidade in JOB_TItensNotaFiscal.quantidade%TYPE
                                , po_mensagem out VARCHAR2) IS
        v_notaFiscalID NUMBER;
        v_itemID NUMBER;
    BEGIN
        INSERT INTO JOB_TClienteNF (clienteID)
                            VALUES (pi_clienteID)
            RETURNING notaFiscalID INTO v_notaFiscalID;

    v_itemID := 1;
        
        INSERT INTO JOB_TItensNotaFiscal (notaFiscalID
                                        , itemID
                                        , produtoId
                                        , quantidade)
                                VALUES (v_notaFiscalID
                                        , v_itemID
                                        , pi_produtoId
                                        , pi_quantidade);
        po_mensagem := 'Nota fiscal e item inseridos com sucesso.';
    exception
        WHEN others THEN
            po_mensagem := sqlerrm;
    END prc_insert_pedido;
END pkg_pedido;


-- Chamada do Pacote Pedido
DECLARE
    v_mensagem VARCHAR2(4000);
BEGIN
    pkg_pedido.prc_insert_pedido (pi_clienteID => 1
                                , pi_produtoId => 1
                                , pi_quantidade => 5
                                , po_mensagem => v_mensagem);
dbms_output.put_line(v_mensagem);
END;


-- Procedure para incluir item no pedido

--Resgata a nota fiscal JOB_TItensNotaFiscal(notaFiscalID);
--Insere o próximo valor do item no pedido JOB_TItensNotaFiscal(itemID);
--Insere o produto JOB_TItensNotaFiscal(produtoId, quantidade);

--Especificação
CREATE OR REPLACE package pkg_insereItem AS
    PROCEDURE prc_insert_insereItem (pi_insereItem in JOB_TItensNotaFiscal%ROWTYPE
                                   , po_mensagem out VARCHAR2);
END pkg_insereItem;

--body
CREATE OR REPLACE package body pkg_insereItem AS
    PROCEDURE prc_insert_insereItem (pi_insereItem in JOB_TItensNotaFiscal%ROWTYPE
                                   , po_mensagem out VARCHAR2) IS
        v_itemID NUMBER;
    BEGIN
        SELECT COALESCE(MAX(itemID), 0) + 1 
            INTO v_itemID 
            FROM JOB_TItensNotaFiscal
            WHERE notaFiscalID = pi_insereItem.notaFiscalID;
        INSERT INTO JOB_TItensNotaFiscal (notaFiscalID
                                        , itemID
                                        , produtoId
                                        , quantidade)
                                  VALUES (pi_insereItem.notaFiscalID
                                        , v_itemID
                                        , pi_insereItem.produtoId
                                        , pi_insereItem.quantidade);
        po_mensagem := 'Item adicionado com sucesso à nota fiscal.';
    exception
        WHEN others THEN
            po_mensagem := sqlerrm;
    END prc_insert_insereItem;
END pkg_insereItem;

-- Chamada do Pacote Pedido
DECLARE
    v_mensagem VARCHAR2(4000);
    v_insereItem JOB_TItensNotaFiscal%ROWTYPE;
BEGIN
    v_insereItem.notaFiscalID := 1000;
    v_insereItem.produtoId := 2;
    v_insereItem.quantidade := 15;

    pkg_insereItem.prc_insert_insereItem (pi_insereItem => v_insereItem                                
                                        , po_mensagem => v_mensagem);
dbms_output.put_line(v_mensagem);
END;


--Desenvolver uma Função que retorna a quantidade de itens de um Pedido.

--Cria a função
CREATE OR replace function fjob_itens_pedido(pi_pedido in JOB_TItensNotaFiscal.notaFiscalID%TYPE) return number
IS
    v_retorno NUMBER;
BEGIN
    SELECT sum(QUANTIDADE) 
        INTO v_retorno
        from JOB_TItensNotaFiscal
        where NOTAFISCALID = pi_pedido;
    RETURN v_retorno;
END fjob_itens_pedido;

--Chama a função
SELECT fjob_itens_pedido(1000) FROM dual


--Desenvolver uma view que retorna os pedidos e seus itens.
create or replace view job_vpedidos as
SELECT a.notaFiscalID, a.itemID, a.produtoId, b.nomeProduto, a.quantidade
FROM JOB_TItensNotaFiscal a
JOIN JOB_TProdutos b on a.produtoId = b.produtoId
ORDER by a.notaFiscalID, a.itemID

Select * from job_vpedidos

--JOB_TClientes(clienteID, nomeCliente, enderecoCliente, cpfCliente);
--JOB_TProdutos(produtoID, nomeProduto);
--JOB_TClienteNF(notaFiscalID, clienteID);
--JOB_TItensNotaFiscal(notaFiscalID, itemID, produtoId, quantidade);