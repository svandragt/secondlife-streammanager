setParcelMusicURL(string data) 
{
    llSetParcelMusicURL(data);
    llOwnerSay("Stream changed to: " + data);
}


default 
{ 

    state_entry()
    {
        llOwnerSay("Started OK");
    }

}

// END //