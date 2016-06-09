param($ComputerName, $SourceId, $ManagedEntityId, $ConfigurationPath)

$script:scriptName = "Discover-Test.ps1"

function AddDiscoveredObject {

	Process {
		$api.LogScriptEvent($scriptName, 1010, 0, "Discovered Test Instance Config")

		$configuration = $_

		$obj = $discoveryData.CreateClassInstance("$MPElement[Name='Community.Citrix.LogonSimulator.Test']$")
		$obj.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", [string]$ComputerName) # Key property
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/TestName$", [string]$configuration.name) # Key property
		$obj.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", [string]$configuration.name)
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/ConfigurationPath$", [string]$ConfigurationPath)
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/StoreFrontUrl$", [string]$configuration.storeFrontUrl) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/ResourceName$", [string]$configuration.resourceName) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/LogFileName$", [string]$configuration.logFileName) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/TimeoutForSFLoginPage$", [int]$configuration.timeoutForSFLoginPage) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/TimeoutForSFResourcesPage$", [int]$configuration.timeoutForSFResourcesPage) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/TimeoutForSessionLogin$", [int]$configuration.timeoutForSessionLogin) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/TimeoutForOther$", [int]$configuration.timeoutForOther) 
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/Interval$", [int]$configuration.interval)
		$obj.AddProperty("$MPElement[Name='Community.Citrix.LogonSimulator.Test']/SyncTime$", [string]$configuration.syncTime)

		$discoveryData.AddInstance($obj)

		$api.LogScriptEvent($scriptName, 1002, 0, "Discovered Test Instance")
	}
}


$script:api = new-object -comObject 'MOM.ScriptAPI'

try {

	$api.LogScriptEvent($scriptName, 1000, 0, "Started")

	$script:discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId)

	Get-Item "$ConfigurationPath\*.json" | Get-Content -Raw | ConvertFrom-Json | AddDiscoveredObject

	Get-Item "$ConfigurationPath\*.xml" | Get-Content -Raw | ForEach-Object { [xml]$_ } | Select -ExpandProperty "Configuration" | AddDiscoveredObject

	Get-Item "$ConfigurationPath\*.csv" | Get-Content -Raw | ConvertFrom-Csv | AddDiscoveredObject

	$api.LogScriptEvent($scriptName, 1003, 0, "Complete")

}
catch {
	$api.LogScriptEvent($scriptName, 9000, 2, $_.Exception.Message)
}

$discoveryData
