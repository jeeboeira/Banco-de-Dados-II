-- Joga um numero pro meu id
create sequence SEQ_JOB_TTIPOS

create table JOB_TTIPOS (
     id NUMBER(19)
    , tipo VARCHAR2(100)

    CONSTRAINT JOB_TTIPOS_PK PRIMARY KEY(ID)
)

create sequence SEQ_JOB_TANIMAIS

create table JOB_TANIMAIS (
    id NUMBER(19)
    , nome VARCHAR2(100)
    , tipo_ID NUMBER(19),

    CONSTRAINT JOB_TANIMAIS_PK PRIMARY KEY (ID),
    CONSTRAINT JOB_TANIMAIS_TIPO_FK
    FOREIGN KEY(tipo_id) REFERENCES JOB_TTIPOS(ID)
)

insert into JOB_TTIPOS (id
                        , tipo)
    VALUES (SEQ_JOB_TTIPOS.nextval --id
                , 'Gato') --tipo

insert into JOB_TTIPOS (id
                        , tipo)
    VALUES (SEQ_JOB_TTIPOS.nextval --id
                , 'Cachorro') --tipo --se coloca entre aspas ele fica case sensitive

alter table JOB_TTIPOS 
    add CONSTRAINT JOB_TTIPOS_PK PRIMARY KEY(ID)

INSERT INTO JOB_TANIMAIS (id
                            , nome
                            , tipo_ID)
    VALUES (SEQ_JOB_TTIPOS.nextval
            ,'Alfredo'
            ,500)

SELECT id 
from JOB_TTIPOS
where TIPO = 'Gato'


-- INSERE UM ANIMAL
DECLARE
    v_gato_id JOB_TTIPOS.ID%TYPE; --Variavel para salvar o id
    v_gato_tipo JOB_TTIPOS.tipo%TYPE; --Variavel para salvar o tipo, nao utilizada
BEGIN
    select id --v_gato_id
         , tipo --v_gato_tipo
    INTO v_gato_id
        ,v_gato_tipo
    FROM JOB_TTIPOS
    where tipo = 'Gato';

    INSERT INTO JOB_TANIMAIS (id
                            , nome
                            , tipo_ID)
    VALUES (SEQ_JOB_TTIPOS.nextval
            ,'Greta'
            ,v_gato_id);

END;

-- describe consulta o banco
describe JOB_TANIMAIS


--Mostra as Primery key
  SELECT a.table_name, a.column_name, a.constraint_name, c.owner, 
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
   AND a.table_name =  'JOB_TANIMAIS'

--Mostra todas as tabelas
SELECT * FROM USER_TABLES

-- Select que pega ID e NOME da tabela ANIMAIS e TIPO da tabela TIPOS
SELECT a.id, a.nome, c.tipo
FROM JOB_TANIMAIS a
JOIN JOB_TTIPOS c on c.id = a.tipo_ID

-- salva um select
create view job_vanimais as
SELECT a.id, a.nome, c.tipo
FROM JOB_TANIMAIS a
JOIN JOB_TTIPOS c on c.id = a.tipo_ID

-- create or replace vai dropar o antigo e criar um novo
create or replace view job_vanimais as
SELECT a.id, a.nome, c.tipo
FROM JOB_TANIMAIS a
JOIN JOB_TTIPOS c on c.id = a.tipo_ID


-- cria uma tabela - tentar não criar isso, usar com o comando REFRESH ON DEMAND
-- replace não funciona aqui
create MATERIALIZED view job_mvanimais as
SELECT a.id, a.nome, c.tipo
FROM JOB_TANIMAIS a
JOIN JOB_TTIPOS c on c.id = a.tipo_ID


-- cria uma tabela - deixa a view rapida, mas o sistema lento - replace não funciona aqui
-- ele não atualiza quando é adicionado novas coisas na tabela
create MATERIALIZED view job_rmvanimais REFRESH ON DEMAND as
SELECT a.id, a.nome, c.tipo
FROM JOB_TANIMAIS a
JOIN JOB_TTIPOS c on c.id = a.tipo_ID


-- Atualiza minha MATERIALIZED VIEW
BEGIN
DBMS_SNAPSHOT.REFRESH('job_rmvanimais');
END;


-- as view funcionam como uma nova tabela
select * from job_vanimais


-- tabela dual é uma tabela fantasma pra fazer select em coisas sem tabela
-- aqui puxa a data do sistema
SELECT sysdate
FROM dual 


-- Cria um índice na tabela estrangeira (Pesquisar sobre isso, que não entendi)
create index  JOB_TANIMAIS_TIPO_I on JOB_tanimais(tipo_id)


--Criar uma tabela DONOS (ID, NOME, ENDEREÇO)
create table JOB_TDONOS (
    id NUMBER(19)
    , nome VARCHAR2(100)
    , endereço VARCHAR2(100),

    CONSTRAINT JOB_TDONOS_PK PRIMARY KEY (ID),
)

create sequence SEQ_JOB_TDONOS

--Criar uma tabela de ligação dos donos com os animais

