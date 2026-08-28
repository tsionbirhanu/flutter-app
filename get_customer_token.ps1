param(
  [Parameter(Mandatory = $true)]
  [string]$PhoneNumber,

  [Parameter(Mandatory = $true)]
  [string]$Pin,

  [string]$ApiBaseUrl = "http://localhost:4000"
)

$body = @{
  phone_number = $PhoneNumber
  pin = $Pin
} | ConvertTo-Json

$response = Invoke-RestMethod `
  -Uri "$ApiBaseUrl/customer/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body

$response | ConvertTo-Json -Depth 10
