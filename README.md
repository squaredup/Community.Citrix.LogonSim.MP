# Getting started with the Community Citrix Logon Simulator MP

## What is the Citrix Logon Simulator MP?

It's a Microsoft System Center Operations Manager (SCOM) management pack for simulating logons to Citrix XenApp and XenDesktop via NetScaler and StoreFront. You will need SCOM to use the management pack.

Once installed and configured, the management pack will perform regular, automated application launches in your Citrix environment to enure your applications are available to end users. Using SCOM, you can configure email notifications for any failures, build dashboards to show real-time availability, and create management reports to demonstrate Citrix uptime and availability.

## Getting started

To install the Logon Simulator you will need:

- SCOM 2012 R2 (earlier versions may be supported but are untested)
- Citrix XenDesktop or XenApp, with StoreFront 3.5 or later (the script requires a minor modification to run with SF 3.0)
- A user account that will be used to perform the logons. The account must have access to one or more desktops or applications.
- A test application (e.g. Notepad) or desktop that will be launched. The above user must have access to the application.
- A test machine with Internet Explorer and Citrix Receiver installed, from where the logons will be made

The Logon Simulator is split into two parts:
1. A management pack that the SCOM administrator will need to install
2. A set of files that are installed on a test client and should be managed by the Citrix administrator

### Step 1 – Install the SCOM Management Pack

Import the management pack `Community.Citrix.LogonSimulator.mpb` into SCOM using the standard process.

The MP will show up as `Citrix Logon Simulator (Community MP)`.

The MP adds a new Run As Profile called `Citrix Logon Simulator User Account`. This must be configured with a user account that will be used for the simulatated logons. Ensure that the user account is configured to be distributed by SCOM to the test client(s).

The MP also adds a discovery called `Discover Citrix Logon Simulator Test`. This can be viewed in the SCOM console under `Authoring > Management Pack Objects > Object Discoveries`.

The discovery is set to run every hour by default, on all Windows Computers. You can override the discovery to run more regularly on your target client machines.


### Step 2 – Prepare the client test machine

Now we’re ready to configure the client test machine. This should be done on one or more Windows computers that will run the simulated logons. You may want to start by testing with a regular server in your data centre, and then experiment with test clients elsewhere in your organisation, such as remote sites, branch offices or even the public cloud.

Let's break this down into several smaller steps:

#### Select and prepare a test client machine:

The machine must be a Windows computer monitored by SCOM, with Citrix Receiver installed.

Verify the user logon by manually browsing to your StoreFront URL, logon with the **test user credentials** and launch the test application.

**REALLY IMPORTANT** Verify that the logon and application launch involves no pop-up dialogs, file downloads or other user interruptions. The test application must also be available on the front page after user logon, i.e. in the user favourites.

### Configure and test the script: 

1. Unzip the ClientFiles.zip to the C: drive on the test client. This should create the following folder structure:
 
```
C:\
  Monitoring\
    Citrix\
      Example Configuration Files\
      Logs\
      Scripts\
```

2. In order for the script to logoff the ICA sessions automatically, you must add the following registry key:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix\ICA Client\CCM\AllowLiveMonitoring = 1 (REG_DWORD)
```

3. You’re now ready to test the script. Open a Administrator PowerShell window and run the following, substituting in your own parameters:

```
C:\Monitoring\Citrix\Scripts\Test-CitrixApp.ps1 -SiteURL https://mycorp.com/Citrix/StoreWeb -UserName domain\username -Password password -ResourceName Notepad
```

Verify that the script performs the following actions:
- opens IE
- logs on
- launches the app
- waits
- closes IE
- logs off the app


Lastly, configure the machine as a test client so that SCOM will automatically run the script.

1. Copy the config.json from `C:\Monitoring\Citrix\Example Configuration Files` to `C:\Monitoring\Citrix`

2. Edit the file, replacing the placeholder values with the details for your environment.


That’s it. SCOM should now discover the config.json file, create new `Citrix Logon Simulator Test` objects hosted on the `Windows Computer` object to represent the tests, and start executing the logon script.

To verify the test clients are discovered and the tests are running, you can use the SCOM console:

Navigate to `Monitoring > Discovered Inventory` and change the type to `Citrix Logon Simulator Test`. You should see the test clients appear. Click on one to see its properties. There will also be an agent task available called `View Last Logon Result` that you can use to view the most recent test log.

## Need help?

This management pack is a community management originally developed by Squared Up (http://www.squaredup.com).

For help and advice, post questions on http://community.squaredup.com/answers.

## Can you improve the script or management pack?

If you want to suggest some fixes or improvements to the script or management pack, raise an issue on [the GitHub Issues page](https://github.com/squaredup/Community.Citrix.LogonSim.MP/issues) or better, submit the suggested change as a [Pull Request](https://github.com/squaredup/Community.Citrix.LogonSim.MP/pulls).
