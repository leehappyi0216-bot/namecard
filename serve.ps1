# 로컬 미리보기 서버: powershell -File serve.ps1  →  http://localhost:8765/
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$l = New-Object System.Net.HttpListener; $l.Prefixes.Add("http://localhost:8765/"); $l.Start()
$types = @{ ".html"="text/html; charset=utf-8"; ".svg"="image/svg+xml"; ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".webp"="image/webp"; ".css"="text/css"; ".js"="text/javascript" }
while ($l.IsListening) {
  $c = $l.GetContext(); $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/')); if (!$p) { $p = "index.html" }
  $f = Join-Path $root $p
  if ((Test-Path $f -PathType Leaf) -and ([IO.Path]::GetFullPath($f).StartsWith($root))) {
    $b = [IO.File]::ReadAllBytes($f); $e = [IO.Path]::GetExtension($f).ToLower()
    $c.Response.ContentType = $(if ($types[$e]) { $types[$e] } else { "application/octet-stream" })
    $c.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
