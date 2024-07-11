SendToConsole("hlvr_physcannon_forward_offset -5")
thisEntity:Attribute_SetIntValue("picked_up", 0)
if Convars:GetInt("hidehud") ~= 96 and Convars:GetInt("hidehud") ~= 1 and Convars:GetInt("hidehud") ~= 67 then
    SendToConsole("r_drawviewmodel 1")
end
