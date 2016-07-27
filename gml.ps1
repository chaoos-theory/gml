
# INITIAL PATH
$DIRECTORY_INIT_PATH="LDAP://OU=location,DC=company,DC=com"


function domain(){
    Write-host -ForegroundColor Gray "    TRYING TO ESTABLISH CONNECTION WITH AD DOMAIN ..."

    $DOMAIN = New-Object System.DirectoryServices.DirectoryEntry($DIRECTORY_INIT_PATH)
    if ( $DOMAIN ){

	# SHOW GREEN TRIANGLE
        $c = [char]16
        Write-host -NoNewLine -ForegroundColor Green "     $c"

	# AVAILABLE
        Write-host -ForegroundColor DarkGray " `$DOMAIN variable available."
    }
    else {

	# SHOW RED TRIANGLE
        $c = [char]16
        Write-host -NoNewLine -ForegroundColor Red  "     $c"

	# NOT AVAILABLE
        Write-host -ForegroundColor DarkGray " Could not connect to AD."
    }
    return $DOMAIN
}

function get_members([string]$dn){

    # IF CONNECTED
    if ( $DOMAIN ){ 

	# PREPARE CRITERIA
        $FILTER = "(&(displayName=$dn))";
        $Searcher = New-Object System.DirectoryServices.DirectorySearcher
        $Searcher.SearchRoot = $DOMAIN
        $Searcher.PageSize = 10
        $Searcher.Filter = $FILTER
        $Searcher.SearchScope = "Subtree"

        # WHAT TO COLLECT
        $PROPERTIES = "displayName", "member"
        foreach ($i in $PROPERTIES){
            $Searcher.PropertiesToLoad.Add($i) | Out-null
        }

        # FETCH
        $RESULTS = $Searcher.FindAll()
        if ( $RESULTS -ne $null ){
            foreach ($OBJ in $RESULTS)
            {
                $USER = $OBJ.Properties            
                $members = $USER.'member'

                foreach ($member in $members) {
                    write-host "`t$member"
                }
            }
        }
        else {
            Write-host -ForegroundColor Red "`tNOT FOUND`tGROUP: " $nazwisko "`t" 
        }
    }
    else {
        Write-host -ForegroundColor DarkYellow "`rDOMAIN CONNECTION FAILURE`r";
    }
}

# GLOBAL VARIABLES
$DOMAIN = domain

# LIST OF GROUPS
$group_string = @"
Group Display Name 1
Group Display Name 2
Other Group Name
"@

# SPLITTING LIST OF GROUPS
$groups = $group_string.split("`n")


# FINDING MEMBERS
foreach ($group in $groups) {
    write-host $group
    get_members "$group"
}
