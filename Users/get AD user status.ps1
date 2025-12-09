# Import the required module
Import-Module ../Library/ActiveDirectory.psm1

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function GenerateForm {

    #----------------------------------------------
    #region Import Assemblies
    #----------------------------------------------
    [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    #endregion

    #----------------------------------------------
    #region Generated Form Objects
    #----------------------------------------------
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $form1 = New-Object System.Windows.Forms.Form
    $Pwdchkbx = New-Object System.Windows.Forms.CheckBox
    $PwdTxtBx = New-Object System.Windows.Forms.TextBox
    $PwdLbl = New-Object System.Windows.Forms.Label
    $label2 = New-Object System.Windows.Forms.Label
    $combobox1 = New-Object System.Windows.Forms.ComboBox
    $button1 = New-Object System.Windows.Forms.Button
    $rsltsbox1 = New-Object System.Windows.Forms.TextBox
    $cnclBtn = New-Object System.Windows.Forms.Button
    $okbtn = New-Object System.Windows.Forms.Button
    $label1 = New-Object System.Windows.Forms.Label
    $txtbox1 = New-Object System.Windows.Forms.TextBox
    #endregion Generated Form Objects

    #----------------------------------------------
    # User Generated Script
    #----------------------------------------------
    $handler_okbtn_Click = {
        $domain = $combobox1.Text
        $samaccountname = $txtbox1.Text
        $userStatus = Get-ADUserStatus -Domain $domain -SamAccountName $samaccountname
        if ($userStatus -is [string]) {
            $rsltsbox1.Text = $userStatus
        }
        else {
            $rsltsbox1.Text = $userStatus | Format-List | Out-String
        }

        if ($Pwdchkbx.Checked) {
            $newPassword = Reset-ADUserPassword -Domain $domain -SamAccountName $samaccountname
            $PwdTxtBx.Text = $newPassword
        }
    }

    $handler_unlockbtn_Click = {
        $domain = $combobox1.Text
        $samaccountname = $txtbox1.Text
        $rsltsbox1.AppendText((Unlock-ADUserAccount -Domain $domain -SamAccountName $samaccountname) + "`r`n")
    }

    $CancelBtn = {
        $form1.Close()
    }

    #----------------------------------------------
    #region Generated Form Code
    #----------------------------------------------
    $form1.Controls.Add($Pwdchkbx)
    $form1.Controls.Add($PwdTxtBx)
    $form1.Controls.Add($PwdLbl)
    $form1.Controls.Add($label2)
    $form1.Controls.Add($combobox1)
    $form1.Controls.Add($button1)
    $form1.Controls.Add($rsltsbox1)
    $form1.Controls.Add($cnclBtn)
    $form1.Controls.Add($okbtn)
    $form1.Controls.Add($label1)
    $form1.Controls.Add($txtbox1)
    $form1.AcceptButton = $okbtn
    $form1.CancelButton = $cnclBtn
    $form1.ClientSize = New-Object System.Drawing.Size(552, 383)
    $form1.Name = "form1"
    $form1.Text = "Password Report"

    $Pwdchkbx.Location = New-Object System.Drawing.Point(336, 38)
    $Pwdchkbx.Size = New-Object System.Drawing.Size(119, 24)
    $Pwdchkbx.Text = "Reset Password"

    $PwdTxtBx.Location = New-Object System.Drawing.Point(12, 353)
    $PwdTxtBx.ReadOnly = $True
    $PwdTxtBx.Size = New-Object System.Drawing.Size(145, 20)

    $PwdLbl.Location = New-Object System.Drawing.Point(12, 335)
    $PwdLbl.Size = New-Object System.Drawing.Size(100, 14)
    $PwdLbl.Text = "Password"

    $label2.Font = New-Object System.Drawing.Font("Calibri", 9.75, 1, 3, 1)
    $label2.Location = New-Object System.Drawing.Point(12, 20)
    $label2.Size = New-Object System.Drawing.Size(100, 16)
    $label2.Text = "Select Domain"

    [void]$combobox1.Items.Add("ddor.local")
    [void]$combobox1.Items.Add("myDomain1")
    $combobox1.Location = New-Object System.Drawing.Point(12, 39)
    $combobox1.Size = New-Object System.Drawing.Size(121, 21)

    $button1.Location = New-Object System.Drawing.Point(465, 35)
    $button1.Size = New-Object System.Drawing.Size(75, 23)
    $button1.Text = "Unlock"
    $button1.add_Click($handler_unlockbtn_Click)

    $rsltsbox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $rsltsbox1.Font = New-Object System.Drawing.Font("Consolas", 8.25, 1, 3, 1)
    $rsltsbox1.Location = New-Object System.Drawing.Point(12, 66)
    $rsltsbox1.Multiline = $True
    $rsltsbox1.ReadOnly = $True
    $rsltsbox1.Size = New-Object System.Drawing.Size(528, 262)

    $cnclBtn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $cnclBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $cnclBtn.Location = New-Object System.Drawing.Point(386, 353)
    $cnclBtn.Size = New-Object System.Drawing.Size(68, 23)
    $cnclBtn.Text = "Close"
    $cnclBtn.add_Click($CancelBtn)

    $okbtn.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $okbtn.Location = New-Object System.Drawing.Point(468, 353)
    $okbtn.Size = New-Object System.Drawing.Size(68, 23)
    $okbtn.Text = "OK"
    $okbtn.add_Click($handler_okbtn_Click)

    $label1.Font = New-Object System.Drawing.Font("Calibri", 9.75, 1, 3, 1)
    $label1.Location = New-Object System.Drawing.Point(139, 20)
    $label1.Size = New-Object System.Drawing.Size(100, 15)
    $label1.Text = "Enter Username"

    $txtbox1.Location = New-Object System.Drawing.Point(139, 38)
    $txtbox1.Size = New-Object System.Drawing.Size(190, 20)
    #endregion

    return $form1.ShowDialog()
}

GenerateForm | Out-Null
