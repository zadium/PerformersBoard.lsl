/**
    @name: PerformersBoard
    @description:

    @author: Zai Dium
    @version: 0.1
    @updated: "2023-05-03 16:43:09"
    @revision: 29
    @localfile: ?defaultpath\Performers\?@name.lsl
    @license: MIT

    @ref:

    @notice:
*/

//* settings
integer warnBefore = 1; //* in minutes
integer warnTimes = 4; //* in minutes
integer roundTime = 1; //* in minutes, this fix the time to start at right time in minutes
integer extendTime = 15;//* in minutes

integer particles = FALSE;

list moneyList = [2, 4, 6, 8];

integer interval = 1;

//* variables

string HomeURI;

/**
    Utils
*/
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

printText(string s)
{
    llMessageLinked(LINK_THIS, 0, s, "fw_reset");
}

/**
    Script
*/

list performers = [];

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
integer TAB_TIME = 1;

integer menuTab = 0;

list getMenuList(key id) {
    list l;
    if (menuTab == TAB_HOME)
    {
        if (id == performerID)
            l += ["Logout", "Extend 15m"];
        else if (performerID == NULL_KEY) {
            if (isperformer(id))
                l += ["as Performer", "as Guest"];
            else
                l += ["-", "-"];
        }
        else
            l += ["Busy", "Busy"];

        if (id == llGetOwner())
        {
            if (performerID != NULL_KEY)
                l += ["Finish"];
            else
                l += ["-"];
            l += ["Reconfig"];
        }
    }
    else
    {
        l += timesStrings;
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
        return cmd_menu + commands;
    }
}

integer dialog_channel;
integer cur_page; //* current menu page
integer dialog_listen_id;

showDialog(key id)
{
    dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    llListenRemove(dialog_listen_id);
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

string timeToStr(integer time)
{
    list t = Unix2StampList(time);
    return llList2String(t, 3)+":"+llList2String(t, 4);
}

integer isperformer(key id)
{
    if (llListFindList(performers, [llGetDisplayName(id)])>=0)
        return TRUE;
    else
        return FALSE;
}

login(key id, integer time)
{
    if (performerID != NULL_KEY)
    {
        llRegionSayTo(id, 0, "You can not login while other performer have playing");
    }
    else
    {
        //* 60 seconds and 15 min, we round it to 15 min
        integer startTime = llRound((float)((float)llGetUnixTime() /((float)roundTime * 60)))*roundTime*60;
        //llOwnerSay("time:"+(string)time);
        endTime = startTime + (time * 60); //* 60 seconds

        performerID = id;
        llSetPayPrice(PAY_HIDE, moneyList);
        llRegionSayTo(performerID, 0, "Your time from " + timeToStr(startTime) + " to " +timeToStr(endTime));

        llSetTimerEvent(interval);
        updateText();
    }
}

logout(key id) {
    if (id == performerID)
        llRegionSayTo(performerID, 0, llGetDisplayName(performerID) + " your time is finished");
    endTime = 0;
    lastWarnTime = 0;
    performerID = NULL_KEY;
    llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
    updateText();
}

sendWarnning()
{
    llRegionSayTo(performerID, 0, llGetDisplayName(performerID) + " your time about to end at " + timeToStr(endTime));
}

key last_paid_id = NULL_KEY;

updateText()
{
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
        performers = [];
        llOwnerSay("Reading notecard");
        notecardLine = 0;
        notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
    }
}

default
{
    state_entry()
    {
        printText("Init");
        clearParticles();
        llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        readNotecard();
        logout(NULL_KEY);
        //llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }

    touch_start(integer num_detected)
    {
        key id = llDetectedKey(0);
        if (!permitted) {
            if (id == llGetOwner())
                llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
            else
                llRegionSayTo(id, 0, "Setup not complete, need permissions");
        }
        else
        {
            if ((id == llGetOwner()) || (isperformer(id)))
            {
                menuTab = TAB_HOME;
                showDialog(id);
            }
            else
                llRegionSayTo(id, 0, llGetDisplayName(id)+" right click, then click Pay button for donation");
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
            if (particles)
                sendParticles(performerID);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == dialog_channel)
        {
            message = llToLower(message);
            llListenRemove(dialog_listen_id);
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
            else
            {
                if (menuTab == TAB_HOME)
                {
                    if (message == "busy")
                    {
                        llRegionSayTo(id, 0, "It said busy, wait till " + timeToStr(endTime));
                    }
                    else if (message == "extend 15m")
                    {
                        if (performerID != NULL_KEY) {
                            if (endTime>0) {
                                endTime = endTime + extendTime * 60;
                                llRegionSayTo(performerID, 0, "Time extended to " + timeToStr(endTime));
                            }
                        }
                    }
                    else if (message == "finish")
                    {
                        if (performerID != NULL_KEY)
                            logout(performerID);
                    }
                    else if (message == "as performer")
                    {
                        //login(id, FALSE);
                         menuTab = TAB_TIME;
                        showDialog(id);
                    }
                    else if (message == "logout")
                    {
                        logout(id);
                        //showDialog(id);
                    }
                    else if (message == "reconfig")
                    {
                        readNotecard();
                        //showDialog(id);
                    }
                }
                else if (menuTab == TAB_TIME)
                {
                    integer index = llListFindList(timesStrings, [message]);
                    if (index>=0)
                    {
                        integer time = llList2Integer(timesValues, index);
                        login(id, time);
                    }
                    menuTab = TAB_HOME;
                }
            }
        }
    }

    dataserver( key queryid, string data ){
        if (queryid == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                notecardQueryId = NULL_KEY;
                llOwnerSay("Read performers count: " + (string)llGetListLength(performers));
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

                    if (name=="warnbefore")
                        warnBefore = (integer)data;
                    else if (name=="warntimes")
                        warnTimes = (integer)data;
                    else if (name=="roundtime")
                        roundTime = (integer)data;
                    else if (name=="extendtime")
                        extendTime = (integer)data;
                    if (name=="homeuri")
                    {
                        HomeURI = data;
                    }
                    if (name=="particles")
                        particles = (integer)data;
                    if (name == "money")
                    {
                        moneyList = llParseString2List(data, [","], [" "]);
                    }
                    else if (name=="performer")
                    {
                        performers += data;
                    }
                }

                ++notecardLine;
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }

    link_message( integer sender_num, integer num, string message, key id)
    {
        if (message == "button.signup")
        {
            llMessageLinked(LINK_SET, 0, "profile_image", id);
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
            integer t = llGetUnixTime();
             if ((endTime - t) <= 0) {
                logout(performerID);
            }
             else if (warnBefore > 0)
            {
                if ((endTime - t) < (warnBefore * 60))
                {
                    if ((t - lastWarnTime) > ((warnBefore * 60) / warnTimes))
                    {
                        lastWarnTime = t;
                        sendWarnning();
                    }
                }
            }
        }
    }
}