--Dono-ANIMAL(id, iddono , idanimal)
CREATE TABLE JOB_TDONO_ANIMAL(
    id NUMBER (19)
    , idDono NUMBER (19)
    , idAnimal NUMBER (19),

    CONSTRAINT JOB_TDONO_TANIMAL PRIMARY KEY (ID),

    CONSTRAINT JOB_TDONO_ANIMAL_idDono_FK
    FOREIGN KEY(idDono) REFERENCES JOB_TDONOS(ID),

    CONSTRAINT JOB_TDONO_ANIMAL_idAnimal_FK
    FOREIGN KEY(idAnimal) REFERENCES JOB_TANIMAIS(ID)
)

CREATE SEQUENCE SEQ_JOB_TDONO_ANIMAL

Create index  JOB_TDONO_ANIMAL_idDono_I on JOB_TDONO_ANIMAL(idDono)
Create index  JOB_TDONO_ANIMAL_idAnimal_I on JOB_TDONO_ANIMAL(idAnimal)



AULA DIA 05/04/24 - Funções

SELECT to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS')
SELECT substr('isso é um teste ',1 ,5) from dual - Pega o 
SELECT instr('isso é um teste ','u') from dual -- retorna a posição que esta o objeto da busca

SELECT substr('o numero da nota é: 54564',20)
   from dual

SELECT instr('o numero da nota é: 54564',':')
   from dual

CREATE TABLE tjob_notas (descricao varchar2(200))

insert into tjob_notas values ('Nome: estjaeh|Codigo:231212|Quantidade:25')
insert into tjob_notas values ('Nome: aeqwtehaeh|Codigo:231212|Quantidade:2')

SELECT descricao, substr(descricao,6,6) FROM tjob_notas

SELECT descricao, instr(descricao,'Codigo:'), substr(descricao, instr(descricao,'Codigo:')+7,6) FROM tjob_notas

CREATE OR replace function fjob_retorna_codigo(pi_descricao in tjob_notas.descricao%TYPE ) return number
IS
    v_retorno NUMBER;
BEGIN
    v_retorno := substr(pi_descricao, instr(pi_descricao,'Codigo:')+7,6);
    RETURN v_retorno;
END fjob_retorna_codigo;

SELECT * FROM tjob_notas

select  fjob_retorna_codigo(descricao) FROM tjob_notas

AULA DIA 19/04/24 - Procedure

CREATE or REPLACE PROCEDURE prc_insert_tanimail (pi_animal_id in JOB_tanimais.id%TYPE
                                                , pi_nome     in job_tanimais.nome%TYPE
                                                , pi_tipo_id  in JOB_tanimais.tipo_id%TYPE
                                                , po_mensagem out VARCHAR2) IS
BEGIN
    INSERT INTO job_tanimais (id
                            , nome
                            , tipo_id )
                    VALUES (pi_animal_id
                            , pi_nome
                            , pi_tipo_id);
    po_mensagem := 'deu bom!';
exception
    WHEN others THEN
        po_mensagem := sqllerrm;
END prc_teste;



select * from user_objects


-- Chamada do pacote
DECLARE
    v_mensagem VARCHAR2(4000);
BEGIN
prc_insert_tanimail ( pi_animal_id => SEQ_JOB_TANIMAIS.nextval
                    , pi_nome     => 'Adrobaldo'
                    , pi_tipo_id  => 21
                    , po_mensagem => v_mensagem
);
dbms_output_.put_line(v_mensagem);
END;

--Especificação
CREATE or REPLACE package pkg_animal AS
    PROCEDURE prc_insert ( pi_animal in JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2);
END pkg_animal;


--body
CREATE or REPLACE package body pkg_animal AS
    PROCEDURE prc_insert ( pi_animal in JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2) IS
    BEGIN
        INSERT INTO job_tanimais (id
                                , nome
                                , tipo_id )
                        VALUES (SEQ_JOB_TANIMAIS.nextval
                                , pi_animal.nome
                                , pi_animal.tipo_id);
        po_mensagem := 'deu bom!';
    exception
        WHEN others THEN
            po_mensagem := sqlerrm;
    END prc_insert;
END pkg_animal;




Especificação 2
CREATE or REPLACE package pkg_animal AS
    PROCEDURE prc_insert ( pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2);
END pkg_animal;

body2
CREATE or REPLACE package body pkg_animal AS
    PROCEDURE prc_insert ( pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2) IS
    BEGIN
        pio_animal.id := SEQ_JOB_TANIMAIS.nextval;
        INSERT INTO job_tanimais
                        VALUES pio_animal;
        po_mensagem := 'deu bom!';
    exception
        WHEN others THEN
            po_mensagem := sqlerrm;
    END prc_insert;
END pkg_animal;




Especificação 3
CREATE or REPLACE package pkg_animal AS
    PROCEDURE prc_insert ( pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2);
    
    PROCEDURE prc_update ( pi_animal_id in JOB_tanimais.id%TYPE
                         , pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2);
END pkg_animal;


body 3
CREATE or REPLACE package body pkg_animal AS
    PROCEDURE prc_insert ( pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2) IS
    BEGIN
        pio_animal.id := SEQ_JOB_TANIMAIS.nextval;
        INSERT INTO job_tanimais
                        VALUES pio_animal;
        po_mensagem := 'deu bom!';
    exception
        WHEN others THEN
            po_mensagem := sqlerrm;
    END prc_insert;

    PROCEDURE prc_update ( pi_animal_id in JOB_tanimais.id%TYPE
                         , pio_animal in out JOB_tanimais%ROWTYPE
                         , po_mensagem out VARCHAR2) IS
    BEGIN

END pkg_animal;