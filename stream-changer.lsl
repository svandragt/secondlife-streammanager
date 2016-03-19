integer gChannel = -1457227181;
integer listen_handle;

setParcelMusicURL(string data) 
{
    llSetParcelMusicURL(data);
    llWhisper(0,"Stream changed to: " + data);
}

integer dataRequirementChecks(string data) 
{
    if (llSubStringIndex( llToLower(data), "http" ) == -1)
    {
        llWhisper(0,"Data must be valid stream URL");
        return 0;    
    }

    return 1;
}


default 
{ 

    state_entry()
    {
        listen_handle = llListen(gChannel, "", llGetOwner(), "");
        llOwnerSay("Started OK");
    }

    listen( integer channel, string name, key id, string data )
    {
        if (channel != gChannel) 
        {
            return;
        }

        integer pass = dataRequirementChecks(data);
        if (pass == 0) 
        {
            return;
        }

        setParcelMusicURL(data);


    }

    changed(integer mask)
    {   
    //Triggered when the object containing this script changes owner.
        if(mask & CHANGED_OWNER)
        {
            llResetScript();   
            // This will ensure the script listens to the new owner, and doesn't continue listening to the creator.
        }
    }

}

// END //