/**
    @name: PerformersBoard
    @description:

    @author: Zai Dium
    @version: 0.17
    @updated: "2023-05-05 16:04:10"
    @revision: 283
    @localfile: ?defaultpath\Performers\?@name.lsl
    @license: MIT

    @ref:

    @notice:
        Use button names like "Signup", you can use capital letter in prim names, but in message recieved to compare use small letter
        Button recieved as "button.signup"

*/

//* settings

string FontName = "Impact-512";

integer ShowTips = FALSE; //* Show tips amount in console board
integer AskTimes = FALSE; //* Show times available when start
integer DefaultTime = 0; //* default time for performer, in seconds, keep it 0 to make it open time

integer WarnBefore = 1; //* in minutes
integer WarnTimes = 4; //* in minutes
integer RoundTime = 1; //* in minutes, this fix the time to start at right time in minutes
integer ExtendTime = 15;//* in minutes

integer Particles = FALSE;

list MoneyList = [2, 4, 6, 8];

integer interval = 1;

//* variables

string HomeURI;

integer infoLines = 4;
integer maxLineLength = 32;
integer maxNameLength = 20;
integer maxNumberLength = 4;
integer maxTimeLength = 5;

/**
    Utils
*/
integer toBool(string s)
{
    if ((llToLower(s) == "true") ||  (llToLower(s) == "on"))
        return TRUE;
    else
        return (integer)s;
}

string alignTextLeft(string s, integer maxLength, string char) {
    integer c = llStringLength(s);
    if (c > maxLength) {
        s = llGetSubString(s, 0, maxLength - 1);
    } else
        while (c < maxLength) {
            s = s + char;
            c++;
        }
    return s;
}

string alignTextRight(string s, integer maxLength, string char) {
    integer c = llStringLength(s);
    if (c > maxLength) {
        s = llGetSubString(s, 0, maxLength - 1);
    } else
        while (c < maxLength) {
            s = char + s;
            c++;
        }
    return s;
}

list setItem(list a_list, integer index, integer a_value) {
    return llListReplaceList(a_list, [a_value], index, index);
}

list incItem(list a_list, integer index, integer a_value) {
    return llListReplaceList(a_list, [llList2Integer(a_list, index) + a_value], index, index);
}

debug(string s)
{
    llSay(0, s);
}

printText(string s, string box)
{
    llMessageLinked(LINK_ROOT, 0, s, "fw_data:"+box);
}

/**
    Script
*/

list id_list = [];
list name_list = [];
list time_list = [];

integer endTime = 0;
key performerID = NULL_KEY;
integer lastWarnTime = 0;

integer total_amount = 0;
integer permitted = FALSE;

key notecardQueryId;
integer notecardLine;
string notecardName = "Config";

list timesStrings = ["3m", "30", "60m", "1h30m", "2h", "2h30m", "3h", "4h", "5h", "6h", "12h"];
list timesValues = [3, 30, 60, 90, 120, 150, 180, 240, 300, 360, 720];

//* https://wiki.secondlife.com/wiki/Unix2StampLst
list Unix2StampList(integer vIntDat){
    if (vIntDat / 2145916800){
        vIntDat = 2145916800 * (1 | vIntDat >> 31);
    }
    integer vIntYrs = 1970 + ((((vIntDat %= 126230400) >> 31) + vIntDat / 126230400) << 2);
    vIntDat -= 126230400 * (vIntDat >> 31);
    integer vIntDys = vIntDat / 86400;
    list vLstRtn = [vIntDat % 86400 / 3600, vIntDat % 3600 / 60, vIntDat % 60];

    if (789 == vIntDys){
        vIntYrs += 2;
        vIntDat = 2;
        vIntDys = 29;
    }else{
        vIntYrs += (vIntDys -= (vIntDys > 789)) / 365;
        vIntDys %= 365;
        vIntDys += vIntDat = 1;
        integer vIntTmp;
        while (vIntDys > (vIntTmp = (30 | (vIntDat & 1) ^ (vIntDat > 7)) - ((vIntDat == 2) << 1))){
            ++vIntDat;
            vIntDys -= vIntTmp;
        }
    }
    return [vIntYrs, vIntDat, vIntDys] + vLstRtn;
}

