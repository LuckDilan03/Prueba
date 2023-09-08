DROP TABLE IF EXISTS tab_reserva;
DROP TABLE IF EXISTS tab_timereal;
DROP TABLE IF EXISTS tab_coment;
DROP TABLE IF EXISTS tab_clien;
DROP TABLE IF EXISTS tab_parq;
DROP TABLE IF EXISTS tab_geren;
DROP TABLE IF EXISTS tab_login;
DROP TABLE IF EXISTS tab_vehi;
DROP TABLE IF EXISTS tab_precioxhora;
DROP TABLE IF EXISTS tab_mensualidad;



-- Tabla para el registro del usuario

CREATE TABLE tab_login (
    id_login    	    INT 	NOT NULL,
    correo              VARCHAR NOT NULL,
    contra              VARCHAR NOT NULL,
    telefono            VARCHAR NOT NULL,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP, 
PRIMARY KEY(id_login)
);

-- Tabla para el registro de vehiculo

CREATE TABLE tab_vehi (
	placa               VARCHAR NOT NULL,
    modelo              VARCHAR,
    marca               VARCHAR NOT NULL,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP, 
PRIMARY KEY (placa)
);

--Tabla de precio x vehiculo

CREATE TABLE tab_precioxhora(
    id_precioxhora      INT,
    precio_carro        INT,
    precio_moto         INT,
    precio_bici         INT,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP,
PRIMARY KEY(id_precioxhora)
);


--Tabla para precio * mes

CREATE TABLE tab_mensualidad(
    id_mensualidad      INT,
    mens_carro          INT,
    mens_moto           INT,
    mens_bici           INT,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP, 
PRIMARY KEY (id_mensualidad)
);

-- Tabla Para Cliente

CREATE TABLE tab_clien (
    DNI                 VARCHAR NOT NULL,
    Nombre              VARCHAR NOT NULL, 
    placa          	    VARCHAR NOT NULL, 
    id_login            INT,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP, 
PRIMARY KEY (DNI),
FOREIGN KEY (placa) REFERENCES tab_vehi(placa),
FOREIGN KEY (id_login) REFERENCES tab_login(id_login)
);

-- Tabla para Gerentes

CREATE TABLE tab_geren (
    id_geren        INT		NOT NULL,
    nombre          VARCHAR NOT NULL,
    id_reg int,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP, 
PRIMARY KEY (id_geren),
FOREIGN KEY (id_login) REFERENCES tab_login(id_login)
);

-- Tabla para Parqueaderos

CREATE TABLE tab_parq (
	NIT         	    VARCHAR NOT NULL,
    Nombre              VARCHAR,
    Direccion           VARCHAR NOT NULL,
    HorarioAtencion     VARCHAR NOT NULL,
	indicador_moto	    BOOLEAN,
    CapacidadTotal      INT		NOT NULL,
	id_precioxhora	    INT,
    id_mensualidad      INT,
    id_geren            INT,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP,    
PRIMARY KEY (NIT),	
FOREIGN KEY (id_precioxhora) REFERENCES tab_prvh(id_precioxhora),	
FOREIGN KEY (id_geren) REFERENCES tab_geren(id_geren),
FOREIGN KEY (id_mensualidad) REFERENCES tab_prms(id_mensualidad)
);

-- Tabla para Reservas

CREATE TABLE tab_reserva (
    id_reserva          INT		  NOT NULL,
    fecha_inicio        TIMESTAMP NOT NULL,
    fecha_fin           TIMESTAMP NOT NULL,
    DNI                 VARCHAR	  NOT NULL,
    id_parq             INT		  NOT NULL,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP,    
PRIMARY KEY (id_reserva ),
FOREIGN KEY (DNI) REFERENCES tab_clien(DNI),
FOREIGN KEY (id_parq) REFERENCES tab_parq(id_parq)
);

-- Tabla para Puestos en Tiempo Real

CREATE TABLE tab_timereal (
    id_puesto           INT		NOT NULL,
    id_parq             INT,
    ocupado             BOOLEAN,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP,
PRIMARY KEY(id_puesto),
FOREIGN KEY (id_parq) REFERENCES tab_parq(id_parq)
);

