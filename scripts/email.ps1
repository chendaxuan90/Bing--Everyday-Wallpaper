# ---------------------------------------------------*/
# Script Name       : email.ps1
# Purpose           : Send a notification email based on GitHub Actions result.
# Author            : Daxuan Chen
# Creation date     : 2025-09-16
# Return Code        : 0  - Success; email sent successfully
#                     8  - Error; failed to send email
# ---------------------------------------------------*/

# ------------------- Declare Variables -------------------
$currentDate = Get-Date -Format "yyyy-MM-dd"
$scriptName = "email"

# GitHub Actions Environment Variables
$token          = $env:RESEND_API_TOKEN
$receiver       = $env:MAIL_RECEIVER
$sender         = $env:MAIL_SENDER
$actionResult   = $env:ACTION_RESULT      # success/failure/cancelled

# Log content based on Action result
switch ($actionResult) {
    "success"   { $result = "SUCCESS"; $logContent = "Wallpaper download step completed successfully." }
    "failure"   { $result = "FAIL";    $logContent = "Wallpaper download step failed." }
    "cancelled" { $result = "CANCELLED"; $logContent = "Workflow was cancelled." }
    default     { $result = "UNKNOWN"; $logContent = "Unknown workflow status." }
}

# Script log path inside repo for email script
$scriptLogPath = "./logs/email"
if (!(Test-Path $scriptLogPath)) { New-Item -ItemType Directory -Path $scriptLogPath -Force | Out-Null }
$scriptLogFile = Join-Path $scriptLogPath "$scriptName-$currentDate.log"

# ------------------- Logging -------------------
Add-Content -Path $scriptLogFile -Value "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss.fff')] [INFO] Script started"
Add-Content -Path $scriptLogFile -Value "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss.fff')] [INFO] Action result: $result"

# ------------------- Construct Email -------------------
$body = @{
    "from"    = "Daily Script Notification <$sender>"
    "to"      = @($receiver)
    "subject" = "Bing Wallpaper Script Report - $currentDate"
    "html"    = @"
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<title>Daily Log Report</title>
<style>
body { font-family: monospace, Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
.container { max-width: 600px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; }
pre { white-space: pre-wrap; word-wrap: break-word; }
.header, .footer { text-align: center; font-weight: bold; }
.divider { border-bottom: 1px solid #ddd; margin: 10px 0; }
</style>
</head>
<body>
<div class='container'>
<div class='header'>=== DAILY LOG REPORT ===</div>
<p>Dear User,</p>
<p>The wallpaper script has finished. Script name: $scriptName</p>
<div class='divider'></div>
<pre>$logContent</pre>
<div class='divider'></div>
<p>Execution Summary:</p>
<p>Result: <strong>$result</strong></p>
</div>
<div class='footer'>&copy; 2025 System Automation</div>
</body>
</html>
"@
}

# ------------------- Send Email -------------------
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

try {
    Invoke-RestMethod -Uri "https://api.resend.com/emails" -Method Post -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    Add-Content -Path $scriptLogFile -Value "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss.fff')] [SUCCESS] Email sent successfully."
    exit 0
} catch {
    Add-Content -Path $scriptLogFile -Value "[$(Get-Date -Format 'yyyy/MM/dd-HH:mm:ss.fff')] [ERROR] Failed to send email: $_"
    exit 8
}
