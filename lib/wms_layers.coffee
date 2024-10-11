L = require "./leaflet.js"

# AEMET API Key - Asegúrate de reemplazar "TU_API_KEY" por tu clave de API válida
apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkLmZ2aWxsYW51ZXZhQHVwbS5lcyIsImp0aSI6IjcwMGU0NDA4LWEzODktNDg3MC1hNzRlLTFhOTBiZDUxOTRlNCIsImlzcyI6IkFFTUVUIiwiaWF0IjoxNzE4Mjg1NzAwLCJ1c2VySWQiOiI3MDBlNDQwOC1hMzg5LTQ4NzAtYTc0ZS0xYTkwYmQ1MTk0ZTQiLCJyb2xlIjoiIn0.JZjhHTGBk-85Q0g260S08Qekel2LVnk3pSOGdVwBdUM"

# Función para obtener la imagen de radar nacional
fetchAEMETRadar = (callback) ->
  console.log("Fetching AEMET radar data...")  # Debug
  fetch("https://opendata.aemet.es/opendata/api/red/radar/nacional?api_key=" + apiKey)
    .then (response) ->
      if response.ok
        console.log("API request successful")  # Debug
        return response.json()
      else
        throw new Error("Error fetching API: " + response.statusText)
    .then (data) ->
      if data.datos
        console.log("Radar image URL found:", data.datos)  # Debug
        callback(data.datos)  # Pasar la URL de la imagen directamente al callback
      else
        console.error("API response does not contain 'datos' field.")
    .catch (error) -> console.error("Error fetching AEMET API:", error)

# Exporta la función
module.exports = { fetchAEMETRadar }