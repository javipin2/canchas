# Usa una imagen de Flutter ya preparada (ajusta la versión según convenga)
FROM cirrusci/flutter:latest

# Establece el directorio de trabajo
WORKDIR /app

# Copia el pubspec del proyecto al contenedor
COPY pubspec.yaml /app/pubspec.yaml

# Ejecuta flutter pub get para resolver las dependencias
RUN flutter pub get

# Copia todo el código fuente en el contenedor
COPY . /app

# Opcional: ejecuta flutter doctor para verificar el entorno
RUN flutter doctor

# Comando de arranque o compilación (ajusta a tu flujo de trabajo)
CMD ["flutter", "run"]