-- Tabla para Comentarios
CREATE TABLE tab_coment (
    id_comentario       INT PRIMARY KEY,
    Comentario          TEXT,
    Calificacion        INT,
    DNI                 VARCHAR ,
    id_parq             INT,
    fecha_update        TIMESTAMP,
    usuario_update      VARCHAR,
    usuario_insert      VARCHAR,
    fecha_insert        TIMESTAMP,
PRIMARY KEY (id_comentario)
FOREIGN KEY (DNI) REFERENCES tab_clien(DNI),
FOREIGN KEY (id_parq) REFERENCES tab_parq(id_parq)
);

-- Tabla de Auditoría para tab_login

CREATE TABLE tab_borrados
( 
    id_consec       			INTEGER     	NOT NULL, -- Codígo de la tabla Borrados (Llave Primaria) 
    nombre_tabla       			VARCHAR     	NOT NULL, -- 
    usuario_insert      		VARCHAR     	NOT NULL    DEFAULT CURRENT_USER, 
    fecha_insert      			TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    PRIMARY KEY(id_consec) 
); 




-- Función de auditoría adaptada
CREATE OR REPLACE FUNCTION fun_act_tabla() RETURNS "trigger" AS 
$$ 
    
	DECLARE id_consec tab_borrados.id_consec%TYPE; 
    BEGIN 
        IF TG_OP = 'INSERT' THEN 
           NEW.Usuario_Inserta = CURRENT_USER; 
           NEW.Fecha_Inserta = CURRENT_TIMESTAMP; 
           RETURN NEW; 
        END IF; 
        IF TG_OP = 'UPDATE' THEN 
           NEW.Usuario_Update = CURRENT_USER; 
           NEW.Fecha_Update = CURRENT_TIMESTAMP; 
           RETURN NEW; 
        END IF; 
        IF TG_OP = 'DELETE' THEN 
            SELECT MAX(a.id_consec) INTO id_consec FROM tab_borrados a; 
            IF id_consec IS NULL THEN 
                id_consec = 1; 
            ELSE 
                id_consec = id_consec + 1; 
            END IF; 
            INSERT INTO tab_borrados VALUES(id_consec,TG_RELNAME,CURRENT_USER,CURRENT_TIMESTAMP); 
            RETURN OLD;  
        END IF; 
    END; 
$$ 
LANGUAGE PLPGSQL; 


-- Desencadenadores para tablas específicas

-- Ejemplo para la tabla tab_ciudades
CREATE OR REPLACE TRIGGER tri_del_tabla_login AFTER DELETE ON tab_login
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_login BEFORE INSERT OR UPDATE ON tab_login
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_vehi AFTER DELETE ON tab_vehi
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_vehi BEFORE INSERT OR UPDATE ON tab_vehi
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_precioxhora AFTER DELETE ON tab_precioxhora
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_precioxhora BEFORE INSERT OR UPDATE ON tab_precioxhora
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_mensualida AFTER DELETE ON tab_mensualida
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_mensualida BEFORE INSERT OR UPDATE ON tab_mensualida
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_clien AFTER DELETE ON tab_clien
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_clien BEFORE INSERT OR UPDATE ON tab_clien
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_geren AFTER DELETE ON tab_geren
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_geren BEFORE INSERT OR UPDATE ON tab_geren
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_parq AFTER DELETE ON tab_parq
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_parq BEFORE INSERT OR UPDATE ON tab_parq
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_reserva AFTER DELETE ON tab_reserva
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_reserva BEFORE INSERT OR UPDATE ON tab_reserva
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_timereal AFTER DELETE ON tab_timereal
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_timereal BEFORE INSERT OR UPDATE ON tab_timereal
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla_coment AFTER DELETE ON tab_coment
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla_coment BEFORE INSERT OR UPDATE ON tab_coment
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

-- Repite el proceso para otras tablas según sea necesario









-- DROP TABLE IF EXISTS tab_admin;
-- Tabla para Administrador
-- CREATE TABLE tab_admin (
--     id_admi         int primary key,
--     Nombre          VARCHAR NOT NULL
-- );


-- DROP TABLE IF EXISTS tab_prhr;
-- --Tabla para precio x hora
-- CREATE TABLE tab_prhr(
-- id_prhr INT PRIMARY KEY,
-- cant_horas INT,
-- total_precio_hora DECIMAL,
-- id_prvh INT,
-- FOREIGN KEY (id_prvh) REFERENCES tab_prvh(id_prvh)
-- );
