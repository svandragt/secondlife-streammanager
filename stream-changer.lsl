integer manager_channel = -1457227181;
integer listen_handle;

setParcelMusicURL(string data)
{
    llSetParcelMusicURL(data);
    llWhisper(0,"Stream changed to: " + data);
}

integer validate_listen(string data, integer channel)
{
    if (channel != manager_channel) {
        return 0;
    }

    if (! is_url(data)) {
        llWhisper(0,"Data must be valid stream URL");
        return 0;
    }

    return 1;
}

integer is_url(string maybe_url) {
    return (llSubStringIndex( llToLower(maybe_url), "http" ) != -1)
}


default
{
    state_entry()
    {
        listen_handle = llListen(manager_channel, "", NULL_KEY, "");
        llOwnerSay("Ready.");
    }

    listen( integer channel, string name, key id, string data )
    {
        integer pass = validate_listen(data, channel);
        if (pass == 0) {
            return;
        }
        setParcelMusicURL(data);
    }

    changed(integer mask)
    {
        if (mask & CHANGED_OWNER) {
            llResetScript();
        }
    }

}
