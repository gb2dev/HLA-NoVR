if not loading_save_file and GlobalSys:CommandLineCheck("-noversioninfo") == false then
    -- Script update date and time
    DebugDrawScreenTextLine(5, GlobalSys:CommandLineInt("-h", 15) - 10, 0, "NoVR Version: Dec 03 21:22 mods", 255, 255, 255, 255, 999999)
end