integer clearParticlesAfter = 3; //* after seconds

clearParticles()
{
    llParticleSystem ([]);
}

sendParticles(key target)
{
    clearParticlesAfter = 3;
    llParticleSystem (
    [
        PSYS_PART_FLAGS, PSYS_PART_TARGET_POS_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_SRC_BURST_PART_COUNT, 15,
        PSYS_SRC_BURST_RATE, 0.4,
        PSYS_PART_MAX_AGE, 1,

        PSYS_SRC_OMEGA, <0.25, 0.25, 0.25>,
//        PSYS_PART_START_SCALE, <0.25, 0.25, 0.25>,
//        PSYS_PART_END_SCALE,  <0.25, 0.25, 0.25>,


        PSYS_SRC_BURST_RADIUS, 5,
        PSYS_SRC_BURST_SPEED_MIN, 1,
        PSYS_SRC_BURST_SPEED_MAX, 10,
        PSYS_SRC_ANGLE_BEGIN, 0,
        PSYS_SRC_ANGLE_END, PI,
        PSYS_SRC_MAX_AGE, clearParticlesAfter,
        PSYS_SRC_TARGET_KEY, target,
        PSYS_SRC_TEXTURE,  "Money"
    ]
    );
}

integer TAB_HOME = 0;
integer TAB_START = 1;
integer TAB_ITEM = 3;
integer TAB_SIGNUP = 4;
integer TAB_FINISH = 5;
//integer TAB_ADMIN = 6;

key menuAgentID = NULL_KEY; //* when open dialog we save who call it, to compare when dialog confirmed by same who opened it
integer menuTab = 0;

list getMenuList(key id) {
    list l;
    if (menuTab == TAB_HOME)
    {
        if (id == performerID)
        {
            l += ["Finish"];
            if (ShowTips)
                l += ["Extend 15m"];
        }
        else if (performerID == NULL_KEY)
        {
            if (isSigned(id))
                l += ["Start", "Finish"];
            else
                l += ["-", "-"];
        }

        if (id == llGetOwner())
        {
            if (performerID != NULL_KEY)
                l += ["End"];
            else
                l += ["-"];
            l += ["Reconfig"];
        }
    }
    else if (menuTab == TAB_START)
    {
        l += ["Start", "Cancel"];
        if (AskTimes)
            l += timesStrings;
    }
    else if (menuTab == TAB_FINISH)
    {
        l += ["Finish", "Cancel"];
    }
    else if (menuTab == TAB_ITEM)
    {
        l += ["Move Top", "Remove", "Cancel"];
    }
    else if (menuTab = TAB_SIGNUP)
    {
        l += ["Signup", "Cancel"];
    }
    return l;
}

list cmd_menu = [ "<--", "---", "-->" ]; //* general navigation

list getMenu(key id)
{
    list commands = getMenuList(id);
    integer length = llGetListLength(commands);
    if (length >= 9)
    {
        integer x = cur_page * 9;
        return cmd_menu + llList2List(commands, x , x + 8);
    }
    else {
        return commands;
    }
}

integer dialog_channel;
integer cur_page; //* current menu page
integer dialog_listen_id;

showDialog(key id)
{
//* nop we cant check it, what if ingored :(
/*	if (dialog_listen_id>0)
    {
        llRegionSayTo(id, 0, "Board is busy with another user, please wait and try again");
        return;
    }
*/
    llListenRemove(dialog_listen_id);
    menuAgentID = id;
    dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    string title;
    if (menuTab == TAB_HOME)
        title = "Select command";
    else
        title = "Select time";
    if (performerID != NULL_KEY)
        title += "\n" + llGetDisplayName(performerID);
    if (endTime>0)
    title += "\nEnd time at "+ timeToStr(endTime);
    llDialog(id, "Page: " + (string)(cur_page+1) + " " + title, getMenu(id), dialog_channel);
    dialog_listen_id = llListen(dialog_channel, "", id, "");
}

