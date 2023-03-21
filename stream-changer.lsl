/**
* CHANGER
*
* Deeded to group.
*/
integer relay_channel = -1457227181;
integer listen_relay;

setParcelMusicURL(string data)
{
    llSetParcelMusicURL(data);
    llWhisper(0,"Stream changed to: " + data);
}

integer validate_listen_relay(list data, integer channel)
{
    if (channel != relay_channel) {
        return 0;
    }

    string command = llList2String(data, 0);
    string maybe_url = llList2String(data, 1);

    if (llListFindList(["CHANGE", "FALLBACK"], [command]) == -1) {
        llOwnerSay("ERROR: Invalid command: " + command);
        return 0;
    }

    if (command == "CHANGE" && ! is_url(maybe_url)) {
        llWhisper(0,"ERROR: Data must be valid stream URL.");
        return 0;
    }

    return 1;
}

integer is_url(string maybe_url) {
    if (llSubStringIndex( llToLower(maybe_url), "http" ) != -1) {
        return 1;
    }
    return 0;
}

save_stream_to_object() {
    llSetObjectDesc( llGetParcelMusicURL());
}


default
{
    state_entry()
    {
        listen_relay = llListen(relay_channel, "", NULL_KEY, "");

        save_stream_to_object();

        llOwnerSay("Ready.");
    }

    listen( integer channel, string name, key id, string data )
    {
        list data = llParseString2List(data, [" "], []);
        integer pass = validate_listen_relay(data, channel);
        if (pass == 0) {
            return;
        }

        string command = llList2String(data, 0);
        string url = llList2String(data, 1);

        if (command == "FALLBACK") {
            url = llGetObjectDesc();
        }

        setParcelMusicURL(url);
    }

    changed(integer mask)
    {
        if (mask & CHANGED_OWNER) {
            llResetScript();
        }
    }

}
