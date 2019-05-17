#!/bin/bash
getCreds(){

#stuff for pashua
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"


#set username, password, and JSS location
jssAddress="https://YOURJSSADDRESS:8443"
jssAPIUsername=${USER}
savePW=0
while (true) do
#read the password if it exists, otherwise get a new password
if ! jssAPIPassword=$(security find-generic-password -a "${USER}" -s jamfscripts -w)
	then
	conf="
	*.title = JAMF password
	*.floating = 1
	jssAPIPassword.type = password
	jssAPIPassword.label = Please enter the JAMF password for ${jssAPIUsername}
	savePW.type = checkbox
	savePW.label = Save password in keychain?
	"
	pashua_run "$conf"
fi
#now test the password
myOutput=$(curl -H "Accept: application/xml" -su "${jssAPIUsername}":"${jssAPIPassword}" -X GET "${jssAddress}"/JSSResource/jssuser)
if echo "$myOutput" | grep -q "Unauthorized"
    then
      conf="
      *.title = Wrong password
      *.floating = 1
      msg.type = text
      msg.default = The password is incorrect
      "
      pashua_run "$conf"
      security delete-generic-password -a "${USER}" -s jamfscripts
    else
      if [ "${savePW}" -eq 1 ]
        then
        security add-generic-password -a "${USER}" -s jamfscripts -w "${jssAPIPassword}"
      fi
      break
fi
done
}
