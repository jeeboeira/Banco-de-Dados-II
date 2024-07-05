--JOB_TItems(itemID(PK), nomeItem, nomePadrão, dataCreated)
--JOB_TItemEntries(entryID(PK), itemID(FK TItens.itemID), entryDate)
--JOB_TAquisitions(aquisitionID(PK), itemID(FK TItens.itemID), dataAcquired)

-----------
--TABELAS--
-----------

--Cria Tabela de Itens, com sequence linear
create sequence SEQ_JOB_TItems
START   with 1 -- A sequence inicia com id 1
INCREMENT by 1 -- Incrementa em 1
NOCACHE        -- Os valores são gerados de forma sequencial, sem pular números
NOCYCLE        -- A sequência não reinicia quando alcançar o valor máximo

CREATE TABLE JOB_TItems (
    itemID      NUMBER  (19)  DEFAULT SEQ_JOB_TItems.nextval NOT NULL,
    nomeItem    VARCHAR2(255) NOT NULL,
    nomePadrão  VARCHAR2(255) NOT NULL,
    dataCreated TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT JOB_TItems_PK PRIMARY KEY(itemID)
);

-- Cria Tabela de repetição de itens inseridos
create sequence SEQ_JOB_TItemEntries
START   with 1 -- A sequence inicia com id 1
INCREMENT by 1 -- Incrementa em 1
NOCACHE        -- Os valores são gerados de forma sequencial, sem pular números
NOCYCLE        -- A sequência não reinicia quando alcançar o valor máximo

CREATE TABLE JOB_TItemEntries (
    entryID   NUMBER(19) DEFAULT SEQ_JOB_TItemEntries.nextval NOT NULL,
    itemID    NUMBER(19) NOT NULL,
    entryDate TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT JOB_TItemEntries_PK PRIMARY KEY(entryID),
    CONSTRAINT JOB_TItems_FK FOREIGN KEY (itemID) REFERENCES JOB_TItems(itemID)
);

-- Cria Tabela de Itens adquiridos
create sequence SEQ_JOB_TAquisitions
START   with 1 -- A sequence inicia com id 1
INCREMENT by 1 -- Incrementa em 1
NOCACHE        -- Os valores são gerados de forma sequencial, sem pular números
NOCYCLE        -- A sequência não reinicia quando alcançar o valor máximo

CREATE TABLE JOB_TAquisitions (
    aquisitionID NUMBER(19) DEFAULT SEQ_JOB_TAquisitions.nextval NOT NULL,
    itemID       NUMBER(19) NOT NULL,
    dataAcquired TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT JOB_TAquisitions_PK PRIMARY KEY(aquisitionID),
    CONSTRAINT JOB_TAquisitions_FK FOREIGN KEY (itemID) REFERENCES JOB_TItems(itemID)
);

----------------
-- PROCEDURES --
----------------

-- INSERE ITEM --

-- Especificação insere itens
CREATE OR REPLACE PACKAGE pkg_insereItem AS
    PROCEDURE prc_insert_insereItem (pi_nomeItem in JOB_TItems.nomeItem%TYPE,
                                     po_mensagem out VARCHAR2);
END pkg_insereItem;


-- Body
CREATE OR REPLACE PACKAGE BODY pkg_insereItem AS
    PROCEDURE prc_insert_insereItem (pi_nomeItem in JOB_TItems.nomeItem%TYPE,
                                     po_mensagem out VARCHAR2) IS
        v_nomepadrao VARCHAR2(255);
        v_idItemExistente NUMBER;
    BEGIN
        -- Padroniza o nome do item
        v_nomepadrao := LOWER(TRIM(pi_nomeItem));

        --Tenta ver se o item já existe
        BEGIN
            SELECT itemID INTO v_idItemExistente
            FROM JOB_TItems
            WHERE nomePadrão = v_nomepadrao;

            -- Se o item existe, registra ele na tabela de registros
            INSERT INTO JOB_TItemEntries (itemID) VALUES (v_idItemExistente);

            -- Mensagem de sucesso
            po_mensagem := 'Item encontrado e entrada registrada com sucesso.';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Se o item não existe, ele é adicionado
                INSERT INTO JOB_TItems (nomeItem, nomePadrão)
                VALUES (pi_nomeItem, v_nomepadrao)
                RETURNING itemID INTO v_idItemExistente;

                -- Registra a entrada do item
                INSERT INTO JOB_TItemEntries (itemID) VALUES (v_idItemExistente);

                -- Mensagem de sucesso
                po_mensagem := 'Item adicionado e entrada registrada com sucesso.';
        END;
    END prc_insert_insereItem;