closeDialog(key id)
{
    if (dialog_listen_id>0) //*maybe showDialog called again for same user
        menuAgentID = NULL_KEY;
}

string timeToStr(integer time)
{
    list t = Unix2StampList(time);
    return llList2String(t, 3)+":"+llList2String(t, 4);
}

integer isSigned(key id)
{
    if (llListFindList(id_list, [id])>=0)
        return TRUE;
    else
        return FALSE;
}

start(key id, integer time)
{
    if (performerID != NULL_KEY)
    {
        llRegionSayTo(id, 0, "You can not start while other performer is started");
    }
    else
    {
        performerID = id;
        if (time>0)
        {
            //* 60 seconds and 15 min, we round it to 15 min
            integer startTime = llRound((float)((float)llGetUnixTime() /((float)RoundTime * 60)))*RoundTime*60;
            //llOwnerSay("time:"+(string)time);
            endTime = startTime + (time * 60); //* 60 seconds
            llRegionSayTo(performerID, 0, llGetDisplayName(id) + " Your time from " + timeToStr(startTime) + " to " +timeToStr(endTime));
        }
        else
        {
            endTime = 0;
            llRegionSayTo(id, 0, llGetDisplayName(id) + " started, good luck.");
        }
        llSetPayPrice(PAY_HIDE, MoneyList);
        updateText();
        showInfo();
        llMessageLinked(LINK_SET, 0, "profile_image", performerID);
        llSetTimerEvent(interval);
    }
}

reset_performer() {
    endTime = 0;
    lastWarnTime = 0;
    performerID = NULL_KEY;
    llMessageLinked(LINK_SET, 0, "profile_image", NULL_KEY);
    llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
}

finish(key id) {
    if (id == performerID)
        llRegionSayTo(performerID, 0, "Thank you " +llGetDisplayName(performerID) + "");
    remove(id);
    reset_performer();
    updateText();
    showInfo();
}

sendWarnning()
{
    llRegionSayTo(performerID, 0, llGetDisplayName(performerID) + " your time about to end at " + timeToStr(endTime));
}

key last_paid_id = NULL_KEY;

updateText()
{
    return; //*
    string s = "Total Tip " + (string)total_amount;
    if (last_paid_id != NULL_KEY)
         s += "\nLast tip from " + llGetDisplayName(last_paid_id);
    if (performerID != NULL_KEY)
        s += "\nCurrent performer " + llGetDisplayName(performerID);
    llSetText(s, <1.0, 1.0, 1.0>, 1.0);
}

readNotecard()
{
    if (llGetInventoryKey(notecardName) != NULL_KEY)
    {
        clear();
        llOwnerSay("Reading notecard");
        notecardLine = 0;
        notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
    }
}

string getHeader() {
    return "Name, Time";
}

string getItem(integer index, integer full)
{
    string s;
    s = alignTextLeft(llList2String(name_list, index), maxLineLength - maxTimeLength, " ");
    integer time;
    string t = ":";
    time = llList2Integer(time_list, index);
    if (time > 0) {
        t = alignTextRight((string)(time / 60), 2, "0") + ":"+alignTextRight((string)(time % 60), 2, "0");
    }
    else
        t = "--:--";
    s = s + alignTextRight(t, maxTimeLength, " ");

//    s = s + alignTextRight(llList2String(time_list, index), maxNumberLength, " ");
    return s;
}

string getInfo()
{
    string s = "";
    integer c = llGetListLength(id_list);
    if (c ==0)
        s = "No performers signed.";
    else
    {
        integer i = 0;
        while (i<c) {
            if (s!="")
                s = s + "\n";
            s = s + getItem(i, FALSE)+"\n";
            i++;
        }
    }
    return s;
}

