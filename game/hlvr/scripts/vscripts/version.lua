if not loading_save_file and GlobalSys:CommandLineCheck("-noversioninfo") == false then
    -- Script update date and time
    DebugDrawScreenTextLine(5, GlobalSys:CommandLineInt("-h", 15) - 10, 0, "NoVR Version: Jul 03 13:20", 255, 255, 255, 255, 999999)
end