END pkg_insereItem;

-- Chamada do Insere item
DECLARE
    v_mensagem VARCHAR2(4000);
BEGIN
    pkg_insereItem.prc_insert_insereItem (pi_nomeItem => 'alguma coisa',
                                          po_mensagem => v_mensagem);
dbms_output.put_line(v_mensagem);
END;



-- ITEM ADQUIRIDO --

-- Especificação Item Adquirido
CREATE OR REPLACE PACKAGE pkg_itemAdquirido AS
    PROCEDURE prc_insert_itemAdquirido (pi_nomeItem in JOB_TItems.nomeItem%TYPE,
                                        po_mensagem out VARCHAR2);
END pkg_itemAdquirido;


-- Body
CREATE OR REPLACE PACKAGE BODY pkg_itemAdquirido AS
    PROCEDURE prc_insert_itemAdquirido (pi_nomeItem in JOB_TItems.nomeItem%TYPE,
                                        po_mensagem out VARCHAR2) IS
        v_itemID NUMBER;
        v_nomepadrao VARCHAR2(255);
    BEGIN
        -- Padroniza o nome do item
        v_nomepadrao := LOWER(TRIM(pi_nomeItem));

        -- Verifica se o item existe e obtém o itemID
            SELECT itemID INTO v_itemID
            FROM JOB_TItems
            WHERE nomePadrão = v_nomepadrao;

            -- Marca o Item como adquirido
            INSERT INTO JOB_TAquisitions (itemID) VALUES (v_itemID);

            -- Mensagem de sucesso
            po_mensagem := 'Item marcado como adquirido com sucesso';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            po_mensagem := 'Item não encontrado. Não pode ser marcado como adquirido.';
    END prc_insert_itemAdquirido;
END pkg_itemAdquirido;


-- Chamada do Item adquirido
DECLARE
    v_mensagem VARCHAR2(4000);
BEGIN
    pkg_itemAdquirido.prc_insert_itemAdquirido (pi_nomeItem => 'Alguma coisa',
                                                po_mensagem => v_mensagem);
dbms_output.put_line(v_mensagem);
END;


-----------
-- VIEWS --
-----------

-- Tempo até Aquisição dos itens
CREATE OR REPLACE VIEW aquisitionTime AS
SELECT a.itemID, a.nomeItem, a.dataCreated, b.dataAcquired,
    (b.dataAcquired - a.dataCreated) AS aquisitionTime
FROM JOB_TItems A
JOIN JOB_TAquisitions b on a.itemID = b.itemID;

-- Frequência de inserção
CREATE OR REPLACE VIEW freqTime AS
SELECT a.itemID, a.nomeItem, COUNT(b.entryID) AS freqTime
FROM JOB_TItems a
JOIN JOB_TItemEntries b ON a.itemID = b.itemID
GROUP BY a.itemID, a.nomeItem
ORDER BY freqTime desc;

CREATE OR REPLACE VIEW tempoNaLista AS
SELECT a.itemID, a.nomeItem, a.dataCreated,
    CURRENT_TIMESTAMP - a.dataCreated AS tempoNaLista
FROM JOB_TItems a
LEFT JOIN JOB_TAquisitions b ON a.itemID = b.itemID
WHERE b.dataAcquired IS NULL;

-- SELECT * FROM aquisitionTime;
-- SELECT * FROM freqTime;
-- SELECT * FROM tempoNaLista

