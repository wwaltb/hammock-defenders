#!/bin/sh

. /opt/muos/script/var/func.sh

LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/Hammock Defenders"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
BINDIR="$LOVEDIR/bin"

# Logging
> "$LOVEDIR/log.txt" && exec > >(tee "$LOVEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"
export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

# Run Application
$GPTOKEYB "love" -c "controls.gptk" &
./bin/love .

kill -9 "$(pidof gptokeyb2)"