showInfo(){
    string s = "Current: " + llGetDisplayName(performerID)+"\n";
    if (ShowTips)
    {
        s += "Total Tip " + (string)total_amount;
        if (last_paid_id != NULL_KEY)
             s += "\nLast: " + llGetDisplayName(last_paid_id);
    }
    printText(s, "Tip");
    printText(getInfo(), "Text");
}

integer indexOfName(string name)
{
    integer len = llGetListLength( name_list );
    integer i;
    for( i = 0; i < len; i++ )
    {
        if( llList2String(name_list, i) == name )
        {
            return i;
        }
    }
    return -1;
}

integer indexOfID(key id)
{
    integer len = llGetListLength(id_list);
    integer i;
    for( i = 0; i < len; i++)
    {
        if( llList2Key(id_list, i) == id)
        {
            return i;
        }
    }
    return -1;
}

addKeyName(key id, string name){
    id_list += id;
    name_list += name;
    time_list += [0];
}

integer add(key id)
{
    integer index = indexOfID(id);
    if (index < 0)
    {
        string name = llGetDisplayName(id);
        if (name=="")
            name = llRequestDisplayName(id);
        addKeyName(id, name);
        return indexOfID(id);
    }
    else
        return index;
}

remove(key id){
    integer index = indexOfID(id);
    if (index >= 0) {
        id_list = llDeleteSubList(id_list, index, index);
        time_list = llDeleteSubList(time_list, index, index);
    }
}

moveTop(key id){
    integer index = indexOfID(id);
    if (index >= 0) {
        key time = llList2Key(time_list, index);
        id_list = [id] + llDeleteSubList(id_list, index, index);
        time_list = [time] + llDeleteSubList(time_list, index, index);
    }
}

integer detectBoardIndex(string s)
{
    list params = llParseString2List(s,[":"],[""]);
    string r = llList2String(params, 3);
    if (r == "")
        return -1;
    else
        return (integer)r;
}

key detectBoardID(string s)
{
    integer i = detectBoardIndex(s);
    if (i<0)
        return NULL_KEY;
    else
    {
        if (i<llGetListLength(id_list))
            return llList2Key(id_list, i);
        else
            return NULL_KEY;
    }
}

clear()
{
    id_list = [];
    name_list = [];
    time_list = [];
    reset_performer();
}

signup(key id)
{
    add(id);
    llRegionSayTo(id, 0, llGetDisplayName(id) + " You are signed as performer.");
    showInfo();
}

fwAddBox(string name, string parent, integer x, integer y, integer w, integer h, string text, string style) {
    llMessageLinked(LINK_SET, 0, text, "fw_addbox: " +name + ":" + parent + ":"+
                    (string)x + "," + (string)y + "," + (string)w + "," + (string)h + ":" + style);
}

fwTouchQuery(integer linkNumber, integer faceNumber, string userData) {
    llMessageLinked(LINK_SET, 0, userData, "fw_touchquery:" + (string)linkNumber + ":" + (string)faceNumber);
}

key action_id = NULL_KEY;

doCommand(string cmd, key id, list params)
{
    if (cmd == "signup")
    {
        menuTab = TAB_SIGNUP;
        showDialog(id);
    }
    else if (cmd == "start")
    {
        if (performerID == id)
            llRegionSayTo(id, 0, llGetDisplayName(id) + " You alread started");
        else if (performerID != NULL_KEY)
            llRegionSayTo(id, 0, llGetDisplayName(id) + " You can not start while other performer " + llGetDisplayName(performerID) + " is started");
        else if (isSigned(id))
        {
            menuTab = TAB_START;
            showDialog(id);
        }
        else
            llRegionSayTo(id, 0, llGetDisplayName(id) + " You are not signed.");
    }
    else if (cmd == "finish")
    {
        if (performerID == id)
        {
            menuTab = TAB_FINISH;
            showDialog(id);
        }
        else
            if (isSigned(id))
            {
                remove(id);
                llRegionSayTo(id, 0, llGetDisplayName(id) + " Your name is removed.");
            }
    }
    else if (cmd == "tip")
    {
//		llpaye
    }
/*        else
        llOwnerSay(cmd);*/
}

