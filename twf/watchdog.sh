#!/bin/bash
# Toasted Watchdog Framework
# Now for 1.16+ !

# Watchdog build identity/version
build="Person's TWF 1.1"

# Override system user, useful if running as root
#user="$USER" # autodetect, reminder that bash is case sensitive
user="mcs"
#user="minecraft"

# Make variables persistent
set -a

# Where to find stuff
# Do not edit
execdir=$(pwd)
cfgfile=$execdir"/preferences"
modload=$cfgfile
setup="setup"

# Get system info such as cores
numCores=$(nproc)
numCoresAdjusted=$(( numCores - 1 ))

# Run the install script if firstrun doesn't exist
function firstrun(){

        undothings ()
        {
                rm firstrun 2>/dev/null
                exit 0
        }

        trap undothings INT
        echo
        echo "TWF Installation Wizard"
        echo "This script will now install the Watchdog to the server directory."
        echo "A valid server directory for TWF uses the following structure:"
        echo "Folder [userhome]/[instancename]Server/, containing folders:"
        echo "runtime, twf, jvm, opt"
        echo "Optional folders: (in opt folder) assets, backups"
        echo
        echo "Please make sure you are running this install script AS the user that will run the server."
        echo
        echo "Continue? (Y/n):"
        read cf; case $cf in
                Y|y|""|" "|yes ) echo "";;
                *) exit 0;;
                esac
	echo "The installation script is disabled."
	echo "It has not been updated, please copy and paste, and edit configurations by hand."
	exit 1
        echo "Select a Minecraft instance by pointing to its folder, from your home folder."
        echo "Run this script again if need install to another server instance, after you're done."
        echo "Instance folder (ex: enigServer):"
        read ifolderpre
        ifolder=$HOME/$ifolderpre
        chmod +x * 2>/dev/null
        if [ -f "$ifolder/twf/watchdog" ]; then
        clear;
            echo "A old watchdog installation was detected. Remove it first?"
            echo "Keeping the old one may introduce problems. Say y (yes) here if you are unsure."
            echo "(Y/n):"
            read ci; case $ci in
                Y|y|""|" "|yes ) rm -rfv $ifolder/twf/* ; echo "";;
                *) echo -n "";;
                     esac
            fi
            
        echo "Copying files... "
        mkdir $ifolder/twf 2>/dev/null
        touch firstrun
        cp -r * $ifolder/twf || echo 'Failed to copy files. Ignore this if you are just updating a existing watchdog.' || exit 1 
       # echo 
       # echo "Enter the name of this Minecraft instance. This is important to get right."
       # echo "Instance name (ex: enig) (ex2: revel):"
       # read iname
       suffix="Server"
       iname=${ifolderpre%"$suffix"}
        packidString="Server"
        packidAppend=$iname
        packid=$packidAppend$packidString
        longPackID=$packid
        
        echo "Enter the full name of the server as you'd like it to appear in the Watchdog's messages and prompts."
        echo "Server name (ex: My Cool Vanilla Server):"
        read pname
clear;
        echo "Is this pack going to use the system Java (system) or a custom Java executable? (custom)"
        read jarchoice
        case $jarchoice in
                "custom") echo "Using Custom Java at /home/$user/$longPackID/jvm/current/bin/java"; seljar="/home/$user/$longPackID/jvm/current/bin/java";;
                "system") echo "Using System Java (java)"; seljar="java";;
        esac 
clear;
        echo "Which jar is this server going to use?"
        echo "List of jars found in the server directory:"
        echo $(ls -a $ifolder/runtime | grep -i -F --color=always ".jar" | grep -v --color=always ".log");
        echo
        echo "Answer with the exact, full name of the jar file, including the .jar extension. (you can copy, and paste)"
        echo "eg. forge-x.xx.x-xx.xx.x.xxxx-universal.jar"
        echo "Or leave blank to use the default name of server.jar"
        read jarname
        if [ "$jarname" == "" ]; then
            jarname="server.jar"
        fi
clear;
        echo "How much memory will the server be able to use?"
        echo "eg. \"2048M\" for 2GBs of heap size. You can also directly use \"G\", such as in \"2G\""
        echo "Or leave blank to use the default of 6G."
        read ram
        if [ "$ram" == "" ]; then
            ram="6G"
        fi
clear;
        # Holy moly this is some spaghetti.
        # It basically writes the configuration to a file, in bash.
        # I despise it.
        
        echo "Installing new configuration... "
        dgen=$(date)
        touch setup
        echo "#!/bin/bash" > setup
        echo "# File automatically generated @ "$dgen >> setup
        echo 'set -a' >> setup
        echo "" >> setup
        echo "packidAppend="\"$packidAppend\" >> setup
        echo "packid="\"$packidAppend\" >> setup
        echo "pack=""\"$pname\"" >> setup
        
        # Reference the folder again just because we can
        iffolder="$ifolder/twf/"
        
        echo "fpid="\"$packid\" >> setup
        echo "longPackID=\"$packid\"" >> setup
        echo "shortPackID=\"$packidAppend\"" >> setup
        echo "lookFor=$packid/runtime" >> setup
        echo "jarname=\"$jarname\"" >> setup
        echo "javainstance=\"$seljar\"" >> setup
        echo "ram=\"$ram\"" >> setup
        
        # Set the JVM Args to what cpw thinks is best.
        echo 'executable="$javainstance -Xmx$ram -Xms$ram -XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=30 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -jar /home/$user/$longPackID/runtime/$jarname nogui"' >> setup
        
        cp -r setup $iffolder
        ln -s $iffolder/watchdog.sh $iffolder/watchdog
        echo ""
        echo "Installing TWF to the local shell..."
        echo "Currently this only supports Bash."
        
            if [ -f "/home/$user/.twf" ]; then
            echo "An old TWF function file already exists. Remove it?"
            echo "Answer n (no) here safely if you don't know what this means."
            echo "Answer d (don't add), to not add an entry."
            echo "(y/N/d):"
            
            # reuse cf variable
            unset cf
            read cf; case $cf in
                N|n|""|" "|no ) echo -n "";;
                d|D ) dontAdd=true ;;
                *) rm /home/$user/.twf;;
                     esac
            fi
            
            if [ "$dontAdd" != "true" ]; then
        echo "[1/3] RunAnywhere for "$packidAppend
        echo "function" $packidAppend'(){' >> /home/$user/.twf;
        echo "currentDir="'$(pwd)' >> /home/$user/.twf;
        echo "cd $iffolder" >> /home/$user/.twf;
        echo './'"watchdog"' $@' >>/home/$user/.twf;
        echo "cd "'$currentDir' >> /home/$user/.twf;
        echo '}' >> /home/$user/.twf;
        echo "[2/3] RunAnywhere for twf-$packidAppend & watchdog-"$packidAppend;
        
        echo "alias watchdog-$iname=$iname" >> /home/$user/.twf;
        echo "alias twf-$iname=$iname" >> /home/$user/.twf;

        duplicateCheck=$(cat /home/$user/.bashrc | grep -i "Added by TWF")
                if [ "$duplicateCheck" == "" ]; then
        echo ". /home/$user/.twf # Added by TWF" >> /home/$user/.bashrc;
                fi
                  echo "You may now run the following commands from any place in the server terminal:"
                  echo "watchdog-$iname"; echo "twf-$iname"; echo "$iname"
            fi
            dontAdd="false"
        rm firstrun 2>/dev/null
        rm $clonefile 2>/dev/null
        rm setup 2>/dev/null
clear;
        echo "Installation is finished." 
        echo "Edit the configuration file at "$iffolder"preferences to this server's needs."
        echo "Or, check out the commands $iname config, and $iname config-setup"
        . /home/$user/.bashrc

}

if [ ! -f "firstrun" ]; then
firstrun; exit 0
fi

# load variables
. $cfgfile || exit 1 || echo "[FATAL] Couldn't load configuration file."

if [ "enforceCfg" != true ]; then
. $setup
fi

# I was experimenting with arrays.
function threadingHandler () 
{
        undothings ()
        {
                rm .threadinfo 2>/dev/null
                exit 0
        }
                        trap undothings INT

                unset thCounter
                declare -i thCounter=0
                touch .threadinfo
                spinner spinnerDummy &
                echo -n "[INFO] Calculating timings. Please wait."

                threadTickTimeArray=()
                threadSpacingArray=()

                while [ "$thCounter" -lt 4 ]; do
        # Calculate optimal values for threading. defaults:
        # threadTickTime="0.66"
        # masterThreadTickTime="3.66"
        # threadSpacing="0.66"
        # numThreads="2"
        numCores=$(nproc)
        numCoresAdjusted=$(( numCores - 1 ))
        if [ "$numCoresAdjusted" -lt 1 ]; then
        numCoresAdjusted=$numCores
        numThreads=$numCoresAdjusted
        else
        numThreads=$numCoresAdjusted
        fi
        baseSleepNumber=$(bc <<< "scale=3; 1 / $numCoresAdjusted")
        baseThreadSpacing=$(bc <<< "scale=3; 1 / $numCores")
        weight=$(bc <<< "scale=3; $numCoresAdjusted / 50");
                        load=$(cat /proc/loadavg)
                        for loadNumber in $load
                        do
                        echo $loadNumber > .threadinfo
                        break;
                        done
        
         sleepNumberModifierBase=$(ps -h -w -w | grep -i "java" | grep -v "tmux" | wc -l);
         sleepNumberModifier=$(bc <<< "scale=3; $weight * $sleepNumberModifierBase * $loadNumber");

                threadTickTime=$(bc <<< "scale=3; $baseSleepNumber + $sleepNumberModifier");
                
                threadSpacingModifier=$(bc <<< "scale=3; $loadNumber * $weight * 3")
                threadSpacing=$(bc <<< "scale=3; $baseThreadSpacing + $threadSpacingModifier")
                masterThreadTickTime=$(bc <<< "scale=2; $threadTickTime * 6 * $loadNumber")
        echo "Thread Tick Time -> $threadTickTime sec" > .threadinfo
        echo "Master Tick Time -> $masterThreadTickTime sec" >> .threadinfo
        echo "Thread Spacing -> $threadSpacing sec" >> .threadinfo
        echo "Thread Count -> $numThreads" >> .threadinfo

                threadTickTimeArray[$thCounter]=$threadTickTime
                threadSpacingArray[$thCounter]=$threadSpacing

                sleep $threadTickTime
                ((thCounter++))


done
        rm .threadinfo 2>/dev/null

                threadSpacing=$(bc <<< "scale=3; ${threadSpacingArray[1]} + ${threadSpacingArray[2]} + ${threadSpacingArray[3]} + ${threadSpacingArray[0]} / 4")
                threadTickTime=$(bc <<< "scale=3; ${threadTickTimeArray[1]} + ${threadTickTimeArray[2]} + ${threadTickTimeArray[3]} + ${threadTickTimeArray[0]} / 4")
        echo ""
        echo "[INFO] Calculated timings (tt/mt/ts/tc) -> $threadTickTime | $masterThreadTickTime | $threadSpacing | $numThreads"
}

function spinnerDummy(){

        decoy=".threadinfo"
        while [ -f "$decoy" ]; do
                sleep 0.05
        done

}

function expandAnnoucement(){

                        loadnow=$(echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')])
                        memtotal=$(awk '/MemTotal/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo)
                        usemem=$(awk '/MemFree/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo)
                        usemem=$(bc <<< "scale=2; $memtotal - $usemem");
                        totalmem=$(bc <<< "scale=2; $memtotal * 1" );

}

# Expose arguments and set some things
    # Race condition handling with even more race conditions.
    filew=".w"
    filey=".y"
    filex=".x"
    # No idea why I use this with set -a
 exportedArgs="$@"
 exportedSone=$1
 exportedStwo=$2
 exportedSthree=$3
 lookForCMD="$executable"
# Fix permissions
chmod +x $cfgfile 2>/dev/null
chmod +x setup 2>/dev/null
# Register Pack ID
shortPackID=$packidAppend
longPackID=$fpid

function startMinecraft(){
unset act
        act="start"; MCManager;
}

function sendSaveOn(){
	echo "Started sendSaveOn daemon"
	sleep 20
	set -a
	command="save-on"
	sendCommand;
	bossbarID="o"
	bossbarRoutines visible false;
	echo "Stopped sendSaveOn daemon"
}

function MCManager(){
set -a
        # Manage MC's startup/shutdown sequences
        # Performant alternative to LGSM
loadVars;
lookForCMD="$executable"
        if [ "$act" == "stop" ]; then
        touch .threadinfo
        spinner spinnerDummy &
        echo "[INFO] Sent shutdown signal to server. This may take up to one minute to take effect."
        echo "[INFO] Using $build's MCManager"
        command="stop"; sendCommand; sleep 1
        command="stop"; sendCommand;
        declare -i counter=0
        nl=$(ps -h -w -w | grep -v "tmux" | grep -i $lookFor | grep -v "grep" | wc -l);
                while [ "$nl" != "0" ]; do
                sleep 1; ((counter++));
                if [ "$counter" -gt 30 ]; then
                        if [ "$countedto30" != "true" ]; then
                        command="save-all flush"; sendCommand;
                        msgAppend="Flushing all chunks to disk! Server will be killed soon if it doesn't stop."; broadcastInternal;
                        countedto30="true"
                        fi
                fi
                if [ "$counter" -gt 100 ]; then
                pkill -9 -x -f "$lookForCMD";
                echo "[INFO] Server was killed. Oof."; break;
                countedto30="false"
                fi
                nl=$(ps -h -w -w | grep -v "tmux" | grep -i $lookFor | grep -v "grep" | wc -l);
                done
                unset counter
                unset skip
                rm $clonefile 2>/dev/null
                tmux kill-session -t $shortPackID 2>/dev/null
                rm .threadinfo 2>/dev/null
                echo "[INFO] Shutdown successful."; exit 0
        fi

        if [ "$act" == "start" ]; then
        touch .threadinfo
        spinner spinnerDummy &
        echo "[INFO] Starting Minecraft server: $pack"
        echo "[INFO] Using $build's MCManager"
                sleep 0.1
                nl=$(ps -h -w -w | grep -v "tmux" | grep -i $lookFor | grep -v "grep" | wc -l)
                if [ "$nl" == "0" ]; then
                currentDir3=$(pwd)
                cd /home/$USER/$longPackID/runtime/
                chmod +x $javainstance 2>/dev/null
                chmod +x $jarname || echo "[ERROR] Couldn't find Minecraft .jar, things will break."
        tmux new-session -d -s $shortPackID "$executable" 2>/dev/null || echo "[ERROR] Server already exists!"
        dated=$(date)
                cd $currentDir3
                        echo "[LOG/MCManager] Started tmux server @ "$shortPackID", @ $dated" >> $logfile
                        echo "[INFO] Started server "$shortPackID 
                        rm .threadinfo 2>/dev/null
                else
                        echo "[LOG/MCManager] Failed to start tmux server @ "$shortPackID", @ $dated" >> $logfile
			echo "MCManager request failed"
                        rm .threadinfo 2>/dev/null
                        
                fi
	sendSaveOn & disown
	sleep 0.5
        exit 0
        fi
}

function accessConsole(){

	rm /dev/shm/.nolag
        echo "[INFO] Launching MCManager console..."
        showConsoleWarning &
        tmux attach -t $shortPackID
	touch /dev/shm/.nolag
}

function stopMinecraft(){
unset act
        act="stop"; MCManager;

}

function broadcast(){

                if [ "$daemonized" == "true" ]; then
        echo "[SENT]"$msg
        tmux send -t $shortPackID "tellraw @a " \""$msg"\" ENTER
        unset msg
                fi

}

function sendCommand(){

        export command=$command
	if [ "$asRoot" == "true" ]; then
	sudo -Eu mcs tmux send -t $shortPackID "$command" ENTER 
	else
        tmux send -t $shortPackID "$command" ENTER
	fi
}

function threadCallRestartHandler(){
loadVars;
set -a
crashDate=$(date)
filew="/home/$user/.w"
        if [ ! -f "$filew" ]; then
touch $filew
                if [ ! -f "$filex" ]; then
touch $filex
                        if [ ! -f "$filey" ]; then
                # Log action
                echo "[LOG]" "Server stop detected @" "["$crashDate"], "$build >> $logfile
touch $filey

        sleep 18
        rm $filew 2>/dev/null
        rm $filex 2>/dev/null
        rm $filey 2>/dev/null
        #renice -n 9 -p $(pidof -x java) > /dev/null 2>&1
        sleep 72
        rm $filew 2>/dev/null
        rm $filex 2>/dev/null
        rm $filey 2>/dev/null
        #renice -n 19 -p $(pidof -x java) > /dev/null 2>&1
        # Catch duplicate threads
        # We must ensure Minecraft has started before doing anything else, so we wait
        rm $filey 2>/dev/null
        smtDate=$(date)
        echo "(debug) caught duplicate thread @ "$smtDate >> $logfile
        exit 1
                                        fi
                                        else
        rm $filex 2>/dev/null
        smtDate=$(date)
        echo "(debug) caught duplicate thread @ "$smtDate >> $logfile
        exit 1
                                fi
                                else
        rm $filew 2>/dev/null
        smtDate=$(date)
        echo "(debug) caught duplicate thread @ "$smtDate >> $logfile
        exit 1

        fi
}

function spawnMasterThread(){
set +a
loadVars;
        while true; do
        sleep $masterThreadTickTime
        try=$(ps -h -w -w | grep -v "tmux" | grep -i $lookFor | grep -v "grep")
                if [ "$try" == "" ]; then
                # The system can poll twf_isRunning anytime to see if the server is running or not
                # We do this from a slower thread to reduce overhead.
                echo "false" > /dev/shm/twf_isRunning
                        if [ ! -f "$lock" ]; then
                                if [ ! -f "$filew" ]; then
                        startMinecraft &
                        threadCallRestartHandler &
                                fi
                        fi
                else
                echo "true" > /dev/shm/twf_isRunning
                fi
        done
}

function spawnNormalThread(){
set +a
loadVars;
        while true; do
        sleep $threadTickTime
        tryn=$(ps -h -w -w | grep -v "tmux" | grep -i $lookFor | grep -v "grep")
                if [ "$tryn" == "" ]; then
                        if [ ! -f "$lock" ]; then
                                if [ ! -f "$filew" ]; then
                startMinecraft &
                threadCallRestartHandler &
                                fi
                        fi
                fi
        done
}

function mainLoop(){
set -a
loadVars;

# Check for silence flag
if [ "$exportedStwo" == "-s" ]; then
daemonized="false"
else
daemonized="true"
fi

# Run instance check
if [ "$isSingleInstance" == "true" ]; then
wcheck=$(ps -u $user | grep -c watchdog)
if [ ! "$wcheck" -lt "3" ]; then
        rm $filew 2>/dev/null
        echo "[ERROR]" "Another watchdog exists. Exiting with error code 1"
        exit 1

fi
fi

# Load modular functions. Can be loaded from external files as well.
. $modfile || echo "Can't find any external modules in $modfile or it is broken."

# Register functions to be loaded
        isModLoadingPhase="true"
        echo ''
        . $modload 2>/dev/null || echo "Can't find module loading directives in" $modload
        . $setup 2>/dev/null
# Complete module loading phase
        isModLoadingPhase="false"
        set -a
        sleep 0.3
        # Export some variables for safekeeping
        export > vars.dog
        echo "[INFO] Finished loading modules"
        touch .threadinfo
        echo -n "[INFO] Spawning threaded watchdog";
        spinner spinnerDummy &
# Spawn a master thread
spawnMasterThread &
sleep $threadSpacing
# Spawn normal threads
for ((n=0;n<$numThreads;n++)); do sleep $threadSpacing; spawnNormalThread &
done

# Change priority of the watchdog
#renice -n 21 -p $(pidof -x watchdog) > /dev/null 2>&1
#renice -n 20 -p $(pidof -x java) > /dev/null 2>&1
schedtool -I $(pidof java)
schedtool -I $(pidof java)
schedtool $(pidof java)

rm .threadinfo 2>/dev/null
echo ''
echo "[INFO] Applied priority values"
echo "[INFO] Finished. Press Ctrl+C to detach the watchdog from your session."
exit 0
}

showHelp(){
echo
echo "Toasted Watchdog Framework by yagoply, package" $build
echo "A watchdog that watches a Minecraft server, automating a few aspects of maintenance,"
echo "and a shell toolkit for Minecraft servers."
echo
echo "Toasted Watchdog Commands | Usage:"
echo "  d, -d, daemonize -> daemonize, run in as a service in the background"
echo "  l, -l, lock, pause -> lock, will lock the watchdog preventing it from doing anything"
echo "  ul, -ul, unlock, resume -> unlock, will unlock the daemon, restoring functionality"
echo "  k, -k, kill ->  kills the daemon, stopping all of its functions"
echo "  b, -b [MESSAGE] -> broadcast a message to the server"
echo "  p, -p -> toggles the ProtectAdmin module to shoot lightning bolts at things near you. Configure your username with the \"config\" option."
echo "  config -> opens the watchdog's configuration file for edits"
echo "  config-setup -> opens the watchdog's secondary configuration file for edits"
echo "  config-file [FILE] -> edits a file of this server instance (runtime folder)"
echo "  schedule [restart/stop] [time in minutes] // (reason) -> schedules a server stop or restart"
echo "  cleanlogs -> cleans up this Minecraft instance's logs, and the watchdog's logs as well."
echo "  mclog (watch) -> shows the latest Minecraft log. If you use \"mclog watch\" it will open the console in read-only mode. It doesn't have a warning or waiting time and is good for a quick peek."
echo "  wlog (watch) -> shows the latest Toasted Watchdog log. \"wlog watch\" will constantly update your view of the log."
echo
echo "MCManager Commands | Usage:"
echo "  start -> starts the Minecraft server instance"
echo "  stop -> stops the Minecraft server instance"
echo "  c, console -> attempts to connect to the remote console of this instance"
echo "  restart -> restarts the server"
}

function killWatchdog(){
loadVars;
set -a
echo "Killing existing watchdog..."
echo "Priming next watchdog!"
rm $filew 2>/dev/null
rm $filex 2>/dev/null
rm $filey 2>/dev/null
daemonized="false"
killall -s 9 watchdog || echo "(2) Could not find a watchdog to kill."; exit 2
killall -s 9 bash watchdog
echo "Watchdog has been unlocked and primed"
rm $lock 2>/dev/null
rm $filew 2>/dev/null

exit 0
}

function spinner(){
 if [ "$useSpinner" == "true" ]; then
	echo "[...]"
 fi
}

function showConsoleWarning(){
if [ "$showWarning" == "true" ]; then 
        declare -i scounter=0
while [ "$scounter" -lt 1 ]; do
  sleep 0.8
  ((scounter++))
 echo -ne "\e[5m \e[92m << Press CTRL + B, then D to quit. Do NOT press Ctrl + C. >> \e[0m"
 tmux send -t $shortPackID ENTER 2>/dev/null
done
        exit 0
fi
}

function daemonize(){
set -a
if [ "$useThreadedCalculation" == "true" ]; then
    threadingHandler;
    else
         threadTickTime="3"
         masterThreadTickTime="5"
         threadSpacing="0.1"
         numThreads="2"
fi
export daemonized="true"
daemonized="true"
mainLoop & disown
exit 0
}

function lock(){
if [ -f "$lock" ]; then
echo "[ERROR] Watchdog is already locked"; exit 3
else
touch $lock
fi
}

function unlock(){
rm $lock 2>/dev/null || echo "[ERROR] Watchdog is already unlocked"; exit 4
}

function broadcastMessage(){

daemonized="true"
tag="  §6[Broadcast]§r"
preMsg=$tag$exportedArgs
preMsg=$(echo $preMsg | sed 's/\-b//g') 
space=" "
msg=$space$preMsg
broadcast; daemonized="false"
unset msg;
}

function broadcastInternal(){
loadVars;
rand="a"
daemonized="true"
if [ "$isDebug" == "true" ]; then
tag=" §d[F/DEBUG]§r "
else
tag=""
fi
msg=$tag$msgAppend; broadcast; daemonized="false"; isDebug="false"
}

function applyUpdate(){
loadVars;
sleep 0.1
msgAppend="Reloading the watchdog..."; broadcastInternal
sleep 0.8
. $execdir/watchdog -d &
disown
exit 0
}

function scheduleManual(){
set -a
loadVars;
echo $exportedStwo
case "$exportedStwo" in
        "stop"|"shutdown"|"close")
        isStop="true"
        ;;
        "restart"|"reboot"|"reset")
        isStop="false"
        ;;
        *)
        echo "Invalid input. Use stop or restart followed by a time in minutes."; exit 1
        ;;
esac

export lock=$lock
declare -i timeInMinutes=0
declare -i timeInSeconds=0
timeInMinutes=$exportedSthree

# Calculate time
timeInSeconds=$(( $timeInMinutes * 60 ));
# Add 1 to prevent bugginess
timeInSeconds=$(( $timeInSeconds + 1 ));
# Calculate time for each case
timeIfGt15Min=$(( $timeInSeconds - 900 ));
timeIfGt5Min=$(( $timeInSeconds - 300 ));
timeIfGt1Min=$(( $timeInSeconds - 60  ));
echo "Starting countdown. Do Ctrl+C to unlock your terminal."

if [ "$isStop" == "true" ]; then
        msgAppend="Staff has scheduled a server stop for "$timeInMinutes" minutes from now."; export msgAppend=$msgAppend; broadcastInternal;
else
        msgAppend="Staff has scheduled a server restart for "$timeInMinutes" minutes from now."; export msgAppend=$msgAppend; broadcastInternal;
fi

msgAppend="Reason: "$reason; export msgAppend=$msgAppend; broadcastInternal;

if [ "$timeIfGt15Min" -gt 0 ]; then
alreadySlept="true"
sleep $timeIfGt15Min
export msgAppend='Server stopping in 15 minutes'; . $execdir/watchdog -i
sleep 600
export msgAppend='Server stopping in 5 minutes'; . $execdir/watchdog -i
sleep 240
export msgAppend='Server stopping in 1 minute'; . $execdir/watchdog -i
sleep 60; didWait="true"
fi 

if [ "$timeIfGt5Min" -gt 0 ]; then
if [ "$alreadySlept" != "true" ]; then 
alreadySlept="true"
sleep $timeIfGt5Min
export msgAppend='Server restarting in 5 minutes'; . $execdir/watchdog -i
sleep 240
export msgAppend='Server restarting in 1 minute'; . $execdir/watchdog -i
sleep 60 ; didWait="true"
fi
fi 

if [ "$timeIfGt1Min" -gt 0 ]; then 
if [ "$alreadySlept" != "true" ]; then 
alreadySlept="true" 
sleep $timeIfGt1Min
export msgAppend='Server restarting in 1 minute'; . $execdir/watchdog -i
sleep 60; didWait="true"
fi
else
if [ "$timeInMinutes" == "0" ]; then
echo "Executing restart immediately."
didWait="true"
else
echo "This amount of time is not supported. Try 0 or >1 minutes."
exit 1
fi
fi 

if [ "$didWait" == "true" ]; then
        if [ "$isStop" == "true" ]; then
        # stopServer;
        touch $lock
        skip="true";
        act="stop"; MCManager
        else
        # rebootServer;
        rm $lock 2>/dev/null
        skip="true";
        act="stop"; MCManager
        rm $lock 2>/dev/null
        fi
fi

alreadySlept="false"; didWait="false"
exit 0
}

function scheduleHandler(){
set -a
loadVars;
echo "Input a reason to make this scheduled action, then press enter."
echo "To cancel now, press Ctrl+C. This action cannot be cancelled anymore if you press ENTER."
read reason
scheduleManual &
disown
}

function protectAdmin(){
# Doesn't work
set -a
loadVars;
echo "[INFO] protectAdmin function running on "$shortPackID
while true; do
if [ ! -f ".p" ]; then
sleep 1.65
command="execute "$adminName" ~ ~ ~ execute @e[name=!"$adminName",x=~,y=~,z=~,r=6] ~ ~ ~ summon lightning_bolt ~ ~ ~"; export command=$command; sendCommand;
else
exit 0
fi
done
}

function doTogglePA(){
# Doesn't work
        if [ "$exportedStwo" != "" ]; then
                adminName=$exportedStwo
                export adminName=$exportedStwo
                echo "[INFO] Set admin's name as $adminName"
        fi
if [ ! -f ".v" ]; then
touch .v
echo "ProtectAdmin set to enabled"
else
touch .p
sleep 2
rm .p 2>/dev/null
rm .v 2>/dev/null
echo "ProtectAdmin set to disabled"
fi
}

logCleaner(){
        echo "This will delete all logs and crash reports of the $shortPackID instance!"
        echo "Press Enter to confirm, Ctrl+C to cancel."
	if [ "$skip" != "true" ]; then
        read confirm
	fi
        echo ""
        echo "[INFO] Removing log files"
	curdirsp=$(pwd)
	cd /home/$user/$longPackID/runtime/logs
        ls /home/$user/$longPackID/runtime/logs/ | grep -vi latest.txt | xargs rm -v
        cd $curdirsp
	unset curdirsp
	echo "[INFO] Removing crash reports"
        rm -v /home/$user/$longPackID/runtime/crash-reports/*
        echo "[INFO] Removing twf log file"
        rm -v $logfile

}

function showLog(){
        numLines=$(tput lines) || numLines=16
        ((numLines - 2))
if [ "$exportedStwo" == "watch" ]; then
        fe ()
        {
        echo '[twf] You are using the dynamic log view. Ctrl+C to exit.'; echo '------------' "$longPackID"',' "$pack" '-------------';  tail -n $numLines $logfile
        }
        export -f fe
        watch -t -n 0.1 -x bash -c fe
        else
cat $logfile
        fi
}

function showMCLog(){
        numLines=$(tput lines)
        numLines=$((numLines - 1))
        if [ "$exportedStwo" == "watch" ]; then
        fe ()
        {
        tail -q -n $numLines /home/"$USER"/"$longPackID"/runtime/logs/latest.log
		#echo "-"
		#echo "-"
        }
        export -f fe
        watch -t -n 0.2 -x sh -c fe
        else
cat /home/$user/$longPackID/runtime/logs/latest.log
        fi
}
function loadVars(){
source vars.dog 2>/dev/null
}

stopPrompt(){
if [ "$skip" != "true" ]; then
        if [ -f "$lock" ]; then
        echo "The watchdog is locked. The server will not start back up automatically after you stop it."
        echo "Pressing enter will continue anyway. Press Ctrl + C to cancel the server stop."
        echo
        echo "To unlock the watchdog: \"watchdog -ul\", to lock it: \"watchdog -l\" "
        read x
        unset x
        else
        echo "The watchdog is unlocked. The server will start itself up immediately after you stop it."
        echo "Pressing enter will continue anyway. Press Ctrl + C to cancel the server stop."
        echo
        echo "To unlock the watchdog: \"watchdog -ul\", to lock it: \"watchdog -l\" "
        read x
        unset x
        fi
fi
echo -n ""
}

rmLocks(){

        rm $lock 
        rm $filew
        rm $filex
        rm $filey
        rm .wdr

}

serverConfigHandler(){

        file=$exportedStwo
        nano /home/$user/$longPackID/runtime/$file

}

bossbarRoutines(){
# Do magic with bossbars

if [ "$1" == "" ]; then
argB="$exportedStwo"
else
argB="$1"
fi

if [ "$2" == "" ]; then
argC="$exportedSthree"
else
argC="$2"
fi

	# handle visibility bool
	if [ "$argC" == "" ]; then
		argC="$bossbarVisible"
	fi

	#echo "argB=$argB"

	# hmm this reminds me of yandere dev code
	# fortunately this is run so infrequently it probably doesn't matter
	# if any competent programmer is seeing this, pardon me!

	# First, target a bossbar by their id
	# export bossbarID=""	
	# bossbarID="opti"

	# Set bossbar name
	# export bossbarName=""
	# bossbarName="Potatoes are cool"
	
	if [ "$argB" == "name" ]; then
		echo "changing $bossbarID bossbar's name to $bossbarName"
		command="bossbar set minecraft:$bossbarID name \"$bossbarName\""; sendCommand
	elif [ "$argB" == "color" ]; then
		echo "changing $bossbarID bossbar's color to $bossbarColor"
		command="bossbar set minecraft:$bossbarID color $bossbarColor"; sendCommand
	elif [ "$argB" == "visible" ]; then
		echo "changing $bossbarID bossbar's visibility to boolean $argC, and targeting all players"
                command="bossbar set minecraft:$bossbarID visible $argC"; sendCommand
		command="bossbar set minecraft:$bossbarID players @a"; sendCommand
		command="bossbar set minecraft:$bossbarID visible $argC"; sendCommand
	elif [ "$argB" == "create" ]; then
		echo "creating bossbar $bossbarID with default name \"$bossbarID\" and style n6, max 6"
		command="bossbar add $bossbarID \"$bossbarID\""; sendCommand
		command="bossbar set $bossbarID style notched_6"; sendCommand
		command="bossbar set $bossbarID max 6"; sendCommand
	elif [ "$argB" == "value" ]; then
		echo "changing value of bossbar $bossbarID to $bossbarValue"
		command="bossbar set minecraft:$bossbarID value $bossbarValue"; sendCommand
	fi
		echo
		echo "--"
		echo "bossbarRoutines, part of twf"
		echo "possible arguments: name, color, visible, create, value"
		echo "possible variables: bossbarID, bossbarName, bossbarColor, bossbarVisible, bossbarValue"
	
}

# Decide what to run
case "$1" in 
        "-k"|"kill"|"k")
               killWatchdog
                ;;
        "-h"|"help"|"h")
                showHelp
                ;;
        "-d"|"daemon"|"d")
                daemonize
                ;;
	"bossbar")
		bossbarRoutines
		;;
        "-l"|"lock"|"pause"|"l")
                lock
                ;;
        "-ul"|"unlock"|"resume"|"ul")
                unlock
                ;;
        "-up"|"update"|"reload")
                applyUpdate
                ;;
        "-b"|"b")
                broadcastMessage
                ;;
        "-i")
                broadcastInternal
                ;;
        "schedule")
                scheduleHandler;
                ;;
        "yagoisbad")
                echo "no u";
                ;;
        "-c")
                sendCommand;
                ;;
        "-p"|"p")
                doTogglePA; protectAdmin &
                ;;
        "wlog"|"--wlog")
                showLog
                ;;
        "mclog"|"log"|"rc")
                showMCLog
                ;;
        "start"|"-su"|"spinup")
                unset act; act="start"; MCManager
                ;;
        "restart"|"reboot")
                echo "[INFO] Running MCManager twice."; skip="true"; unset act; act="stop"; MCManager; act="start"; MCManager;
                ;;
        "stop"|"-st"|"shutdown")
                stopPrompt; unset act; act="stop"; MCManager
                ;;
        "-v"|"listvars")
                cat vars.dog || echo "[ERROR] The watchdog needs to be run once with "-d" to generate a variable list.";
                ;;
        "cleanlogs")
                logCleaner
                ;;
        "config-setup")
                nano watchdog.setup.cfg
                ;;
        "config")
                nano watchdog.cfg
                ;;
        "config-file")
                serverConfigHandler
                ;;
        "rmlocks")
                echo "[INFO] Removing all locks..."; rmLocks 2>/dev/null;
                ;;
        "folder")
                cd $execdir; exit 0
                ;;
        "console"|"c")
                accessConsole
                ;;
	"wadd")
		toAdd="$exportedStwo"; command="whitelist add $exportedStwo"; sendCommand; echo "Added $exportedStwo to the whitelist."; exit 0
		;;
	"import")
		echo "imported watchdog functions."
		;;
         *)     
                showHelp; echo "[ERROR] Unknown command or no command specified "; exit 1
                ;;
esac

