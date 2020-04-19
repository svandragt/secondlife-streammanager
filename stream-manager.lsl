/**
* MANAGER
*
* Not deeded.
*/
key notecard_id;
integer relay_channel = -1457227181;

allow_sit() {
    llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
}

integer is_url(string maybe_url) {
    if (llSubStringIndex( llToLower(maybe_url), "http" ) != -1) {
        return 1;
    }
    return 0;
}

/**
* Notecard line must have contents and can only contains URLs.
*/
integer validate_notecard_data(string data)
{
    if (data == EOF) {
        llOwnerSay("ERROR: stream URL cannot be found in notecard.");
        return 0;
    }

    if (! is_url(data)) {
        llOwnerSay("ERROR: Notecard must contain valid stream URL");
        return 0;
    }

    return 1;
}

/**
* Handle person changing the stream via chat.
*/
integer listeningFunction(string input) {
    input = llStringTrim(input, STRING_TRIM);
    if (llToUpper(input) == "LIVE" &&  llGetInventoryKey("live") == NULL_KEY) {
        // TODO: also message sitter
        llOwnerSay( "Must contain 'live' notecard containing stream URL.");
        return 0;
    }
    return 1;
}

relayParcelMusicURL(string command, string data)
{
    llRegionSay(relay_channel,command + " " + data);
}

/**
* Main
*/
default
{

    /**
    * Bootstrap.
    */
    state_entry()
    {
        allow_sit();

        llOwnerSay("Ready.");
    }

    on_rez(integer start_param)
    {
        llOwnerSay("Reset");
        llResetScript();
    }

    /**
    * Handle avatar and inventory changes.
    */
    changed(integer change)
    {
        if (change & CHANGED_LINK) {
            key av = llAvatarOnSitTarget();

            if (av) {
                // if avatar is sitting on prim then change to live stream
                notecard_id = llGetNotecardLine("live", 0);
                return;
            }

            // change to stream specified in object description
            relayParcelMusicURL("FALLBACK", "");
            return;
        }

        if (change & CHANGED_INVENTORY) {
            llResetScript();
        }

        if (change & CHANGED_OWNER) {
            llResetScript();
        }
    }

    /**
    * Process notecard line read.
    * Only read the first line, contains live stream.
    */
    dataserver(key query_id, string line)
    {
        if (query_id == notecard_id) {
            line = llStringTrim(line, STRING_TRIM);

            integer pass = validate_notecard_data(line);
            if (pass == 0) {
                llWhisper(0, "Owner must fix invalid notecard contents. Please try again later.");
                return;
            }

            relayParcelMusicURL("CHANGE", line);
        }
    }
}
