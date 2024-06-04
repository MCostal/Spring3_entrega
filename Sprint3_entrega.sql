## Nivel 1

-- Ejercicio 1
-- Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales 
-- sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar de manera única cada 
-- tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
-- Después de crear la tabla será necesario que ingreses la información del documento denominado 
-- "dades_introduir_credit". Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

USE transactions;

-- Creamos la tabla credit_card 
CREATE TABLE IF NOT EXISTS credit_card  (
		id VARCHAR(20) NOT NULL PRIMARY KEY,
		iban VARCHAR(50) NOT NULL,
        pan VARCHAR(25) NOT NULL,
        pin VARCHAR(4) NOT NULL,
        cvv INT NOT NULL,
        expiring_date VARCHAR(10) NOT NULL      
		);

 SHOW TABLES;     
 SELECT * FROM credit_card;

-- me sale un aviso si le pongo un parámetro de longitud a los valores INTEGER --

-- Hay que definir la llave foranea en la tabla transaction que relaciona con la tabla credit_car.
-- Con el comando DESC (descripción), se puede ver que en el campo Key aparece la descipción MUL (multiple).

DESC transaction;

ALTER TABLE transaction ADD CONSTRAINT credit_card_id
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

DESC transaction;

ALTER TABLE transaction MODIFY credit_card_id VARCHAR(15) NOT NULL;
ALTER TABLE transaction MODIFY company_id VARCHAR(20) NOT NULL; 

-- Bajo mi criterio, al tratarse de claves foraneas: credit_card_id y company_id, 
-- he decido modificar sus parámetros a NOT NULL.
-- Por último, comentar que en las restricciones he decidido que sean en CASCADE. Si eliminamos
-- el registro en la tabla principal, se eliminarán todos los registros relacionados en la tabla
-- donde se encuentra la clave foránea.




-- Ejercicio 2
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario 
-- con ID CcU-2938. La información que debe mostrarse para este registro es: 
-- R323456312213576817699999. Recuerda mostrar que el cambio se realizó.

SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Primero se busca el registro indicado en el enunciado con Id = CcU-2938.
-- Se pasa a modificar el valor del iban para ese registro. Clickamos sobre el valor del campo, cambiamos el valor y
-- y aplicamos los cambios (botón Apply).
-- La linea de comandos es: 

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- Comprobar que se ha hecho el cambio correctamente.
SELECT * 
FROM credit_card
WHERE iban = 'R323456312213576817699999';


-- Ejercicio 3
-- En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:
/* Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	
*/

-- Primero buscamos los valores de las FOREIGN KEY en las tablas correspondientes.

SELECT * FROM company;
SELECT * FROM credit_card;
SELECT * FROM transaction;

SELECT * FROM credit_card
WHERE id =	'CcU-9999';

-- Para mi, para poder añadir una transacción, primero se debe dar de alta la company en la BBDD,
-- al igual que los datos de la credit_card. Por un tema de consistencia de la BBDD, se aplican CONSTRAINT.
-- (Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails)

-- En la práctica, la consulta seria la siguiente;

DESC transaction;
SELECT * FROM transaction;

-- Aunque no se debería hacer para conservar la consistencia de nuestra base de datos. 
-- Se va a introducir el resgistro desactivando las FOREIGN KEY, con la siguiente instrucción.

SET FOREIGN_KEY_CHECKS = 0;

-- Insertamos el registro

INSERT INTO transaction (id, credit_card_id, company_id, user_id, 
                        lat, longitude, timestamp, amount, declined
                        ) 
                        VALUES (        
                        '108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 
                        '829.999','-117.999', '2024-05-31 10:39:00', '111.11', '0');

-- Comprobamos que se ha creado exitosamente.

SELECT * FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Activamos las FOREIGN KEY de nuevo.

SET FOREIGN_KEY_CHECKS = 1;

-- Ejercicio 4
-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. 
-- Recuerda mostrar el cambio realizado.

DESC credit_card;

ALTER TABLE credit_card DROP COLUMN pan;
DESC credit_card;



## Nivel 2

