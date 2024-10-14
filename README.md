# Widget de Radar Meteorológico con Datos de AEMet (Übersicht)

---

<div align="center">
  <img src="https://raw.githubusercontent.com/Deode22/meteoradar-widget-aemet/main/radar_animacion.gif" alt="Radar Animación" width="300">
</div>

>[!IMPORTANT]
>## Agradecimientos:
>Este widget es la edición, ampliación y adaptación del trabajo del usuario [openfirmware](https://github.com/openfirmware) con su repositorio [canada_radar.widget](https://github.com/openfirmware/canada_radar.widget)

## El widget

Este widget muestra datos en tiempo real del radar meteorológico proporcionados por la Agencia Estatal de Meteorología (AEMet). Permite visualizar fenómenos atmosféricos como lluvias, tormentas y nevadas en un mapa interactivo.

### Características

- **Datos en tiempo real**: Actualizaciones constantes de información meteorológica.
- **Interfaz interactiva**: Mapa navegable y opciones personalizables.

### Requisitos

- **API Key de AEMet**: Necesaria para acceder a los datos del radar. Siguiendo este enlace puedes solicitar la tuya: [link](https://opendata.aemet.es/centrodedescargas/altaUsuario?)
    - ¡LA TIENES QUE INTEGRAR EN `index.cofee` y `./lib/wms_layers`!
- **Conexión a Internet**: Para obtener y actualizar los datos meteorológicos.

## Instalación

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/Deode22/meteoradar-widget-aemet.git
   ```
Y descomprimir.

2. **Mover la carpeta a ~/Übersicht/widgets**

3. Personaliza posición y tamaño en `index.coffee`:

```coffee

style: """
  top: 30%   # Posición en la ventana
  left: 81%

  #map
    border: 1px solid white
    width: 300px               # Tamaño del mapa
    height: 400px

[…]
"""
```
4. Crea un servidor en segundo plano para el display del GIF:

Abre terminal en **tu carpeta de widgets** y ejecuta:

```bash
nohup python3 -m http.server 8000
```

>[!WARNING]
> Si se apaga el ordenador se apaga el servidor. Puedes iniciarlo cuando lo necesites o mandar ejecutar esa linea de código con cada inicio.

---

## A tener en cuenta...

> La imagen de radar está dimensionada para el centro de la península. Las zonas norte y sur están descuadradas, en especial Galicia y Baleares.
> 
> Existen puntos de lugares de interés, zonas donde quieras monitorear más las precipitaciones.

---

## Archivo de recopilación de datos (pyhton)

Los datos de AEMet se recogen mediante el script de python [radar_fetch.py](https://github.com/Deode22/meteoradar-widget-aemet/blob/main/radar_fetch.py), el cual debería de ejecutarse de manera periódica. 

Para lograr mantener los datos actualizados, podemos automatizar la ejecución con `crontab`: 

```bash
brew install crontab
```

```bash
crontab -e
```

Para que se ejecute cada 30 minutos: 

```bash
*/30 * * * * ruta/a/python ruta/a/radar_fetch.py
```

> [!CAUTION]
> Ten cuidado desde donde lo intentas ejecutar. MacOS bloquea las automatizaciones de terceros si está en una carpeta sensible como 'Documentos' o 'Escritorio'. 


## Capturas de Pantalla


| <img src="https://github.com/Deode22/meteoradar-widget-aemet/raw/main/capturaspantalla/Captura%20de%20pantalla%202024-10-11%20a%20las%2016.14.33%20(2).png" width="320"> | <img src="https://github.com/Deode22/meteoradar-widget-aemet/raw/main/capturaspantalla/Captura%20de%20pantalla%202024-10-11%20a%20las%2016.14.58%20(2).png" width="320"> | <img src="https://github.com/Deode22/meteoradar-widget-aemet/raw/main/capturaspantalla/Captura%20de%20pantalla%202024-10-11%20a%20las%2016.15.23.png" width="320"> |
|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------:|
| **Escritorio**                                                                                             | **GIF**                                                                                             | **Zoom**                                                                                             |



## Contribución

¡Las contribuciones son bienvenidas!

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

>[!NOTE]
>*Este proyecto no está afiliado ni respaldado por la Agencia Estatal de Meteorología (AEMet). Los datos se utilizan conforme a las políticas y términos de uso de AEMet.*
