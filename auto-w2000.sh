#!/bin/bash
########################################################################################################################
########################################################################################################################
########################################################################################################################
#
#                      _     _                    _         _____       _       _   _
#       /\            | |   (_)                  | |       / ____|     | |     | | (_)
#      /  \   _ __ ___| |__  _ _ __ ___   ___  __| | ___  | (___   ___ | |_   _| |_ _  ___  _ __  ___
#     / /\ \ | '__/ __| '_ \| | '_ ` _ \ / _ \/ _` |/ _ \  \___ \ / _ \| | | | | __| |/ _ \| '_ \/ __|
#    / ____ \| | | (__| | | | | | | | | |  __/ (_| |  __/  ____) | (_) | | |_| | |_| | (_) | | | \__ \
#   /_/    \_\_|  \___|_| |_|_|_| |_| |_|\___|\__,_|\___| |_____/ \___/|_|\__,_|\__|_|\___/|_| |_|___/
#
#
########################################################################################################################
########################################################################################################################
#
#                       888                                  .d8888b.   .d8888b.   .d8888b.   .d8888b.
#                       888                                 d88P  Y88b d88P  Y88b d88P  Y88b d88P  Y88b
#                       888                                        888 888    888 888    888 888    888
#      8888b.  888  888 888888 .d88b.         888  888  888      .d88P 888    888 888    888 888    888
#         "88b 888  888 888   d88""88b        888  888  888  .od888P"  888    888 888    888 888    888
#     .d888888 888  888 888   888  888 888888 888  888  888 d88P"      888    888 888    888 888    888
#     888  888 Y88b 888 Y88b. Y88..88P        Y88b 888 d88P 888"       Y88b  d88P Y88b  d88P Y88b  d88P
#     "Y888888  "Y88888  "Y888 "Y88P"          "Y8888888P"  888888888   "Y8888P"   "Y8888P"   "Y8888P"
#
########################################################################################################################
########################################################################################################################
########################################################################################################################
#
# VARIABLES DEFINITION
#
########################################################################################################################
DIR_BASE="$HOME/scripts/auto-w2000"
DIR_DATA="$DIR_BASE/data"
DIR_DOWNLOAD="$DIR_BASE/src"
DIR_HASH="$DIR_BASE/hash"
HASH=''
W2000_MATCH_PATTERN='#\s+\[Start of entries generated by MVPS HOSTS\]'
W2000_URL='http://winhelp2002.mvps.org/hosts.zip'
SYSTEM_HOSTS_FILE='/etc/hosts'

########################################################################################################################
#
# FLAGS DEFINITION
#
########################################################################################################################
PROCEED=false
UPDATE_OK=false

########################################################################################################################
#
# CODE START
#
########################################################################################################################
mkdir -p ${DIR_DOWNLOAD}
mkdir -p ${DIR_HASH}

cd ${DIR_DOWNLOAD}

# Try to download new hosts file
if curl -O "${W2000_URL}" > /dev/null 2>&1 ;
then
    # Extract hash from downloaded file
    HASH=$(sha256sum "${DIR_DOWNLOAD}/hosts.zip" | cut -d ' ' -f1)
    # Check if dat file exist
    if [[ -s "${DIR_HASH}/last_check.dat" ]]
    then
        # File exist.. check if HASHes equals
        if grep -q "${HASH}" "${DIR_HASH}/last_check.dat" ; then
            PROCEED=false
        else
            PROCEED=true
        fi
    else
        # Script first run... last_check.dat not found
        PROCEED=true
    fi
else
    # Error on download
    PROCEED=false
fi

# Elaborate data
if [[ "${PROCEED}" == true ]] ;
then
    # Remove previous data
	rm -rf "${DIR_DATA}"
	# Unzip data
	if unzip -d "${DIR_DATA}" "${DIR_DOWNLOAD}/hosts.zip" ;
	then
	    # Extract old hosts content
        awk "/${W2000_MATCH_PATTERN}/{stop=1} stop==0{print}" < "${SYSTEM_HOSTS_FILE}" >> "${DIR_DATA}/HOSTS_TO_MAINTAIN"
        # Clean downloaded hosts file
        awk "/${W2000_MATCH_PATTERN}/{f=1}f" "${DIR_DATA}/HOSTS" > "${DIR_DATA}/HOSTS_CLEAN"
        # Concat in one new file
        cat "${DIR_DATA}/HOSTS_TO_MAINTAIN" <(echo) "${DIR_DATA}/HOSTS_CLEAN" > "${DIR_DATA}/HOSTS_NEW"
		UPDATE_OK=true
	fi
fi

# Proceed to update system hosts file
if [[ "${UPDATE_OK}" == true ]] ;
then
    # Safety copy
	cp -f "${SYSTEM_HOSTS_FILE}" "${SYSTEM_HOSTS_FILE}.bak"
	# Overwrite with new file
    mv -f "${DIR_DATA}/HOSTS_NEW" "${SYSTEM_HOSTS_FILE}"
    # Clean up data folder
    rm -rf "${DIR_BASE}/data"
    # Clean up src folder
    rm -rf "${DIR_BASE}/src"
    # Set last succesful hash
    printf %s ${HASH} > "${DIR_HASH}/last_check.dat"
fi

########################################################################################################################
#
# CODE END
#
########################################################################################################################
