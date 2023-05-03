string fontName = "Impact-512.png";

default {
    state_entry() {
        // Reset the FURWARE text script.
        llMessageLinked(LINK_SET, 0, "", "fw_reset");
    }

    link_message(integer sender, integer num, string str, key id) {
        // The text script sends "fw_ready" when it has initialized itself.
        if (id == "fw_ready") {
            // Here you can try out your commands.

            //llOwnerSay("FW text is up and running!");

            // Start sending some initialization stuff.
            llMessageLinked(sender, 0, "c=white; a=left; f="+fontName, "fw_conf");
            llMessageLinked(LINK_SET, 0, llGetObjectName(), "fw_data");
        }
    }

    touch_start(integer numDetected) {
        //llMessageLinked(LINK_SET, 0, "Score Board v1.1", "fw_data");
    }
}
