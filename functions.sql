----------Exercicios Apostila 12----------
--1.1
DROP FUNCTION IF EXISTS fn_consultar_saldo;
CREATE OR REPLACE FUNCTION fn_consultar_saldo (
IN p_cod_cliente INT,
IN p_cod_conta INT) 
RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
v_saldo NUMERIC(10, 2);
BEGIN
SELECT saldo INTO v_saldo 
FROM tb_conta 
WHERE cod_cliente = p_cod_cliente 
AND cod_conta = p_cod_conta;
RETURN v_saldo;
END;
$$;

--1.2
DROP FUNCTION IF EXISTS fn_transferir;
CREATE OR REPLACE FUNCTION fn_transferir (
IN p_cod_cliente_remetente INT,
IN p_cod_conta_remetente INT,
IN p_cod_cliente_destinatario INT,
IN p_cod_conta_destinatario INT,
IN p_valor_transferencia NUMERIC(10, 2)) 
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
v_saldo_remetente NUMERIC(10, 2);
v_saldo_destinatario NUMERIC(10, 2);
BEGIN
SELECT saldo INTO v_saldo_remetente 
FROM tb_conta 
WHERE cod_cliente = p_cod_cliente_remetente 
AND cod_conta = p_cod_conta_remetente
FOR UPDATE;
SELECT saldo INTO v_saldo_destinatario
FROM tb_conta 
WHERE cod_cliente = p_cod_cliente_destinatario 
AND cod_conta = p_cod_conta_destinatario
FOR UPDATE; 

IF v_saldo_remetente < p_valor_transferencia THEN
RETURN FALSE;
END IF;
    
BEGIN
UPDATE tb_conta 
SET saldo = saldo - p_valor_transferencia 
WHERE cod_cliente = p_cod_cliente_remetente 
AND cod_conta = p_cod_conta_remetente;
UPDATE tb_conta 
SET saldo = saldo + p_valor_transferencia 
WHERE cod_cliente = p_cod_cliente_destinatario 
AND cod_conta = p_cod_conta_destinatario;
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
RETURN FALSE;
END;
END;
$$;


--1.3
--fn_consultar_saldo
DO $$
DECLARE
    v_cod_cliente INT := 2;
    v_cod_conta INT := 2;
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT fn_consultar_saldo(v_cod_cliente, v_cod_conta) INTO v_saldo;
    RAISE NOTICE 'O saldo da conta é: %', v_saldo;
END;
$$;

--fn_transferir
DO $$
DECLARE
    v_cod_cliente_remetente INT := 2;
    v_cod_conta_remetente INT := 2;
    v_cod_cliente_destinatario INT := 1;
    v_cod_conta_destinatario INT := 1;
    v_valor_transferencia NUMERIC(10, 2) := 100;
    v_transferencia_ok BOOLEAN;
BEGIN
    SELECT fn_transferir(v_cod_cliente_remetente, v_cod_conta_remetente, 
                         v_cod_cliente_destinatario, v_cod_conta_destinatario, 
                         v_valor_transferencia)
    INTO v_transferencia_ok;
    
    IF v_transferencia_ok THEN
        RAISE NOTICE 'Transferência de R$%s realizada com sucesso.', v_valor_transferencia;
    ELSE
        RAISE NOTICE 'Não foi possível realizar a transferência de R$%s.', v_valor_transferencia;
    END IF;
END;
$$;


