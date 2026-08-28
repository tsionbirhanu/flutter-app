param(
  [Parameter(Mandatory = $true)]
  [string]$CustomerJwt,

  [Parameter(Mandatory = $true)]
  [string]$FcmToken,

  [string]$ApiBaseUrl = "http://localhost:4000"
)

$body = @{
  fcm_token = $FcmToken
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "$ApiBaseUrl/me/register-device-token" `
  -Method Post `
  -ContentType "application/json" `
  -Headers @{ Authorization = "Bearer $CustomerJwt" } `
  -Body $body |
  ConvertTo-Json -Depth 10
