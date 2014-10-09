<# 
 .SYNOPSIS   
  PS4SQL aims to provide a command line interactive program to manage the 
  non-regular process for data maintenance, cleansing and specific reporting.  
  Considering these data operation data are not regular as weekly, monthly 
  report, this program provide a set of options for user to choose and depend
  on the uesr's   requrirement to complete above operation tasks. Any question
  or concern please don't hestite to ask me or development team. The program 
  is supposed to run on the machine which has SQL server locally.

 .DESCRIPTION  
  Started guide:      
    * If the program is running on production envrionment, please backup your 
      production server at first.
    * If you have any doubt regarding this program please enquire dev or infra
      team.
    * Start powershell      
    * Run the main.ps1       
    * Menu and operation are straight forward. More details please 
       check the examples below.
     
   Directory structure:      
      Root (PS4SQL)                    
        |__ backup :      A folder  contains database  backup files
        |__ log:          A folder contains log files               
        |__ report:       A folder contains report files
        |__ sql:          A folder contains sql scripts      
        |__ template :    A folder contains sql  script template    
        |__ update:       A folder contains the csv files for data update
        |__ main.ps1 :    A powershell file called by main.ps1     
        |__ worker.ps1 :  A powershell file executed by user
	   
    * Root directory can be renamed. 
    * Sub folders under the Root can be configured by the constants
      variables in the  main.ps1 .

	
  #****************************************************************   
  # Program: CRM Data Cleansing   
  # Author : hho   
  # Date   : 24.07.2014   
  # Purpose: Centralize and reuse the sql scripts
  #****************************************************************   
  #:Revisions   #: Rev No     Date         AUTHOR     Details
  #:--------:-----------:-------------------:--------------------------   
  #:0.1     :26.07.2011 :     hho           :  
  #:0.1.5   :14.02.2012 :     hho           :           :: 
  # 0.1.20  :17.05.2013 :     hho           :           ::    
  #:--------:-----------:-------------------:--------------------------
  #********************************************************************

 Note:
    1. Data cleansing
       a. delete duplicate sales, leads, orders record;
       b. delete duplicate account, contact recrod;
    2. Data update
       a. update the latest sale, order data from the sales team;
       b. update the latest contact detail from the customer service team;
    3. Data report ( I believe most systems have weekly / monthly report 
        function, but your GM or marketing team or sale team lead want to
        check the UTD data, and want to get the report from you ASAP )
        a.generate the report for GM;
        b.generate the report for Marketing;
        c.generate the report for sales team leader;
        d.generate the report for customer service team;


.EXAMPLE

-------------------------------EXAMPLE 1-----------------------------------------
     PS C:\PS4SQL>.\main.ps1
  
  
  Description 
  ------------------- 
  This command can run the program. PS4SQL is root directory. 
  
  Use right click menu and click "Run with Powershell" can run the program
  as well.
  
   
  
  ---------------------------- EXAMPLE 2----------------------------------------
     PS C:\PS4SQL>

      Please type [D],[H],[B],[R] or [X] to pick up following options.
		  
      [D] Backup database with rollback script and data cleansing.
           This process is highly recommended for the first time of running 
           data cleansing.        
      [H] Restore the database, backup again and data cleansing. If  you want
          to roll back and try again. Please choose this action.        
      [C] Data cleansing only. Not recommended for the first time.        
      [B] Backup database only. Not
      recommended for the first time.        
      [R] Restore database only. Not
      recommended for the first time.        
      [X] Exit
		  
      Please type your option here : D 

 
 Description 
 ----------------
 Thisisthemainprogrammenu.The[D] in this example is the user's input. 
 D/d are both accepted. If it is your first time to run the program,
 [D] process is highly recommended.It will backup database, prepare 
 all scripts, complete data cleansing and validate the final result.
 
 All the process, except[X]can be assumed a comprehensive process.
  
 
 
 ---------------------------- EXAMPLE 3 -------------------------------
  PS C:\PS4SQL>

      Do you want to choose another action? 
      Please type [Y] to continue or [N] to exit : Y
		  
 
 Description 
 ------------------
 After the program complete one comprehensive processes which has
 show in Example 2.The usercan choose to continue or exit.[Y] in this 
 example is user's input. If user chooses[Y],the program will go back 
 the main menu as example 2. If user choose[N],the program will exit.
 
 
 
 
 
  ------------------------- EXAMPLE 4-------------------------------  
   PS C:\PS4SQL>

    Please enter the database name :  hmc_crm_mgr_copy
		  
   There is an existing backup database file hmc_crm_mgr_copy.bak .
   Please enter [Y] to replace it or [N] to create new backup file  : N
		   
		   
  New backup file name : hmc_crm_mgr_copy.20140724120507.bak
		   

 Description 
 --------------------------
 If user choose [D] or [H] inthe main program menu, you need to enter the 
 database name. 
 
 hmc_crm_mgr_copy is the user's input. Usually the program will use this 
 name as the backup file name with bak as file extension.
 
 If the program finds an existing file with the same name,you need to
 pick up  [Y]or[N}.[N] is the user's input. The program will generate a new 
 backup file name to backup the database and remind the user that restore
 process will use new backup file to restore.
 
 If user chooses[Y], the program will backup the database with the same
 name and replace the previous backup file.


