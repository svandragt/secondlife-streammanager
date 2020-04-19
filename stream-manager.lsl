/**
* MANAGER
*
* Not deeded.
*/
key av;
key notecard_id;
integer relay_channel = -1457227181;
integer user_channel = PUBLIC_CHANNEL;
integer listen_user;


allow_sit() {
    llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
}

remove_sit() {
    //TODO unsits also sets fallback stream.
    llUnSit(av);
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
    llListenRemove(listen_user);
    remove_sit();
}

integer validate_listen_user(string data, integer channel)
{
    if (channel != user_channel) {
        return 0;
    }

    if (! is_url(data) && llToUpper(data) != "LIVE") {
        llWhisper(0,"NOTICE: Data must be valid stream URL or the word LIVE");
        return 0;
    }

    return 1;
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
            av = llAvatarOnSitTarget();

            if (av) {
                // if avatar is sitting on prim then listen to their command
                listen_user = llListen(user_channel, "", av, "");
                llWhisper(0, "Please say a stream URL or the word LIVE for parcel live stream.");
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

    listen( integer channel, string name, key id, string data )
    {
        data = llStringTrim(data, STRING_TRIM);
        integer pass = validate_listen_user(data, channel);
        if (pass == 0) {
            return;
        }

        if (llToUpper(data) == "LIVE") {
            notecard_id = llGetNotecardLine("live", 0);
            return;
        }

        // User said URL
        relayParcelMusicURL("CHANGE", data);
    }
}
