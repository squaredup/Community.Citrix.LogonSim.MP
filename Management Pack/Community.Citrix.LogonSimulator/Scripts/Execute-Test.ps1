param(
	$StoreFrontUrl,
	$ResourceName,
	$Domain,
	$UserName,
	$Password,
	$TestName,
	$ConfigurationPath,
	$LogFileName,
	$TimeoutForSFLoginPage,
	$TimeoutForSFResourcesPage,
	$TimeoutForSessionLogin,
	$TimeoutForOther
)

$scriptName = "Execute-Test.ps1"

# Initialise SCOM API
$api = new-object -comObject "MOM.ScriptAPI"

# Put everything in a try-catch to report errors to SCOM
try {

	# SCOM log start
	$api.LogScriptEvent($scriptName, 1000, 0, "Started")

	$scriptProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
	$scriptProcessStartInfo.Arguments = "$ConfigurationPath\Scripts\Test-CitrixApp.ps1 -LogFilePath '$ConfigurationPath\Logs\$TestName' -LogFileName 'sflauncher.log' -SiteURL '$StoreFrontUrl' -UserName '$Domain\$UserName' -Password $Password -ResourceName $ResourceName -TimeoutForSFLoginPage $TimeoutForSFLoginPage -TimeoutForSFResourcesPage $TimeoutForSFResourcesPage -TimeoutForSessionLogin $TimeoutForSessionLogin -TimeoutForOther $TimeoutForOther"
    $scriptProcessStartInfo.Domain = $Domain
	$scriptProcessStartInfo.UserName = $UserName
	$scriptProcessStartInfo.Password = (ConvertTo-SecureString $Password -AsPlainText -Force)
	$scriptProcessStartInfo.LoadUserProfile = $true
	$scriptProcessStartInfo.Verb = "runas"
    $scriptProcessStartInfo.UseShellExecute = $false
	$process = [System.Diagnostics.Process]::Start($scriptProcessStartInfo)
	$process.WaitForExit()
	$returnCode = $process.ExitCode

	# Log complete
	$api.LogScriptEvent($scriptName, 1001, 0, "Finished with output '$returnCode'")

	# Interpret errors as SCOM monitor result
	if($returnCode -eq 0) { $state = "good" } else { $state = "bad" }

	$api.LogScriptEvent($scriptName, 1001, 0, "Adding state: $state")

	# Create the SCOM "property bag"
	$pb = $api.CreatePropertyBag()

	$pb.AddValue("State", $state)

	# Write the property bag to the output        
	$pb

}
catch {
	# Top level error handling - log to SCOM
	$api.LogScriptEvent($scriptName, 1002, 2, $_.Exception.Message)
}