#>

# ***-------------------*** 
# ***  define Constants **** 
#***-------------------*** 
Set-Variable -name ps4sql_AppName -value "PS4SQL" -option ReadOnly -force 
Set-Variable -name ps4sql_bakFolder -value "dbbackup" -option ReadOnly -force 
Set-Variable -name ps4sql_updateFolder -value "update" -option ReadOnly -force 
Set-Variable -name ps4sql_logFolder -value "log" -option ReadOnly -force 
Set-Variable -name ps4sql_tempFolder -value "template" -option ReadOnly -force 
Set-Variable -name ps4sql_sqlFolder -value "sql" -option ReadOnly -force 
Set-Variable -name ps4sql_repFolder -value "report" -option ReadOnly -force 
Set-Variable -name ps4sql_importPs -value "crm_mgr.ps1" -option ReadOnly -force



# ***-------------------*** 
#**** define Variables  **** 
#***-------------------***

#  ------------ Time variable ---------------
$ps4sql_timer=[Diagnostics.Stopwatch]::StartNew()

#  ------------  Directory variables -------------------- 
$ps4sql_pwd=pwd
$ps4sql_mainProgramFullPath="$ps4sql_pwd\$ps4sql_mainProgram"
$ps4sql_bakFolderFullPath="$ps4sql_pwd\$ps4sql_bakFolder"
$ps4sql_logFolderFullPath="$ps4sql_pwd\$ps4sql_logFolder"
$ps4sql_tempFolderFullPath="$ps4sql_pwd\$ps4sql_tempFolder"
$ps4sql_sqlFolderFullPath="$ps4sql_pwd\$ps4sql_sqlFolder"
$ps4sql_repFolderFullPath="$ps4sql_pwd\$ps4sql_repFolder"

#  -----------------  File variables -------------------- 
$ps4sql_TimeStamp=get-date -f yyyyMMddHHmmss 
$ps4sql_logFileFullPath="$ps4sql_logFolderFullPath\log.$ps4sql_TimeStamp.txt" 
$ps4sql_logFilePath="$ps4sql_logFullPath"

#  -----------------  User variables -------------------- 
$ps4sql_database ="" 
$ps4sql_results = @()
$ps4sql_txtReportFullPath = "$ps4sql_repFolderFullPath\txt_report$ps4sql_TimeStamp.txt"
$ps4sql_csvReportFullPath = "$ps4sql_repFolderFullPath\csv_report$ps4sql_TimeStamp.csv"


# customized by different purpose  
$ps4sql_cpyTblPrefix = "cpy_"
$ps4sql_newTblPrefix = "mgr_" 
$ps4sql_user =[System.Security.Principal.WindowsIdentity]::GetCurrent().Name


# ***-------------------*** 
# ***  import scripts  **** 
#***-------------------*** 
$ps4sql_script1="$ps4sql_pwd\$ps4sql_importPs"
.$ps4sql_script1

# ***-------------------*** 
#****    Main Program    **** 
#***-------------------***


function init
{
    if( !(Test-path -path $ps4sql_logFolderFullPath ))
    {
      $info = New-Item  -type directory -path $ps4sql_logFolderFullPath
    }
    
    if( !(Test-path -path $ps4sql_bakFolderFullPath ))
    {
      $info = New-Item -type directory -path  $ps4sql_bakFolderFullPath
      log $info
    }
  
    if( !(Test-path -path $ps4sql_sqlFolderFullPath ))
    {
      $info = New-Item -type directory -path  $ps4sql_sqlFolderFullPath
      log $info
    }
    
    if( !(Test-path -path $ps4sql_repFolderFullPath ))
    {
      $info = New-Item -type directory -path  $ps4sql_repFolderFullPath
      log $info
    }
	
	if( !(Test-path -path $ps4sql_txtReportFullPath ))
    {
			   New-Item -type file -path  $ps4sql_txtReportFullPath
    }
	
    if( !(Test-path -type leaf -path  $ps4sql_csvReportFullPath ))
    {
			   New-Item -type file -path  $ps4sql_csvReportFullPath
    }
	
	if( !(Test-path -type leaf -path  $ps4sql_csvReportFullPath ))
    {
			   New-Item -type file -path  $ps4sql_csvReportFullPath
    }
	
    LoadSnapIn
    
    $logInfo = "  Initial completed ... `n"     
    
    Write-Host $logInfo
    
    log $logInfo
    
	# Register-ObjectEvent -InputObject $timer -EventName elapsed   -SourceIdentifier  thetimer -Action $action    	 
    
   # dataCleansing 
    
}


