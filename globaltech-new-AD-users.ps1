
  $logo =
          
           @"
                                         .,**//(((#((/*.                                           
                                   ,*((##%%#((###/**,,....,,,,..                                   
                              ./#%%%%%%(.,(%%%#,,//,.....,,,,,,***,.                               
                           ./#%%%%%%%%*,/#%%%%%(. ,#(/,....,,,,,,***.                              
                        ./%#%&%%%%%%%/.,(%%%######*  ,/##(*,..,,*,,.  .*,.                         
                       #&%(&&%%%%%%%%/.,%%##########/. .*(####(,.  .,,*****.                       
                    .#&%%/#&%%%%%%%%%%,.*%###########(/*..,*(#%####(/*****,.                     
                   (&&%%//#&%%%%%%%%%%#..,#&%#######(((((((/,..,/#%&%######(/*,                    
                 *%%&%%#,.*&%%%%%%%%####/..*#&((((((((((((((((/*.,*/#&&&####,                  
                /&&&%%%#.,/&&%%%%%%#######*,**/%&%(((((((((((((((((((*,,*/(%&&%%%/.                
               #&&&&%%%%/**#&&%%%%#########(*. .*#&&%(///////((((((((((((((*,..*(#(.               
              *&&&&%%%%%%**/#&&%%##########((((...,/#&@%(////////((((((((#####/. *(*.              
             *%&&&&%%%%%%%/**/%@%#########(((((((/,...,(%&@%(//////(((((((#########,.              
            .%#&&&&%%%%%%%%***/#%&%######(((((((///**....,*#&&@#(//(((((((#########%(.             
            #(*&@&&%%%%%%%%%(*...*#&%####((((((////****,,..,,,,*(#&&%(((((#########%%#.            
           ,*&@&%%%%%%%%%%%#, ,*/%&@%##((((((////***,,,,,,.     .*(%&&%##########%%%/.           
           (&&(%&@&%%%%%%%%%%%%#/****(%@(((((////****,,,,,*****,    .*(%&@&%#####%%%#,           
           %&&%(%&@%%%%%%%%%%%%###/****(%&@#((((///*************/////,    .*#%&@&%##%%#,.          
           &&&&((#&@&%%%%%%%%%%%####(*****/%&@&((/////********////(((((((/,   .*(%&&%%%,.          
           &&&&%(((%&&%%%%%%%%%%%#####(*****,*/%&%(//////////////(((((((####(*.  ,/%&&%*.          
           %&&&&*,*#@&%%%%%%%%%%#######(,     .*#@&%(//////(((((((((((#########/,//##,.          
           (&&&&& ,(%@@%%%%%%%%%%########(*  .***/#%&&%(((((((((((((############%#///.           
           /&&&&&&&%#((#%&@%%%%%%%%%###########(/******(#&@@%#(((((############%%%%%%#.            
           ,%&&&&&&&&%((((%@@&%%%%%%%#############(********(%&@&%#############%%%%%%%%,            
            (%&&&&&&&&%%((((#&&&%%%%%%################(****,****/(%&&%#######%%%%%%%%(.            
            ,%%&&&&&&&&%%%((/**/%&&%%%%%%%################(,..    .*(&&&%%%%%%%%%%%%%/.            
             *%(#&&&&&&&%&%%(,   ./&@&%%%#%###################(,.... ..*(%&@&%%%%%%%(,.            
             ./#*#&&&&&&&&%%%%#..*((#%&@&%%%%%%###################(,..   .,(%&@&%%%(*.             
              .(%&&&&&&&&&&%%%%%%((((#%&@&%%%%%%%%%%%%#####%%%%%%%%%#*.,,**/(%@,.              
               ,(&&%&&&&&&&&&&%%%%%%%%#((((%&&&%%%%%%%%%%%%%%%%%%%%%%%%%%%(///*/##*.               
                .*%&&%%&&&&&&&&&&%%%%%%%%#(*,..,(%@&%%%%%%%%%%%%%%%%%%%%%%%%%#/,,.                 
                  ,%&&&%%%%&&&&&&&%%%%%%%%%(,  *(((%&&&&%%%%%%%%%%%%%%%%%%%%%%*                    
                   .*#&&&&(*/#&&&&&&&&%%%%%%%%%%#(////**/(%&&%%%%%%%%%%%%%%%(.                     
                     .*%&&&&(*/&&@&&&&&&&%%%%%%%%%%#/.     .*(#&&&%%%%%&%%%*.                      
                       .*(%&&&&&%%%&&&&&&&&&&&%&%%%%%%%%#/,    ..*(&&&&%#/,                        
                         .,(%&&&&&&&%%%%%%&&&&&&&&&&&&&&&%&&%#*,*//(#%#*.                          
                        . ...,*(%&&&&&&&&%(#&&&&&&&&&&&&&&&&&&&&%/,,,..                            
                     ........,,,**/##%&&&&&&&&%%###%&&&&&&&&&&%(/,,,......                         
                   .......,,,,,*****///(((#%%%%&&&%%###((((//***,,,,,,.......                      
                   .......,,,,,*****////(((#####%###(((////****,,,,,,.......                       
                     .......,,,,,,,*****////////////////*****,,,,,,........                        
                         .......,,,,,,**********************,,,,.......                            
                             .....,,,,,,,,,,,,,,,,,,,,,,,,,,,,.....          
                                                                                                    
                                                                            
"@

          
          
          
          $logo


import-module activedirectory

write-host 'We are now going to make a new user'

#==============GETTING THE USER INFO===============

$nameinput = read-host -Prompt 'What is the users name?'

$splitname = $nameinput.Split(' ')

$first_name = $splitname[0]

$last_name = $splitname[1]

$job_title = read-host -Prompt "What is this person's job title"

$first_initial = ($first_name).Substring(0,1)

$username = $first_initial + $last_name


[string]$facility = Read-Host 'Which facility is this person in?'

$DomainDn = (Get-AdDomain).DistinguishedName

$z = ((get-addomain).dnsroot).split('.')

$ou_path = 'OU=' + $facility +  ',OU=Users,OU=' + $z[0] +',' + $DomainDN

#=============GETTING THE EMAIL ADDRESS==================

$all_administrators = get-aduser -Filter "Title -like 'Administrator'" -Properties mail

foreach ($i in $all_administrators){

[string]$distin = $i.DistinguishedName

[string]$withtheou  = $distin.Split(',')

[string]$withouttheou = ($withtheou.split('='))[2]

[string] $thefacility = $withouttheou.Split(' ')[0]

          if (($thefacility -eq $facility)){
          
   $adminsemail = ($i.mail)
   $email_suffix = ($adminsemail.split('@'))[1]
                }
          }


#===========ACTUALLY DOING IT===============

$Attributes = @{

   Enabled = $true
   ChangePasswordAtLogon = $true
   path = $ou_path
   SamAccountName = $username
   Title = $job_title
   UserPrincipalName = $username + '@' + $email_suffix
   Name = $first_name +' ' + $last_name
   GivenName = $first_name
   Surname = $last_name
   DisplayName = $first_name +' '+ $last_name
   EmailAddress = $username + '@' + $email_suffix
   #Description = 
   #Office = 

   #Company = 
   #Department = 
   #Title = 
   #City = 
   #State = 

   AccountPassword = "Spring2019" | ConvertTo-SecureString -AsPlainText -Force

}

New-ADUser @Attributes




#=============GETTING THE GROUP MEMBERSHIPS=============
$thenewperson = (get-aduser -filter "Name -like '$first_name $last_name'")

$allpeoplewiththesametitle = get-aduser -Filter "Title -like '$job_title'"

if(!$allpeoplewiththesametitle)
{ write-host 'Apparently there is no one in this facility that has the same title as the new user. Group Membership will therefore need to be added manually.'
                         Exit }  

foreach ($i in $allpeoplewiththesametitle) #finding someone else with the same title
{

[string]$distin = $i.DistinguishedName

[string]$withtheou  = $distin.Split(',')

[string]$withouttheou = ($withtheou.split('='))[2]

[string] $thefacility = $withouttheou.Split(' ')[0]

          if (($thefacility -eq $facility)){
          
             $allthegroupstheotherisin =  Get-ADPrincipalGroupMembership -Identity $distin
             
             foreach ( $groupname in $allthegroupstheotherisin){
             
             if($groupname.name -eq 'Domain Users')
              
             {continue}
            {
     
             Add-ADGroupMember -Identity $groupname.distinguishedName -Members $thenewperson}
             }
         
             
               
                
                
                
                
                
                }
          }