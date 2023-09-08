 --INSERT INTO tab_prod VALUES(1,'Producto 1','Ref. 1',1000,0,300,800,500,1,'2023-01-01','2023-12-31');
--SELECT * FROM tab_prod
--ORDER BY id_prod;

--SELECT * FROM tab_kardex;

--UPDATE tab_prod set  val_stock=0,val_cosprom=1000;
--SELECT fun_kardex('E',1,300,700,'Algo...');
--Use DROP FUNCTION fun_kardex(character varying,integer,integer,integer,text);
--DROP FUNCTION fun_contador();

CREATE OR REPLACE FUNCTION autoincrementable()RETURNS INTEGER AS
$$
DECLARE num INTEGER;
BEGIN
SELECT MAX(val_consec) INTO num FROM tab_kardex;
   IF num  IS NULL OR num = 0 THEN
   num=1;
   RETURN num;
   ELSE
   num=num+1;
   RETURN num;
   END IF;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION fun_kardex(wind_tipomov tab_kardex.ind_tipomov%TYPE,wid_prod tab_prod.id_prod%TYPE,
                                      wval_prod tab_kardex.val_prod%TYPE,wcant_prod tab_kardex.cant_prod%TYPE,
                                      wval_observa tab_kardex.val_observa%TYPE) RETURNS VARCHAR AS
$$
    DECLARE wreg_prod   RECORD;
    DECLARE wval_real   tab_prod.val_stock%TYPE;
    DECLARE autoincrementable tab_kardex.val_consec%TYPE;
    DECLARE suma INTEGER;
    DECLARE resta INTEGER;
    DECLARE sum_cost_prom BIGINT;
    DECLARE promedio_total BIGINT;
    
    
    
    BEGIN
        IF wind_tipomov <> 'E'  AND
           wind_tipomov <> 'S'  OR
           wind_tipomov IS NULL THEN
           RAISE NOTICE 'Vuelva a hacerlo';
           RETURN 'CRASH TIPO DE NOVEDAD';
        END IF;
        IF wid_Prod IS NULL OR
           wid_prod <= 0 THEN
           RAISE NOTICE 'Escriba algo en el id_producto que sirva pingo... Vuelva a hacerlo';
           RETURN 'crash id del producto';
        END IF;
        IF wval_prod IS NULL     OR
           wval_prod <= 0        OR
           wval_prod > 100000000 THEN
           RAISE NOTICE  'Vuelva a hacerlo';
           RETURN 'Me salí de esta vaina en el valor del producto';
        END IF;
        IF wcant_prod IS NULL OR
           wcant_prod <= 0    OR
           wcant_prod > 100000000  THEN
           RAISE NOTICE 'Escriba algo en cantidad de producto que sirva pingo... Vuelva a hacerlo';
           RETURN 'Me salí de esta vaina en cantidad de producto';
        END IF;
--           RAISE NOTICE 'Acá sigue el desarrollo porque vamos bien, como dijo el borracho';
           --RETURN 'Vamos bien...';