function LoadSnapIn
{
    $logInfo= ""
    
    # Load SqlServerProviderSnapin100 
    if (!(Get-PSSnapin | ?{$_.name -eq 'SqlServerProviderSnapin100'})) 
    { 
        if(Get-PSSnapin -registered | ?{$_.name -eq 'SqlServerProviderSnapin100'}) 
        { 
           add-pssnapin SqlServerProviderSnapin100 
           $logInfo= "Loading SqlServerProviderSnapin100 in session" 
           log $logInfo
        } 
        else 
        { 
            $logInfo= "SqlServerProviderSnapin100 is not registered with the system."
            Write-Host $logInfo -Backgroundcolor Red �Foregroundcolor White 
            log $logInfo
            break 
        } 
    } 
    else 
    { 
        $logInfo= "SqlServerProviderSnapin100 is already loaded" 
           log $logInfo
    }  
    
    # Load SqlServerCmdletSnapin100 
	if (!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})) 
	{ 
		if(Get-PSSnapin -registered | ?{$_.name -eq 'SqlServerCmdletSnapin100'}) 
		{ 
			add-pssnapin SqlServerCmdletSnapin100 
			$logInfo= "Loading SqlServerCmdletSnapin100 in session" 
            log  $logInfo 
		} 
		else 
		{ 
			$logInfo= "SqlServerCmdletSnapin100 is not registered with the system." 
            Write-Host $logInfo -Backgroundcolor Red �Foregroundcolor White
            log  $logInfo 
			break 
		} 
	} 
	else 
	{ 
	    $logInfo= "SqlServerCmdletSnapin100 is already loaded" 
        log  $logInfo 
	} 
    
}

function deinit 
{
    $timer.stop()
  #  Unregister-Event thetimer
   Get-Variable  -include hmc_ps* -Scope "global" |  % { Remove-Variable -Name "$($_.Name)" -Force -Scope "global"  -ErrorAction Stop }
}

function main 
{     
    
  try{
   Write-Host " `n`n
  
    <==<<===<<<  $ps4sql_AppName >>>===>>==>
	
  ******************************************************
  
   Hi, $ps4sql_user, you are running data cleansing program. `n "
       
    Write-Host "
===================================================================
		   
  IMPORTANT: Data cleansing should only clean the copy of production.          
				   
==================================================================== `n " 
     
   Write-Host " 
   If you need more information, please start PowerShell from window's 
   accessories and type:  
   
   get-help  $ps4sql_pwd\main.ps1  -full `n
   
   To run the program in PowerShell CLI, pleae type :
   
   $ps4sql_pwd\main.ps1 
   `n"
  
  
     $continue = Read-Host "`n  Please type [Y] to enter main menu or [N] to exist "
	 
	  if ( $continue.toUpper() -eq "Y" )
     {
	   
       $measure= Measure-Command   {          
       Write-Host "`n   The program is initializing ...  `n"            
       init                 
       Do{             
          $cmd =Read-Host "`n

Please type [D],[H],[C],[B],[S],[M] or [X] to pick up following process

[D] Backup database .
[H] Restore the database.
[C] Data cleansing and data update.
[B] Generate report for GM.
[S] Generate report for Sale team
[M] Generate report for marketing
[X] Exit              
		  
Please type your option here "
         
        log " user choose $cmd ".
			  
          switch ($cmd.toUpper()) {
              "D" { $cmd=commandHandler "Backup-DataCleansing"}
              "H" { $cmd=commandHandler "Restore-Backup-DataCleansing" }
              "C" { $cmd=commandHandler  "DataCleansing-Only"  }
              "B" { $cmd=commandHandler  "Backup-Only"  }
              "S" { $cmd=commandHandler  "DataCleansing-Only"  }
              "M" { $cmd=commandHandler  "Backup-Only"  }              
              "R" { $cmd=commandHandler  "Restore-Only"  } 
          }
		  
		  if ( $cmd.toUpper() -eq "Y" ) {
		      $ps4sql_TimeStamp=get-date -f yyyyMMddHHmmss 
			  $ps4sql_txtReportFullPath = "$ps4sql_repFolderFullPath\txt_report$ps4sql_TimeStamp.txt"
			  $ps4sql_csvReportFullPath = "$ps4sql_repFolderFullPath\csv_report$ps4sql_TimeStamp.csv"
		  }
      } Until ( ($cmd) -and ( $cmd.toUpper()  -eq "X" ) )
       
      }  
     }  
  }
   catch
  {
 
    Write-Host "Caught an exception:" -Backgroundcolor Red –Foregroundcolor White  Red
    log "Caught an exception:"         
    Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -Backgroundcolor Red –Foregroundcolor White
    log "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Host "Exception Message: $($_.Exception.Message)" -Backgroundcolor Red –Foregroundcolor White 
    log "Exception Message: $($_.Exception.Message)"    
  }
  finally
  { 
     log "Finally block reached. The whole process took $measure . Exit." 
     Write-Host "Finally block reached. The whole process took $measure . Exit."	    
        deinit    
  }
  
}

main