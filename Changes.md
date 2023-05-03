### 1.19.0
    Add: button for owner only or for all
### 1.18.0
   Add: Auto update gate script
### 1.17.0
    Add: Rounds count, you can set round to win the race by menu
### 1.16.0
    Add ignore list, now "cannonball" in gate script

### 1.15.1
    Allow gates number started from 0, for Start gate can have 0 number
    Fixed bug in aligning texts

### 1.15
    Auto detect first last gates, press "setup" to refresh it, or List to show info about it
    Press "setup" in menu of ScoreBoard , press it one after you changed, removed or added new gate, it collect gates number and considired the first and last gate as Start Finish gate

### 1.14.2
    new chate command tp to teleport to gate by index of the list, use list command first to check the index
    /gates tp
### 1.14
    check owner of command sender, now if any prim send same command on same channel will not accept, all gates should have same owner
### 1.13
    Rename up and down to Show and Hide
    Gate with height = 0 will not slide down, it switched between visible and invisible

### 1.12
    Improve sort time, make none finished in bottom

### 1.10
    show not individual time for each player, if time started by count down at the gate, if no countdown the individual time will be effected,
    start time will be cleared with clear command or after 5 min, player should pass the start gate in 5 min after Start(GO)

### 1.9
    show time by default
### 1.7
    * Fix gate number
    * Show list of info into public chat

### 1.6

    * Sort/Order scores or time result
    * Calc time between Start and Finish gates, you need to update script of gates, click "Show Time" button in menu of ScoreBoard
    * Count the gate that passed by players, counting only in series, if a player skipped a gate, count will stop unil back to the right gate
        Add number of gate in description of gate
