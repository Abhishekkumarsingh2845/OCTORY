#!/bin/zsh

# This file should be called by a LaunchAgent
# Its goal is to ensure Octory only executes when user is on the desktop.

# I suggest you create a Policy to Remove and uninstall the LaunchAgent
# We cannot do it here as LaunchAgent are executed by the user.


loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
loggedInUID=`id -u ${loggedInUser}`


app="/Library/Application Support/Octory/Octory.app"
donefile="/Users/$loggedInUser/Library/Preferences/OctoryDone"

# Check if:
# - Octory is not already running
# - Octory is signed (is fully installed)
# - User is in control (not _mbsetupuser)
# - User is on desktop (Finder process exists)
# - Done file doesn't exist

function appInstalled {
    codesign --verify "${app}" && return 0 || return 1
}

function appNotRunning {
    pgrep Octory && return 1 || return 0
}

function finderRunning {
    pgrep Finder && return 0 || return 1
}

if appNotRunning \
	&& appInstalled \
	&& [ "$loggedInUser" != "_mbsetupuser" ] || [ "$loggedInUser" != "root" ] \
	&& finderRunning \
    && [ ! -f "$donefile" ]; then

    open -a "$app"
    
    # unload the agent once Octory is launched
    /bin/launchctl bootout gui/${loggedInUID}/com.amaris.octory.launch
fi

exit 0