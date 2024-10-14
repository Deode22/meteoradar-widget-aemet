L          = require "./lib/leaflet.js"
TileLayers = require "./lib/tile_layers.coffee"
WMSLayers  = require "./lib/wms_layers.coffee"

# CUSTOMIZE THESE FOR YOUR LOCATION
latitude  = 40.395
longitude = -4.109
zoomLevel = 5.5  # Ajusta el nivel de zoom si es necesario

# CUSTOMIZE THE BASEMAP
basemap = TileLayers["openstreetmap-hot"]

# The refresh frequency in milliseconds. Radar updates every 10 minutes,
# so update map every 10 minutes too.
refreshFrequency: 10 * 60 * 1000

# No local command necessary
command: ""

render: (domEl) -> """
<link rel="stylesheet" href="canada_radar.widget/lib/leaflet.css" />
<div id="map">Loading...</div>
<div id="last-update"></div>
<button id="open-gif-button">Abrir GIF</button>
<img id="gif-display" src="http://localhost:8000/radar_animacion.gif" style="display:none;" />
"""


afterRender: (domEl) ->
  try
    console.log("Initializing map...")
    map = L.map('map', {
      zoomControl: true
    }).setView([latitude, longitude], zoomLevel)

    # Capa base del mapa
    if basemap
      basemap.addTo(map)
      console.log("Base map layer added successfully.")
    else
      console.error("No basemap found.")

"""
    # Añadir los marcadores personalizados
    console.log("Adding custom markers...")
    L.circleMarker([40.10575, -5.82441], {color: 'red', radius: 5}).addTo(map)
    L.circleMarker([40.424856875738044, -3.4849927667095733], {color: 'red', radius: 5}).addTo(map)
    L.circleMarker([40.55318143939791, -4.432384838084168], {color: 'red', radius: 5}).addTo(map)
    console.log("Markers added successfully.")
"""
    # Obtener la URL de la imagen del radar y procesarla
    WMSLayers.fetchAEMETRadar (radarImageUrl) ->
      if radarImageUrl
        console.log("Processing radar image to remove purple and black colors...")

        # Crear un nuevo objeto Image
        img = new Image()
        img.crossOrigin = "Anonymous"  # Importante para evitar problemas de CORS

        img.onload = ->
          # Crear un canvas con las mismas dimensiones que la imagen
          canvas = document.createElement('canvas')
          canvas.width = img.width
          canvas.height = img.height
          ctx = canvas.getContext('2d')

          # Dibujar la imagen en el canvas
          ctx.drawImage(img, 0, 0)

          # Obtener los datos de la imagen
          imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
          data = imageData.data

          # Función para convertir RGB a HSV
          rgbToHsv = (r, g, b) ->
            r /= 255
            g /= 255
            b /= 255

            max = Math.max(r, g, b)
            min = Math.min(r, g, b)
            h = s = v = max

            d = max - min
            s = if max == 0 then 0 else d / max

            if max == min
              h = 0  # achromatic
            else
              if max == r
                h = (g - b) / d + (if g < b then 6 else 0)
              else if max == g
                h = (b - r) / d + 2
              else if max == b
                h = (r - g) / d + 4
              h /= 6

            return [h * 360, s, v]

          # Recorrer cada píxel y establecer alfa a 0 para píxeles negros y morados
          for i in [0...data.length] by 4
            r = data[i]
            g = data[i + 1]
            b = data[i + 2]
            a = data[i + 3]

            # Para píxeles negros (donde RGB y alfa son 0)
            if r == 0 and g == 0 and b == 0
              data[i + 3] = 0  # Establecer alfa a 0 (transparente)
            else
              # Convertir RGB a HSV
              [hue, sat, val] = rgbToHsv(r, g, b)
              # Verificar si el tono está en el rango de morados y lilas (aproximadamente entre 270 y 330 grados)
              if (hue >= 270 and hue <= 330) and sat > 0.2 and val > 0.2
                data[i + 3] = 0  # Establecer alfa a 0 (transparente)

          # Poner los datos de imagen modificados de vuelta en el canvas
          ctx.putImageData(imageData, 0, 0)

          # Crear una URL de datos a partir del canvas
          processedRadarImageUrl = canvas.toDataURL()

          # Ahora añade la imagen procesada como overlay
          imageBounds = [[33, -11], [46.5, 5]]  # Ajusta las coordenadas según sea necesario
          L.imageOverlay(processedRadarImageUrl, imageBounds).addTo(map)
          console.log("Processed radar image overlay added successfully.")
        img.onerror = ->
          console.error("Error loading radar image.")
        img.src = radarImageUrl

      else
        console.error("Failed to retrieve radar image URL.")

    # Añadir evento al botón para abrir o previsualizar el GIF
    button = document.getElementById('open-gif-button')
    button.onclick = ->
      gifPath = 'http://localhost:8000/radar_animacion.gif?' + new Date().getTime()  # Forzar recarga del GIF
      console.log("Ruta al GIF:", gifPath)

      # Crear una ventana modal para mostrar el GIF
      modal = document.createElement('div')
      modal.id = 'gif-modal'
      modal.innerHTML = """
        <div id="modal-content">
          <span id="close-modal">&times;</span>
          <img src="#{gifPath}" alt="Radar GIF" id="gif-image">
        </div>
      """
      document.body.appendChild(modal)

      # Estilos para la ventana modal
      modalStyle = document.createElement('style')
      modalStyle.innerHTML = """
        #gif-modal {
          display: block;
          position: fixed;
          z-index: 1001;
          left: 0;
          top: 0;
          width: 100%;
          height: 100%;
          overflow: auto;
          background-color: rgba(0,0,0,0.8);
        }
        #modal-content {
          position: relative;
          margin: auto;
          padding: 0;
          width: 80%;
          max-width: 700px;
        }
        #close-modal {
          position: absolute;
          top: 10px;
          right: 25px;
          color: #fff;
          font-size: 35px;
          font-weight: bold;
          cursor: pointer;
        }
        #gif-image {
          margin: auto;
          display: block;
          width: 100%;
          max-width: 700px;
        }
      """
      document.head.appendChild(modalStyle)

      # Evento para cerrar la ventana modal
      closeModal = document.getElementById('close-modal')
      closeModal.onclick = ->
        document.body.removeChild(modal)
        document.head.removeChild(modalStyle)

update:(output, domEl) ->
  if @layer
    @layer.redraw()
    console.log("Layer redrawn.")  # Debug message
  else
    console.error("No radar layer available to redraw.")  # Error message
  $("#last-update").text(@timestampString(new Date()))

# Customize this for converting the Date object into a string for rendering over the map.
timestampString: (timestamp) ->
  timestamp.toTimeString()

# Edit these to change the position/size of the widget
style: """
  top: 30%
  left: 81%

  #map
    border: 1px solid white
    width: 300px
    height: 400px

  #last-update
    position: absolute
    left: 0.1em
    top: 0
    z-index: 1000
    background-color: rgba(255,255,255,0.7)
    font-family: "Helvetica Neue", sans-serif
    font-size: 8pt

  #open-gif-button
    position: absolute
    top: 10px
    right: 10px
    z-index: 1000
    padding: 5px 10px
    font-size: 10pt
    background-color: #fff
    border: 1px solid #ccc
    cursor: pointer
"""

