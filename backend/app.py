from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

db_config = {
    'host': 'gondola.proxy.rlwy.net',  # Host de Railway
    'user': 'root',  # Usuario de Railway
    'password': 'MoFLWaJIAlyWignWbYdIDCtAvIUDQMyo',  # Contraseña obtenida de Railway
    'database': 'railway',  # Nombre de la base de datos en Railway
    'port': 13868  # Puerto asignado por Railway
}

@app.route('/canchas', methods=['GET'])
def obtener_canchas():
    try:
        sede = request.args.get('sede')
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        if sede:
            query = "SELECT * FROM canchas WHERE sede = %s"
            cursor.execute(query, (sede,))
        else:
            query = "SELECT * FROM canchas"
            cursor.execute(query)
        canchas = cursor.fetchall()
        return jsonify({"canchas": canchas}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()


@app.route('/crear_reserva', methods=['POST'])
def crear_reserva():
    try:
        data = request.get_json()
        print("Datos recibidos:", data)  # Línea de depuración

        # Validar campos requeridos
        nombre = data.get('nombre')
        telefono = data.get('telefono')
        fecha = data.get('fecha')
        cancha_id = data.get('cancha')
        horario_str = data.get('horario')

        if not (nombre and telefono and fecha and cancha_id and horario_str):
            return jsonify({"error": "Faltan datos requeridos"}), 400

        # Convertir el horario de formato "8:00 am" a 24 horas
        try:
            hora_dt = datetime.strptime(horario_str, '%I:%M %p')
            hora = hora_dt.strftime('%H:%M:%S')
        except ValueError:
            return jsonify({"error": "Formato de horario inválido, usa ej. '8:00 am'"}), 400

        estado = data.get('estado', 'Pendiente')
        valor = data.get('valor', 0)
        tipo_evento = data.get('tipo_evento', 'Fútbol')
        sede = data.get('sede', 'Sede 1')

        # Ya no se busca ni se crea un cliente; se guarda el nombre directamente en la reserva.
        # Suponemos que la tabla reservas tiene una columna "nombre" para este fin.
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        query = """
            INSERT INTO reservas (nombre, cancha_id, fecha, hora, estado, valor, tipo_evento, sede)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (nombre, cancha_id, fecha, hora, estado, valor, tipo_evento, sede))
        conn.commit()

        return jsonify({"message": "Reserva creada con éxito", "id": cursor.lastrowid}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()


@app.route('/horarios_ocupados', methods=['GET'])
def horarios_ocupados():
    try:
        fecha = request.args.get('fecha')
        cancha_id = request.args.get('cancha')
        sede = request.args.get('sede', 'Sede 1')

        if not (fecha and cancha_id):
            return jsonify({"error": "Fecha y cancha son requeridos"}), 400

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        query = "SELECT hora FROM reservas WHERE fecha = %s AND cancha_id = %s AND sede = %s"
        cursor.execute(query, (fecha, cancha_id, sede))
        reservas = cursor.fetchall()

        # Convertir cada hora a formato "8:00 am"
        horarios_ocupados = []
        for (hora_str,) in reservas:
            try:
                hora_dt = datetime.strptime(str(hora_str), '%H:%M:%S')
                hora_formateada = hora_dt.strftime('%I:%M %p').lstrip("0")
                horarios_ocupados.append(hora_formateada)
            except Exception:
                continue

        return jsonify({"horarios_ocupados": horarios_ocupados}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
