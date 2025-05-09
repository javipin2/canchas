import mysql.connector
from mysql.connector import errorcode

# Configuración de conexión (ajusta según corresponda)
config = {
    'user': 'root',
    'password': '',  # Ingresa tu contraseña
    'host': 'localhost',
    'port': 3306,
}

DB_NAME = 'cancha_dueño'

TABLES = {}

TABLES['canchas'] = (
    "CREATE TABLE `canchas` ("
    "  `id` INT AUTO_INCREMENT PRIMARY KEY,"
    "  `nombre` VARCHAR(100) NOT NULL,"
    "  `descripcion` TEXT,"
    "  `imagen` VARCHAR(255),"
    "  `techada` BOOLEAN NOT NULL DEFAULT FALSE,"
    "  `ubicacion` VARCHAR(255),"
    "  `precio` DECIMAL(10,2),"
    "  `servicios` TEXT"
    ") ENGINE=InnoDB")

TABLES['clientes'] = (
    "CREATE TABLE `clientes` ("
    "  `id` INT AUTO_INCREMENT PRIMARY KEY,"
    "  `nombre` VARCHAR(100) NOT NULL,"
    "  `telefono` VARCHAR(50) NOT NULL,"
    "  `correo` VARCHAR(100),"
    "  UNIQUE KEY `unique_cliente` (`nombre`, `telefono`)"
    ") ENGINE=InnoDB")

TABLES['reservas'] = (
    "CREATE TABLE `reservas` ("
    "  `id` INT AUTO_INCREMENT PRIMARY KEY,"
    "  `cliente_id` INT NOT NULL,"
    "  `cancha_id` INT NOT NULL,"
    "  `fecha` DATE NOT NULL,"
    "  `hora` TIME NOT NULL,"
    "  `estado` ENUM('Pendiente', 'Pago Completo', 'Abono') DEFAULT 'Pendiente',"
    "  `valor` DECIMAL(10,2) DEFAULT 0,"
    "  `tipo_evento` ENUM('Fútbol','Cumpleaños','Torneo') DEFAULT 'Fútbol',"
    "  `sede` VARCHAR(50) DEFAULT 'Sede 1',"
    "  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
    "  FOREIGN KEY (`cliente_id`) REFERENCES `clientes`(`id`),"
    "  FOREIGN KEY (`cancha_id`) REFERENCES `canchas`(`id`)"
    ") ENGINE=InnoDB")

try:
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    
    try:
        cursor.execute(f"CREATE DATABASE {DB_NAME} DEFAULT CHARACTER SET 'utf8'")
        print(f"Base de datos {DB_NAME} creada exitosamente.")
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_DB_CREATE_EXISTS:
            print(f"La base de datos {DB_NAME} ya existe.")
        else:
            print(f"Error al crear la base de datos: {err.msg}")
            exit(1)

    cursor.execute(f"USE {DB_NAME}")

    for table_name in TABLES:
        table_description = TABLES[table_name]
        try:
            print(f"Creando tabla {table_name}... ", end='')
            cursor.execute(table_description)
        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_TABLE_EXISTS_ERROR:
                print("ya existe.")
            else:
                print(err.msg)
        else:
            print("OK")
    
    cursor.close()
    cnx.close()
except mysql.connector.Error as err:
    print(err)
