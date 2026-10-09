# ══════════════════════════════════════════════════════════
#  Compila el sitio y lo deja en la carpeta ../sitio
#  Uso (desde esta carpeta):   .\compilar.ps1
#  Después se hace commit y push de la carpeta sitio/ y Netlify
#  la publica sola. Las fotos y el panel NO necesitan esto:
#  se actualizan sin compilar.
# ══════════════════════════════════════════════════════════
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter build web --release --wasm --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { throw 'La compilación falló' }

$destino = Join-Path $PSScriptRoot '..\sitio'
if (Test-Path $destino) { Remove-Item -Recurse -Force $destino }
New-Item -ItemType Directory $destino | Out-Null

# canvaskit/ no se copia: el navegador lo baja del CDN de Google
# (pesa ~60 MB y no hace falta tenerlo en el repositorio)
Get-ChildItem 'build\web' -Force |
  Where-Object { $_.Name -notin @('canvaskit', '.last_build_id') } |
  Copy-Item -Destination $destino -Recurse -Force
Write-Host "Listo: sitio compilado en $destino"