default
{
    state_entry()
    {
        llSetText("", <0.0, 0.0, 0.0>, 0.0);
        clearParticles();
        llMessageLinked(LINK_SET, 0, "", "fw_reset");
        llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        readNotecard();
        reset_performer();

        //llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }

    touch_start(integer num_detected)
    {
        integer link = llDetectedLinkNumber(0);
        string name = llGetLinkName(link);
        key id = llDetectedKey(0);
        if (id == llGetOwner())
        {
            if (llSubStringIndex(name, "FURWARE ") == 0)
            {
                key k = detectBoardID(name);
                if (k != NULL_KEY)
                {
                    action_id = k;
                    menuTab = TAB_ITEM;
                    showDialog(id);
                }
                //fwTouchQuery(link, llDetectedTouchFace(0), "board");
            }
        }
    }

    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_DEBIT) {
           permitted = TRUE;
        }
    }

    money(key id, integer amount)
    {
        total_amount += amount;
        string msg = llGetDisplayName(id) + " donated " + (string)amount  + " to " + llGetDisplayName(performerID);
        llInstantMessage(llGetOwner(), msg);
        if (performerID != NULL_KEY) {
            llGiveMoney(performerID, amount);
            llRegionSayTo(id, 0, "Thank you for payment, you donated " + (string)amount + " to " + llGetDisplayName(performerID));
            llSay(0, msg);
            last_paid_id = id;
            updateText();
            showInfo();
            if (Particles)
                sendParticles(performerID);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == dialog_channel)
        {
            message = llToLower(message);
            llListenRemove(dialog_listen_id);
            dialog_listen_id = 0; //* we check it in closedialog, to not close it if it show dialog again
            if (message == "---")
            {
                cur_page = 0;
                showDialog(id);
            }
            else if (message == "<--")
            {
                if (cur_page > 0)
                    cur_page--;
                showDialog(id);
            }
            else if (message == "-->")
            {
                integer max_limit = llGetListLength(getMenuList(id)) / 9;
                if ((max_limit > 0) && (cur_page < max_limit))
                    cur_page++;
                showDialog(id);
            }
            //* Commands
            else if (menuAgentID != id) //* accept it from same who last one opened it
                llRegionSayTo(id, 0, "Sorry action is interrupted by another user");
            else
            {
                if (menuTab == TAB_HOME)
                {
                    if (message == "extend 15m")
                    {
                        if (AskTimes)
                        {
                            if (performerID != NULL_KEY) {
                                if (endTime>0) {
                                    endTime = endTime + ExtendTime * 60;
                                    llRegionSayTo(performerID, 0, "Time extended to " + timeToStr(endTime));
                                }
                            }
                        }
                    }
                    else if (message == "end")
                    {
                        if (performerID != NULL_KEY)
                            finish(performerID);
                    }
                    else if (message == "start")
                    {
                        doCommand("start", id, []);
                    }
                    else if (message == "finish")
                    {
                        doCommand("finish", id, []);
                    }
                    else if (message == "reconfig")
                    {
                        readNotecard();
                    }
                }
                else if (menuTab == TAB_START)
                {
                    if (message=="start")
                    {
                        start(id, 0);
                    }
                    else if (message=="cancel") {
                        //* nothing to do
                    }
                    else if (AskTimes)
                    {
                        integer index = llListFindList(timesStrings, [message]);
                        if (index>=0)
                        {
                            integer time = llList2Integer(timesValues, index);
                            start(id, time);
                        }
                    }
                    menuTab = TAB_HOME;
                }
                else if (menuTab == TAB_FINISH)
                {
                    if (message=="finish")
                    {
                        finish(id);
                    }
                    else if (message=="cancel") {
                        //* nothing to do
                    }
                }
                else if (menuTab == TAB_SIGNUP)
                {
                    if (message=="signup")
                    {
                        signup(id);
                    }
                    else if (message=="cancel")
                    {
                        //* ignore
                    }
                }
                else if (menuTab == TAB_ITEM)
                {
                    if (message == "remove")
                    {
                        remove(action_id);
                        showInfo();
                        action_id = NULL_KEY;
                    }
                    else if (message == "move top")
                    {
                        moveTop(action_id);
                        showInfo();
                        action_id = NULL_KEY;
                    }
                }
                closeDialog(id);
            }
        }
    }

    dataserver( key queryid, string data ){
        if (queryid == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                notecardQueryId = NULL_KEY;
                llOwnerSay("Read performers count: " + (string)llGetListLength(id_list));
                llMessageLinked(LINK_SET, 0, "HomeURI;"+HomeURI, NULL_KEY);
            }
            else
            {
                if (llToLower(llGetSubString(data, 0, 0)) != "#")
                {
                    integer p = llSubStringIndex(data, "=");
                    string name;
                    if (p>=0) {
                        name = llToLower(llStringTrim(llGetSubString(data, 0, p - 1), STRING_TRIM));
                        data = llStringTrim(llGetSubString(data, p + 1, -1), STRING_TRIM);
                    }

                    if (name=="showtips")
                        ShowTips = toBool(data);
                    else if (name=="AskTimes")
                        AskTimes = toBool(data);
                    else if (name=="defaulttime")
                        DefaultTime = (integer)data;
                    if (name=="WarnBefore")
                        WarnBefore = toBool(data);
                    else if (name=="WarnTimes")
                        WarnTimes = toBool(data);
                    else if (name=="RoundTime")
                        RoundTime = toBool(data);
                    else if (name=="ExtendTime")
                        ExtendTime = toBool(data);
                    if (name=="homeuri")
                    {
                        HomeURI = data;
                    }
                    if (name=="Particles")
                        Particles = toBool(data);
                    if (name == "money")
                    {
                        MoneyList = llParseString2List(data, [","], [" "]);
                    }
                    else if (name=="add")
                    {
                        id_list += data;
                    }
                }

                ++notecardLine;
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }

    link_message( integer sender, integer num, string message, key id)
    {
        if (id == "fw_ready") {
            // Here you can try out your commands.

            //llOwnerSay("FW text is up and running!");

            // Start sending some initialization stuff.
            llMessageLinked(sender, 0, "c=white; a=left; f="+FontName, "fw_conf");

            fwAddBox("Tip", "default", 0, 0, maxLineLength, infoLines, "", "");
            fwAddBox("Text", "default", 0, infoLines, maxLineLength, 12, "", "");
            llMessageLinked(sender, 0, "c=red;w=none;t=off", "fw_conf:Tip");
            llMessageLinked(sender, 0, "c=white;w=none;t=off", "fw_conf:Text");
            updateText();
            showInfo();
        }
        else
        {
            list params = llParseString2List(message,[";"],[""]);
            string cmd = llToLower(llList2String(params,0));
            params = llDeleteSubList(params, 0, 0);
            if (cmd == "button.signup")
                doCommand("signup", id, params);
            else if (cmd == "button.start")
                doCommand("start", id, params);
            else if (cmd == "button.finish")
                doCommand("finish", id, params);
        }
    }

    timer()
    {
        if (clearParticlesAfter>0)
         {
            clearParticlesAfter--;
            if (clearParticlesAfter==0)
                clearParticles();
         }

        if (performerID != NULL_KEY)
        {
            if (endTime>0) //* not open time
            {
                integer t = llGetUnixTime();
                 if ((endTime - t) <= 0) {
                    finish(performerID);
                }
                 else if (WarnBefore > 0)
                {
                    if ((endTime - t) < (WarnBefore * 60))
                    {
                        if ((t - lastWarnTime) > ((WarnBefore * 60) / WarnTimes))
                        {
                            lastWarnTime = t;
                            sendWarnning();
                        }
                    }
                }
            }
        }
    }
}
