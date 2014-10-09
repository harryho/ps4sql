ps4sql
======
  PS4SQL aims to provide a command line interactive program to manage the 
  non-regular process for data maintenance, cleansing and specific reporting.  
  Considering these data operation data are not regular as weekly, monthly 
  report, this program provide a set of options for user to choose and depend
  on the uesr's   requrirement to complete above operation tasks. Any question
  or concern please don't hestite to ask me or development team. The program 
  is supposed to run on the machine which has SQL server locally.
  
  
## Non-Regular task list##
  1. Data cleansing
      - delete duplicate sales, leads, orders record;
      - delete duplicate account, contact recrod;
  2. Data update
      - update the latest sale, order data from the sales team;
      - update the latest contact detail from the customer service team;
  3. Data report ( I believe most systems have weekly / monthly report 
    function, but your GM or marketing team or sale team lead want to
    check the UTD data, and want to get the report from you ASAP )
      - generate the report for GM;
      - generate the report for Marketing;
      - generate the report for sales team leader;
      - generate the report for customer service team;
        
 
##Directory structure
      Root (PS4SQL)                    
        |__ backup :      A folder  contains database  backup files
        |__ log:          A folder contains log files               
        |__ report:       A folder contains report files
        |__ sql:          A folder contains sql scripts      
        |__ template :    A folder contains sql  script template    
        |__ update:       A folder contains the csv files for data update
        |__ main.ps1 :    A powershell file called by main.ps1     
        |__ worker.ps1 :  A powershell file executed by user        
