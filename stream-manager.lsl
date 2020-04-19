key notecardQueryId;
integer gChannel = -1457227181;

integer coreRequirementChecks()
{
    // set sit target, otherwise this will not work
    llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);

    if (llGetInventoryKey("live") == NULL_KEY {
        llOwnerSay( "Must contain 'live' notecard containing stream URL.");
        return 0;
    }

    if (llSubStringIndex( llToLower(llGetObjectDesc()), "http" ) == -1) {
        llOwnerSay( "Object description must be set to a valid stream URL.");
        return 0;
    }

    return 1;
}

integer dataRequirementChecks(string data)
{
    if (data == EOF) {
        llOwnerSay("Missing stream URL in the notecard.");
        return 0;
    }

    if (llSubStringIndex( llToLower(data), "http" ) == -1) {
        llOwnerSay("Notecard contents must contain valid stream URL");
        return 0;
    }

    return 1;
}

setParcelMusicURL(string data)
{
    llRegionSay(gChannel,data);
}

/*
    Main

*/
default
{

    state_entry()
    {
        integer pass = coreRequirementChecks();
        if (pass == 0) {
            return;
        }

        llOwnerSay("Started OK");
    }

    on_rez(integer start_param)
    {
        llOwnerSay("Reset");
        llResetScript();
    }

    changed(integer change)
    {
        integer pass = coreRequirementChecks();
        if (pass == 0) {
            return;
        }

        if (change & CHANGED_LINK) {
            key av = llAvatarOnSitTarget();
            if (av) {
                // if avatar is sitting on prim then change to live stream
                notecardQueryId = llGetNotecardLine("live", 0);
            }
            else {
                // change to stream specified in object description
                setParcelMusicURL(llGetObjectDesc());
                return;
            }
        }
        else if (change & CHANGED_INVENTORY) {
            llResetScript();
        }
    }

    dataserver(key query_id, string data)
    {
        if (query_id == notecardQueryId) {
            data = llStringTrim(data, STRING_TRIM);

            integer pass = dataRequirementChecks(data);
            if (pass == 0) {
                return;
            }

            setParcelMusicURL(data);
        }
    }
}
