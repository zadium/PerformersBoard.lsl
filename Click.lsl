/**
    @name: Click
    @description:

    @author: Zai Dium
    @version: 0.1
    @updated: "2023-05-02 20:07:29"
    @revision: 17
    @localfile: ?defaultpath\Performers\?@name.lsl
    @license: MIT

    @ref:

    @notice:
*/
default
{
    state_entry()
    {
    }

    touch_start(integer num_detected)
    {
        llMessageLinked(LINK_SET, 0, "button."+llToLower(llGetObjectName()), llDetectedKey(0));
    }

}