-- ACÁ EMPIEZA LA VALIDACIÓN DEL KARDEX PARA INSERTAR
        SELECT a.id_prod,a.val_cosprom,a.val_stock,a.val_stockmin,a.val_stockmax,a.ind_estado INTO wreg_prod FROM tab_prod a
        WHERE a.id_prod = wid_prod AND
              a.ind_estado = TRUE;
         IF FOUND THEN

         suma=wreg_prod.val_stock + wcant_prod;
         resta=wreg_prod.val_stock - wcant_prod;
		 
            CASE wind_tipomov
               WHEN 'E' THEN
                  
                  IF suma >= wreg_prod.val_stockmin 
                     THEN
                     
                     
                     RAISE NOTICE 'El producto cumple y habrá que INSERTARLO.';
                     SELECT autoincrementable ()INTO autoincrementable;
                     wval_real=wcant_prod*wval_prod;
                     INSERT INTO tab_kardex VALUES(autoincrementable,CURRENT_TIMESTAMP,wind_tipomov,wid_Prod,wval_prod,wcant_prod,wval_real,wval_observa);
                     if FOUND THEN 
                        SELECT SUM (val_prod) into sum_cost_prom from tab_kardex
                        WHERE id_prod=wid_Prod;
                        promedio_total=sum_cost_prom/suma;
                        UPDATE tab_prod SET val_cosprom = promedio_total,val_stock=suma
                        WHERE id_prod = wid_prod;
                        RETURN 'Funciona bien';
						   END IF;
                  ELSE 
                     RAISE NOTICE 'EL PRODUCTO ESTA POR DEBAJO DEL STOCK MINIMO NO SE INGRESA';
                     RETURN 'NO FUNCIONA';
                  
                  END IF;

                  IF suma <= wreg_prod.val_stockmax THEN
                     
                     RAISE NOTICE 'El producto cumple y habrá que INSERTARLO.';
                     SELECT autoincrementable ()INTO autoincrementable;
                     wval_real=wcant_prod*wval_prod;
                     INSERT INTO tab_kardex VALUES(autoincrementable,CURRENT_TIMESTAMP,wind_tipomov,wid_Prod,wval_prod,wcant_prod,wval_real,wval_observa);
                     if FOUND THEN 
                        SELECT SUM (val_prod) into sum_cost_prom from tab_kardex
                        WHERE id_prod=wid_Prod;
                        promedio_total=sum_cost_prom/suma;
                        UPDATE tab_prod SET val_cosprom = promedio_total,val_stock=suma
                        WHERE id_prod = wid_prod;
                        RETURN 'Funciona bien';
                     END IF;
                  ELSE 
                  RAISE NOTICE 'EL STOCK ESTA POR ENSIMA DEL STOCK MAXIMO';
                  RETURN 'NO FUNCIONA';
                  END IF;
               WHEN 'S' THEN
                  
                  IF wreg_prod.val_stock < wcant_prod THEN
                     RAISE NOTICE 'No es posible hacer Salida porque existencia < que valor a SACAR';
                     RETURN 'Me totié en Salida porque está en CERO';
                  ELSE
                     IF wreg_prod.val_stockmin < resta THEN
                        RAISE NOTICE 'Transacción cumple pero tenga en cuenta que debe pedir más... Es menor que Mínimo. Se INSERTA';
                        SELECT autoincrementable ()INTO autoincrementable;
                     wval_real=wcant_prod*wval_prod;
                     INSERT INTO tab_kardex VALUES(autoincrementable,CURRENT_TIMESTAMP,wind_tipomov,wid_Prod,wval_prod,wcant_prod,wval_real,wval_observa);
                     IF FOUND THEN 
                        UPDATE tab_prod SET val_stock=suma
                        WHERE id_prod = wid_prod;
                        RETURN 'Funcionó bien';
                     ELSE
                        RAISE NOTICE 'Transacción cumple y se descontará wcant del stock del producto. Se INSERTA';
                        RETURN 'Funcionó bien';
                     END IF;
					 END IF;
                  END IF;
            END CASE;
        ELSE
            RAISE NOTICE 'El producto no existe... Haga las vainas bien';
            RETURN 'Vamos Pailas en el producto...';
        END IF;
    END;
$$
LANGUAGE PLPGSQL;




--   id_prod         INTEGER     NOT NULL,
--nom_prod        VARCHAR     NOT NULL    CHECK(LENGTH(nom_prod >= 20)),
--    ref_prod        VARCHAR     NOT NULL,
--    val_cosprom     INTEGER     NOT NULL    CHECK(val_cosprom >=0),
--    val_stock       INTEGER     NOT NULL,
--    val_stockmin    INTEGER     NOT NULL,
--    val_stockmax    INTEGER     NOT NULL,
--    val_reorden     INTEGER     NOT NULL,
--    id_marca        INTEGER     NOT NULL,
--    fec_compra      DATE        NOT NULL,
--    fec_vence       DATE        NOT NULL,
--    ind_estado      BOOLEAN     NOT NULL 




