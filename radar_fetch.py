import requests
import os
import json
from datetime import datetime
import imageio

# Reemplaza 'TU_API_KEY' con tu clave real de API de AEMET
API_KEY = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkLmZ2aWxsYW51ZXZhQHVwbS5lcyIsImp0aSI6IjcwMGU0NDA4LWEzODktNDg3MC1hNzRlLTFhOTBiZDUxOTRlNCIsImlzcyI6IkFFTUVUIiwiaWF0IjoxNzE4Mjg1NzAwLCJ1c2VySWQiOiI3MDBlNDQwOC1hMzg5LTQ4NzAtYTc0ZS0xYTkwYmQ1MTk0ZTQiLCJyb2xlIjoiIn0.JZjhHTGBk-85Q0g260S08Qekel2LVnk3pSOGdVwBdUM'

# Directorio donde se guardarán las imágenes
DIRECTORIO_IMAGENES = '/Users/danielfernandezvillanueva/Library/Application Support/Übersicht/widgets/canada_radar.widget/imagenes_radar'

# Número máximo de imágenes a mantener
MAX_IMAGENES = 60

# Nombre del archivo GIF de salida
NOMBRE_GIF = '/Users/danielfernandezvillanueva/Library/Application Support/Übersicht/widgets/canada_radar.widget/radar_animacion.gif'

def descargar_imagen_radar():
    # Paso 1: Obtener el JSON desde la API
    url_api = f'https://opendata.aemet.es/opendata/api/red/radar/nacional?api_key={API_KEY}'
    respuesta = requests.get(url_api)
    if respuesta.status_code != 200:
        print(f'Error al obtener datos de la API: {respuesta.status_code}')
        return

    datos = respuesta.json()
    if 'datos' not in datos:
        print('No se encontró el campo "datos" en la respuesta de la API')
        return

    # Paso 2: Obtener la URL de la imagen desde "datos"
    url_imagen = datos['datos']

    # Paso 3: Descargar la imagen
    respuesta_imagen = requests.get(url_imagen)
    if respuesta_imagen.status_code != 200:
        print(f'Error al descargar la imagen: {respuesta_imagen.status_code}')
        return

    # Paso 4: Guardar la imagen con un nombre basado en la marca de tiempo
    if not os.path.exists(DIRECTORIO_IMAGENES):
        os.makedirs(DIRECTORIO_IMAGENES)

    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    nombre_imagen = os.path.join(DIRECTORIO_IMAGENES, f'radar_{timestamp}.png')

    with open(nombre_imagen, 'wb') as f:
        f.write(respuesta_imagen.content)
    print(f'Imagen guardada: {nombre_imagen}')

def eliminar_imagenes_antiguas():
    # Paso 5: Mantener solo las últimas MAX_IMAGENES imágenes
    archivos = sorted(os.listdir(DIRECTORIO_IMAGENES))
    while len(archivos) > MAX_IMAGENES:
        archivo_antiguo = archivos.pop(0)
        os.remove(os.path.join(DIRECTORIO_IMAGENES, archivo_antiguo))
        print(f'Imagen antigua eliminada: {archivo_antiguo}')

def crear_gif():
    # Paso 6: Crear un GIF a partir de las imágenes
    imagenes = []
    archivos = sorted(os.listdir(DIRECTORIO_IMAGENES))
    
    # Filtrar solo los archivos que sean imágenes (por ejemplo, archivos que terminen en .png)
    archivos_imagenes = [archivo for archivo in archivos if archivo.endswith('.png')]
    
    for nombre_archivo in archivos_imagenes:
        ruta_archivo = os.path.join(DIRECTORIO_IMAGENES, nombre_archivo)
        imagenes.append(imageio.imread(ruta_archivo))

    if imagenes:
        imageio.mimsave(NOMBRE_GIF, imagenes, fps=2)
        print(f'GIF creado: {NOMBRE_GIF}')
    else:
        print('No hay imágenes para crear el GIF')

def main():
    descargar_imagen_radar()
    eliminar_imagenes_antiguas()
    crear_gif()

if __name__ == '__main__':
    main()