-- Ejercicio 1
-- Elimina de la tabla transaction el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de 
-- la base de datos.


-- Primero, comprobamos que está el registro
SELECT * FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Segundo lo eliminamos.
DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Tercero volvemos a comprobar que ya no existe.
SELECT * FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
-- No se obtiene ningún resultado con ese valor de filtro. La eliminación del registro 
-- se ha realizado con éxito.


-- Ejercicio 2
-- La sección de marketing desea tener acceso a información específica para realizar análisis y 
-- estrategias efectivas. Se ha solicitado crear una vista que proporcione detalles clave sobre 
-- las compañías y sus transacciones. Será necesaria que crees una vista llamada VistaMarketing 
-- que contenga la siguiente información: Nombre de la compañía, Teléfono de contacto, 
-- País de residencia. Promedio de compra realizado por cada compañía. 
-- Presenta la vista creada, ordenando los datos de mayor a menor.

SELECT * FROM transaction;
SELECT * FROM credit_card;
SELECT * FROM company;

-- Los datos seleccionados se consiguen através de la siguiente consulta.
CREATE VIEW vistaMarketing AS
SELECT company.company_name, company.phone, company.country, avg(transaction.amount) as media
FROM company
INNER JOIN transaction
ON transaction.company_id = company.id
GROUP BY company.id
ORDER BY media DESC;


-- Ejercicio 3
-- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de 
-- residencia en "Germany"

SELECT * FROM vistaMarketing
WHERE country = 'Germany';

-- En este caso, para filtrar por País se utiliza la vista 'VistaMarketing' que funciona 
-- una tabla nueva de nuestra BBDD.



## Nivel 3
-- Ejercicio 1
-- La semana próxima tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu 
-- equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó. Te pide 
-- que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama.

-- Primero, creamos la tabla data_user y añadimos todos los datos, ejecutando los 
-- archivos facilitados.

-- Creamos la tabla user


CREATE INDEX idx_user_id ON transaction(user_id);

CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );
-- Cargamos los datos de la tabla apartir del archivo datos_introducir_user.
-- Listamos los datos de la tabla para comprobar que se han cargado.

SELECT * FROM user;

-- Se debe definir la relación entre tablas en la tabla transaction, para que aparezca
-- como FOREIGN KEY.
-- Primero elimino la FOREIGN KEY que hay en la tabla user, ya que no tiene sentido.
ALTER TABLE user DROP FOREIGN KEY user_ibfk_1;

-- Segundo, se crea la FOREIGN KEY en la tabla transaction

ALTER TABLE transaction ADD CONSTRAINT user_id
FOREIGN KEY (user_id) REFERENCES user(id) 
ON DELETE RESTRICT
ON UPDATE RESTRICT;


-- 1) Añadimos a la tabla Credit-Card la columna fecha_actual DATE

ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;
DESC credit_card;

-- 2) Cambiamos el nombre de la tabla USER por DATA USER.user

SHOW TABLES;

RENAME TABLE user to data_user;
SHOW TABLES;


-- 3) Elimino de la tabla company la comuna website.

ALTER TABLE company DROP COLUMN website;
DESC company;



-- Ejercicio 2
-- La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga 
-- la siguiente información:

-- ID de la transacción
-- Nombre del usuario/a
-- Apellido del usuario/a
-- IBAN de la tarjeta de crédito usada.
-- Nombre de la compañía de la transacción realizada.
-- Asegúrate de incluir información relevante de ambas tablas y utiliza alias para cambiar de 
-- nombre columnas según sea necesario.

-- Creamos la vista con el asistente del menú contectual Create View.

CREATE VIEW InformeTecnico AS
SELECT 	transaction.id AS NumTransaccion,
		data_user.name AS NombreCliente,
        data_user.surname AS ApellidoCliente, 
        credit_card.iban AS Iban,  
        company.company_name AS empresa
FROM transaction
JOIN company
ON company.id = transaction.company_id
JOIN data_user
ON data_user. id = transaction. user_id
JOIN credit_card
ON credit_card.id = transaction.credit_card_id;
