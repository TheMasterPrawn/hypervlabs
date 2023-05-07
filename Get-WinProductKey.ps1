# Get Windows product key from registry
$productKey = (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue("DigitalProductId")

# Convert product key to readable format
$productId = ""
$key = $productKey[52..66]
$charsArray = "B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9"
for ($i = 24; $i -ge 0; $i--) {
  $k = 0
  for ($j = 14; $j -ge 0; $j--) {
    $k = $k * 256 -bxor $key[$j]
    $key[$j] = [math]::truncate($k / 24)
    $k = $k % 24
  }
  $productId = $charsArray[$k] + $productId
  if (($i % 5) -eq 0 -and $i -ne 0) {
    $productId = "-" + $productId
  }
}

# Output the product key
Write-Output $productId