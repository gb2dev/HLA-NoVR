local map = GetMapName()
local name = thisEntity:GetName()
local class = thisEntity:GetClassname()
local model = thisEntity:GetModelName()
local player = Entities:GetLocalPlayer()

-- First Junction in the Puzzle
local toner_start_junction
-- First Junction input number
local toner_start_junction_input
-- Last/Success Path
local toner_end_path
-- example_toner_path = {{start_junction_input_number [leave out for first path], end_junction_input_number [leave out for dead end/last path]}, {start_junction_name [leave out for first path], end_junction_name [leave out for dead end/last path]}, absolute_start_position, absolute_end_position},
local toner_paths
-- example_toner_junction = {type [0 = I Junction, 1 = L Junction, 2 = T Junction, 3 = LL Junction, 4 = Static T Junction], absolute_junction_position, toner_path_for_input_0, toner_path_for_input_1, toner_path_for_input_2, toner_path_for_input_3}
local toner_junctions

if map == "a2_quarantine_entrance" then
    toner_start_junction = "toner_junction_1"
    toner_start_junction_input = 2
    toner_end_path = "toner_path_5"

    toner_paths = {
        toner_path_1 = {{2}, {"toner_junction_1"}, Vector(-912.1, 1150.47, 100), Vector(-912.1, 1115, 100)},
        toner_path_2 = {{0, 2}, {"toner_junction_1", "toner_junction_2"}, Vector(-912.1, 1109, 100), Vector(-912.1, 1099, 100), Vector(-912.1, 1099, 108.658), Vector(-912.1, 1088.1, 108.658), Vector(-926, 1088.1, 108.658)},
        toner_path_3 = {{1}, {"toner_junction_2"}, Vector(-929, 1088.1, 111.658), Vector(-929, 1088.1, 144), Vector(-946, 1088.1, 144)},
        toner_path_5 = {{0}, {"toner_junction_3"}, Vector(-973, 1088.1, 98.4348), Vector(-986, 1088.1, 98.4348)},
        toner_path_7 = {{2, 3}, {"toner_junction_3", "toner_junction_2"}, Vector(-929, 1088.1, 105.658), Vector(-929, 1088.1, 98.4348), Vector(-947, 1088.1, 98.4348), Vector(-947, 1088.1, 69.5763), Vector(-947, 1088.1, 98.4348), Vector(-967, 1088.1, 98.4348)},
    }

    toner_junctions = {
        toner_junction_1 = {0, Vector(-912.1, 1112, 100), "toner_path_2", "", "toner_path_1", ""},
        toner_junction_2 = {1, Vector(-929, 1088.1, 108.658), "", "toner_path_3", "toner_path_2", "toner_path_7"},
        toner_junction_3 = {0, Vector(-970, 1088.1, 98.4348), "toner_path_5", "", "toner_path_7", ""},
    }
elseif map == "a2_headcrabs_tunnel" then
    toner_start_junction = "toner_junction_1"
    toner_start_junction_input = 0
    toner_end_path = ""

    toner_paths = {
        toner_path_1 = {{0}, {"toner_junction_1"}, Vector(-440.082, -591.641, 10.1066), Vector(-453.538, -583.872, 10.1066)},
        toner_path_2 = {{3}, {"toner_junction_1"}, Vector(-456.077, -582.406, 7.1066), Vector(-456.077, -582.406, 1.25), Vector(-492.011, -561.866, 1.25), Vector(-508.747, -590.854, 1.25)},
        toner_path_3 = {{1, 1}, {"toner_junction_1", "toner_junction_2"}, Vector(-456.077, -582.406, 13.1066), Vector(-456.077, -582.406, 20.25), Vector(-489.012, -563.389, 20.25), Vector(-507.848, -589.466, 20.25), Vector(-563.691, -557.735, 20.25), Vector(-563.471, -557.356, 3.5)},
        toner_path_5 = {{2}, {"toner_junction_2"}, Vector(-566.054, -555.864, 0.5), Vector(-591.523, -541.157, 0.5), Vector(-583.348, -527.429, 0.5), Vector(-612.043, -511.988, 0.5)},
        toner_path_6 = {{0}, {"toner_junction_2"}, Vector(-561.36, -558.574, 0.5), Vector(-551.359, -564.352, 0.5), Vector(-518.847, -584.56, 0.5)},
        toner_path_8 = {{}, {}, Vector(), Vector()},
        toner_path_10 = {{}, {}, Vector(), Vector()},
    }

    toner_junctions = {
        toner_junction_1 = {3, Vector(-456.077, -582.406, 10.1066), "toner_path_1", "toner_path_3", "", "toner_path_2"},
        toner_junction_2 = {3, Vector(-563.471, -557.356, 0.5), "toner_path_6", "toner_path_3", "toner_path_5", ""},
    }
elseif map == "a2_train_yard" then
    toner_start_junction = "train_gate_junction_0_1"
    toner_start_junction_input = 0
    toner_end_path = ""

    toner_paths = {
        train_gate_path_start = {{0}, {"train_gate_junction_0_1"}, Vector(733, 617, 88), Vector(733, 606, 88)},
        train_gate_path_00_to_01 = {{3, 1}, {"train_gate_junction_0_0", "train_gate_junction_0_1"}, Vector(733, 603, 91), Vector(733, 603, 105)},
        train_gate_path_00_to_10 = {{0, 2}, {"train_gate_junction_1_0", "train_gate_junction_0_0"}, Vector(733, 600, 108), Vector(733, 586, 108)},
        train_gate_path_01_to_02 = {{1, 3}, {"train_gate_junction_0_2", "train_gate_junction_0_1"}, Vector(733, 603, 85), Vector(733, 603, 71)},
        train_gate_path_01_to_11 = {{0, 2}, {"train_gate_junction_1_1", "train_gate_junction_0_1"}, Vector(733, 600, 88), Vector(733, 586, 88)},
        train_gate_path_02_to_12 = {{0, 2}, {"train_gate_junction_1_2", "train_gate_junction_0_2"}, Vector(733, 600, 68), Vector(733, 586, 68)},
        train_gate_path_10_to_11 = {{1, 3}, {"train_gate_junction_1_1", "train_gate_junction_1_0"}, Vector(733, 583, 105), Vector(733, 583, 91)},
        train_gate_path_10_to_20 = {{2, 0}, {"train_gate_junction_1_0", "train_gate_junction_2_0"}, Vector(733, 580, 108), Vector(733, 566, 108)},
        train_gate_path_11_to_12 = {{3, 1}, {"train_gate_junction_1_1", "train_gate_junction_1_2"}, Vector(733, 583, 71), Vector(733, 583, 85)},
        train_gate_path_11_to_21 = {{0, 2}, {"train_gate_junction_2_1", "train_gate_junction_1_1"}, Vector(733, 580, 88), Vector(733, 566, 88)},
        train_gate_path_12_to_22 = {{0, 2}, {"train_gate_junction_2_2", "train_gate_junction_1_2"}, Vector(733, 580, 68), Vector(733, 566, 68)},
        train_gate_path_20_to_21 = {{1, 3}, {"train_gate_junction_2_1", "train_gate_junction_2_0"}, Vector(733, 563, 105), Vector(733, 563, 91)},
        train_gate_path_21_to_22 = {{1, 3}, {"train_gate_junction_2_2", "train_gate_junction_2_1"}, Vector(733, 563, 85), Vector(733, 563, 71)},
        train_gate_path_20_to_end = {{}, {}, Vector(733, 560, 108), Vector(733, 549.5, 108)},
        train_gate_path_22_to_end = {{}, {}, Vector(733, 560, 68), Vector(733, 549.5, 68)},
    }
    toner_junctions = {
        train_gate_junction_0_0 = {1, Vector(733, 603, 108), "", "", "train_gate_path_00_to_10", "train_gate_path_00_to_01"},
        train_gate_junction_0_1 = {1, Vector(733, 603, 88), "train_gate_path_start", "train_gate_path_00_to_01", "train_gate_path_01_to_11", "train_gate_path_01_to_02"},
        train_gate_junction_0_2 = {1, Vector(733, 603, 68), "", "train_gate_path_01_to_02", "train_gate_path_02_to_12", ""},
        train_gate_junction_1_0 = {1, Vector(733, 583, 108), "train_gate_path_00_to_10", "", "train_gate_path_10_to_20", "train_gate_path_10_to_11"},
        train_gate_junction_1_1 = {2, Vector(733, 583, 88), "train_gate_path_01_to_11", "train_gate_path_10_to_11", "train_gate_path_11_to_21", "train_gate_path_11_to_12"},
        train_gate_junction_1_2 = {1, Vector(733, 583, 68), "train_gate_path_02_to_12", "train_gate_path_11_to_12", "train_gate_path_12_to_22", ""},
        train_gate_junction_2_0 = {1, Vector(733, 563, 108), "train_gate_path_10_to_20", "", "train_gate_path_20_to_end", "train_gate_path_20_to_21"},
        train_gate_junction_2_1 = {1, Vector(733, 563, 88), "train_gate_path_11_to_21", "train_gate_path_20_to_21", "", "train_gate_path_21_to_22"},
        train_gate_junction_2_2 = {0, Vector(733, 563, 68), "train_gate_path_12_to_22", "train_gate_path_21_to_22", "train_gate_path_22_to_end", ""},
    }
elseif map == "a3_station_street" then
    toner_start_junction = "toner_junction_1"
    toner_start_junction_input = 0
    toner_end_path = "toner_path_6"

    toner_paths = {
        toner_path_1 = {{0}, {"toner_junction_1"}, Vector(1439.2, -182.292, -433.661), Vector(1439.2, -182.292, -443), Vector(1439.2, -162, -443), Vector(1429.3, -162, -443), Vector(1429.3, -150, -443), Vector(1429.3, -150, -448), Vector(1429.3, -143, -448)},
        toner_path_2 = {{0, 1}, {"toner_junction_2", "toner_junction_1"}, Vector(1429.3, -140, -445), Vector(1429.3, -140, -424), Vector(1429.3, -125, -424), Vector(1430, -124, -424), Vector(1432, -123.3, -424), Vector(1432, -119, -424)},
        toner_path_3 = {{3}, {"toner_junction_1"}, Vector(1429.3, -140, -451), Vector(1429.3, -140, -455), Vector(1429.6, -127.5, -455), Vector(1429.6, -127.5, -457), Vector(1429.9, -127.5, -457.5), Vector(1431.9, -127.5, -458.1), Vector(1431.9, -127.5, -470)},
        toner_path_4 = {{2, 0}, {"toner_junction_2", "toner_junction_alarm_1"}, Vector(1432, -113, -424), Vector(1432, -107, -424)},
        toner_path_5 = {{3, 1}, {"toner_junction_2", "toner_junction_3"}, Vector(1432, -116, -427), Vector(1432, -116, -437)},
        toner_path_6 = {{2}, {"toner_junction_3"}, Vector(1432, -113, -440), Vector(1432, -112, -440), Vector(1432, -112, -450)},
        toner_path_alarm_1 = {{1}, {"toner_junction_alarm_1"}, Vector(1432, -104, -421), Vector(1432, -104, -410)},
    }
    toner_junctions = {
        toner_junction_1 = {1, Vector(1429.3, -140, -448), "toner_path_1", "toner_path_2", "", "toner_path_3"},
        toner_junction_2 = {2, Vector(1432, -116, -424), "toner_path_2", "", "toner_path_4", "toner_path_5"},
        toner_junction_3 = {1, Vector(1432, -116, -440), "", "toner_path_5", "toner_path_6", ""},
        toner_junction_alarm_1 = {1, Vector(1432, -104, -424), "toner_path_4", "toner_path_alarm_1", "", ""},
    }
elseif map == "a3_hotel_lobby_basement" then
    if player:Attribute_GetIntValue("circuit_" .. map .. "_junction_1_completed", 0) == 0 then
        toner_start_junction = "junction_1"
        toner_start_junction_input = 0
        toner_end_path = "toner_path_6"

        toner_paths = {
            toner_path_1 = {{0}, {"junction_1"}, Vector(919.6, -1457.38, 191.875), Vector(919.6, -1447.5, 191.875), Vector(920.6, -1447.5, 191.875), Vector(920.6, -1447.5, 187.099), Vector(920.6, -1429, 187.099)},
            toner_path_2 = {{1, 0}, {"junction_1", "junction_2_panel"}, Vector(920.6, -1426, 190.099), Vector(920.6, -1426, 205.375), Vector(920.6, -1437, 205.375), Vector(920.6, -1437, 209.1), Vector(919.7, -1437, 209.1), Vector(919.7, -1437, 212.45), Vector(916.8, -1437, 212.45), Vector(916.8, -1437, 214), Vector(916.8, -1421.3, 214), Vector(918, -1421.3, 214), Vector(918, -1400, 214), Vector(917, -1399.6, 214), Vector(916, -1398.7, 214), Vector(916, -1389.3, 214), Vector(917, -1388.2, 214), Vector(918, -1388.1, 214), Vector(918, -1375, 214), Vector(919, -1374, 214), Vector(929, -1374, 214), Vector(929, -1375.9, 212), Vector(929, -1375.5, 199.5), Vector(957, -1375.5, 199.5), Vector(957, -1387, 199.5), Vector(970, -1387, 199.5)},
            toner_path_lights_1 = {{3}, {"junction_1"}, Vector(920.6, -1426, 184.099), Vector(920.6, -1426, 180), Vector(920.6, -1420.5, 180), Vector(919.7, -1420.5, 180), Vector(919.7, -1400, 180)},
            path_2_panel = {{3}, {"junction_2_panel"}, Vector(973, -1387, 196.5), Vector(973, -1387, 185), Vector(964.5, -1387, 185), Vector(964.5, -1387, 183)},
            path_2_panelexit = {{1, 0}, {"junction_2_panel", "junction_2"}, Vector(973, -1387, 202.5), Vector(973, -1387, 208), Vector(980, -1387, 208), Vector(980, -1387, 187), Vector(983, -1387, 187), Vector(983, -1375, 187), Vector(989.8, -1375, 187), Vector(989.8, -1374.3, 187), Vector(1003.5, -1374.3, 187), Vector(1003.5, -1374.3, 204), Vector(1023.45, -1374.3, 204), Vector(1023.45, -1359, 204)},
            toner_path_3 = {{1, 1}, {"junction_2", "junction_3"}, Vector(1023.45, -1356, 207), Vector(1023.45, -1356, 213), Vector(1023.45, -1317.26, 213), Vector(1023.45, -1317.26, 192)},
            toner_path_4 = {{3}, {"junction_2"}, Vector(1023.45, -1356, 201), Vector(1023.45, -1356, 182), Vector(1023.45, -1365, 182), Vector(1023.45, -1365, 162)},
            toner_path_5 = {{0, 3}, {"junction_3", "toner_junction_4"}, Vector(1023.45, -1320.26, 189), Vector(1023.45, -1325, 189), Vector(1023.45, -1325, 182), Vector(1023.45, -1264.1, 182), Vector(979.875, -1264.1, 182), Vector(979.875, -1264.1, 185)},
            tp_maint_6 = {{2}, {"junction_3"}, Vector(1023.45, -1314.26, 189), Vector(1023.45, -1299, 189), Vector(1023.45, -1299, 215)},
            toner_path_6 = {{2}, {"toner_junction_4"}, Vector(976.875, -1264.1, 188), Vector(972.5, -1264.1, 188), Vector(972.5, -1264.1, 175)},
        }
        toner_junctions = {
            junction_1 = {2, Vector(920.6, -1426, 187.099), "toner_path_1", "toner_path_2", "", "toner_path_lights_1"},
            junction_2_panel = {1, Vector(973, -1387, 199.5), "toner_path_2", "path_2_panelexit", "", "path_2_panel"},
            junction_2 = {1, Vector(1023.45, -1356, 204), "path_2_panelexit", "toner_path_3", "", "toner_path_4"},
            junction_3 = {1, Vector(1023.45, -1317.26, 189), "toner_path_5", "toner_path_3", "tp_maint_6", ""},
            toner_junction_4 = {1, Vector(979.875, -1264.1, 188), "", "", "toner_path_6", "toner_path_5"},
        }
    else
        toner_start_junction = "junction_5"
        toner_start_junction_input = 3
        toner_end_path = "toner_path_11"
    
        toner_paths = {
            toner_path_7 = {{3}, {"junction_5"}, Vector(1170.43, -1535, 167.518), Vector(1159, -1535, 167.518), Vector(1159, -1535, 188), Vector(1139.16, -1535, 188), Vector(1139.16, -1535, 204.518)},
            toner_path_8 = {{0, 2}, {"junction_5", "junction_6"}, Vector(1136.16, -1535, 207.503), Vector(1132, -1535, 207.503), Vector(1132, -1535, 243.515), Vector(1128, -1535, 243.515), Vector(1128, -1528, 243.515), Vector(1120, -1528, 243.515), Vector(1120, -1535, 243.515), Vector(1083.87, -1535, 243.515)},
            toner_path_9 = {{2}, {"junction_5"}, Vector(1142.16, -1535, 207.503), Vector(1160, -1535, 207.503), Vector(1160, -1535, 220)},
            toner_path_10 = {{0, 2}, {"junction_6", "junction_7"}, Vector(1077.87, -1535, 243.515), Vector(1040, -1535, 243.515), Vector(1040, -1528, 243.515), Vector(1032, -1528, 243.515), Vector(1032, -1524, 243.515), Vector(1032, -1524, 213), Vector(1032, -1517, 213), Vector(1020, -1517, 213), Vector(1020, -1511.5, 213)},
            toner_path_11 = {{0}, {"junction_7"}, Vector(1020, -1505.5, 213), Vector(1020, -1490, 213), Vector(1032.1, -1490, 213), Vector(1032.1, -1480, 213), Vector(1036, -1480, 213), Vector(1036, -1476, 213), Vector(1036, -1476, 180)},
        }
        toner_junctions = {
            junction_5 = {2, Vector(1139.16, -1535, 207.503), "toner_path_8", "", "toner_path_9", "toner_path_7"},
            junction_6 = {0, Vector(1080.87, -1535, 243.515), "toner_path_10", "", "toner_path_8", ""},
            junction_7 = {0, Vector(1020, -1508.5, 213), "toner_path_11", "", "toner_path_10", ""}
        }
    end
elseif map == "a3_hotel_street" then
    toner_start_junction = "junction_1"
    toner_start_junction_input = 0
    toner_end_path = "toner_path_11"

    toner_paths = {
        toner_path_7 = {{0}, {"junction_1"}, Vector(1076, 162.3, 116.829), Vector(1076, 162.3, 130), Vector(1089, 162.3, 130)},
        toner_path_9 = {{1, 0}, {"junction_1", "junction_2"}, Vector(1092, 162.3, 133), Vector(1092, 162.3, 139), Vector(1103, 162.3, 139), Vector(1103, 133.1, 139), Vector(1103, 133.1, 125), Vector(1107, 133.1, 125)},
        toner_path_5 = {{3, 2}, {"junction_1", "junction_6"}, Vector(1092, 162.3, 127), Vector(1092, 162.3, 120), Vector(1103, 162.3, 120), Vector(1103, 146.5, 120), Vector(1103, 146.5, 114), Vector(1121, 146.5, 114)},
        toner_path_2 = {{1, 3}, {"junction_2", "junction_4"}, Vector(1110, 133.1, 128), Vector(1110, 133.1, 139)},
        toner_path_1 = {{2, 0}, {"junction_4", "junction_5"}, Vector(1113, 133.1, 142), Vector(1116.9, 133.1, 142), Vector(1116.9, 130.9, 142), Vector(1123, 130.9, 142)},
        toner_path_4 = {{3, 1}, {"junction_5", "junction_3"}, Vector(1126, 130.9, 139), Vector(1126, 130.9, 131)},
        toner_path_10 = {{1, 0}, {"junction_5", "junction_7"}, Vector(1126, 130.9, 145), Vector(1126, 130.9, 152), Vector(1129.9, 130.9, 152), Vector(1129.9, 138, 152), Vector(1123.3, 138, 152), Vector(1123.3, 154.2, 152), Vector(1129.1, 154.2, 152), Vector(1129.1, 162.3, 152), Vector(1138, 162.3, 152)},
        toner_path_12 = {{1}, {"junction_6"}, Vector(1124, 149.5, 114), Vector(1124, 152.75, 114), Vector(1129.9, 152.75, 114), Vector(1129.9, 152.75, 126), Vector(1123.5, 152.75, 126), Vector(1123.5, 152.75, 135.4), Vector(1124.9, 152.75, 135.4), Vector(1124.9, 152.75, 142)},
        toner_path_13 = {{3}, {"junction_6"}, Vector(1124, 143.5, 114), Vector(1124, 138.25, 114), Vector(1111.5, 138.25, 114), Vector(1111.5, 143.25, 114), Vector(1103, 143.25, 114), Vector(1103, 143.25, 130.8), Vector(1107.1, 143.25, 130.8), Vector(1107.1, 143.25, 134)},
        toner_path_11 = {{3}, {"junction_7"}, Vector(1141, 162.3, 149), Vector(1141, 162.3, 119)},
    }
    toner_junctions = {
        junction_1 = {4, Vector(1092, 162.3, 130), "toner_path_7", "toner_path_9", "", "toner_path_5"},
        junction_2 = {2, Vector(1110, 133.1, 125), "toner_path_9", "toner_path_2", "", ""},
        junction_3 = {0, Vector(1126, 130.9, 128), "", "toner_path_4", "", ""},
        junction_4 = {2, Vector(1110, 133.1, 142), "", "", "toner_path_1", "toner_path_2"},
        junction_5 = {2, Vector(1126, 130.9, 142), "toner_path_1", "toner_path_10", "", "toner_path_4"},
        junction_6 = {3, Vector(1124, 146.5, 114), "", "toner_path_12", "toner_path_5", "toner_path_13"},
        junction_7 = {1, Vector(1141, 162.3, 152), "toner_path_10", "", "", "toner_path_11"}
    }
elseif map == "a3_c17_processing_plant" then
    if player:Attribute_GetIntValue("circuit_" .. map .. "_shack_path_6_junction_1_completed", 0) == 0 then
        toner_start_junction = "shack_path_6_junction_1"
        toner_start_junction_input = 2
        toner_end_path = "shack_path_11"

        toner_paths = {
            shack_path_6 = {{2}, {"shack_path_6_junction_1"}, Vector(-1941.8, -1905, 255), Vector(-1941.8, -1905, 271), Vector(-1941.8, -1916.66, 271)},
            shack_path_7 = {{3, 1}, {"shack_path_6_junction_1", "shack_path_6_junction_2"}, Vector(-1941.8, -1919.66, 268), Vector(-1941.8, -1919.66, 255.5), Vector(-1941.8, -1932.2, 255.5), Vector(-1943.5, -1932.2, 255.5), Vector(-1943.5, -1943.5, 255.5), Vector(-1943.5, -1943.5, 311.5), Vector(-1952.5, -1943.5, 311.5), Vector(-1952.5, -1881, 311.5), Vector(-1941.8, -1881, 311.5), Vector(-1941.8, -1881, 283)},
            shack_path_8 = {{1}, {"shack_path_6_junction_1"}, Vector(-1941.8, -1919.66, 274), Vector(-1941.8, -1919.66, 290.25), Vector(-1941.8, -1892.5, 290.25), Vector(-1941.8, -1892.5, 264), Vector(-1941.8, -1887.5, 264), Vector(-1941.8, -1887.5, 250)},
            shack_path_9 = {{2}, {"shack_path_6_junction_2"}, Vector(-1941.8, -1878, 280), Vector(-1941.8, -1860, 280)},
            shack_path_10 = {{0, 0}, {"shack_path_6_junction_2", "shack_path_11_junction_1"}, Vector(-1941.8, -1884, 280), Vector(-1941.8, -1889, 280), Vector(-1941.8, -1889, 269), Vector(-1941.8, -1884, 269)},
            shack_path_11 = {{2}, {"shack_path_11_junction_1"}, Vector(-1941.8, -1878, 269), Vector(-1941.8, -1875.5, 269), Vector(-1942.5, -1875.5, 269), Vector(-1942.5, -1870.5, 269), Vector(-1942.5, -1870.5, 258.8)},
        }
        toner_junctions = {
            shack_path_6_junction_1 = {2, Vector(-1941.8, -1919.66, 271), "", "shack_path_8", "shack_path_6", "shack_path_7"},
            shack_path_6_junction_2 = {1, Vector(-1941.8, -1881, 280), "shack_path_10", "shack_path_7", "shack_path_9", ""},
            shack_path_11_junction_1 = {0, Vector(-1941.8, -1881, 269), "shack_path_10", "", "shack_path_11", ""},
        }
    else
        toner_start_junction = "shack_path_1_junction_1"
        toner_start_junction_input = 1
        toner_end_path = "shack_path_5"

        toner_paths = {
            shack_path_1 = {{1}, {"shack_path_1_junction_1"}, Vector(-2039.9, -2018.31, 231), Vector(-2039.9, -2018.31, 247), Vector(-2039.9, -1984.1, 247), Vector(-2024, -1984.1, 247), Vector(-2024, -1987.4, 247), Vector(-2022, -1987.4, 247), Vector(-2022, -1974, 247), Vector(-2022, -1974, 263.9), Vector(-2001.16, -1974, 263.9)},
            shack_path_2 = {{3, 1}, {"shack_path_1_junction_1", "shack_path_2_junction_1"}, Vector(-1995.16, -1974, 263.9), Vector(-1978, -1974, 263.9), Vector(-1978, -1974, 231.5), Vector(-1978, -1987.4, 231.5), Vector(-1957.9, -1987.4, 231.5), Vector(-1957.9, -1964.1, 231.5), Vector(-1957.9, -1964.1, 261.9), Vector(-1957.9, -1975, 261.9), Vector(-1957.9, -1975, 263.9), Vector(-1957.9, -1975, 263.9), Vector(-1927, -1975, 263.9), Vector(-1914, -1975, 242), Vector(-1914, -1975, 239.08)},
            shack_path_3 = {{3, 1}, {"shack_path_2_junction_1", "shack_path_3_junction_1"}, Vector(-1914, -1975, 233.08), Vector(-1914, -1975, 229), Vector(-1926.5, -1975, 229), Vector(-1926.5, -1987.4, 229), Vector(-1926.5, -1987.4, 220), Vector(-1896.1, -1987.4, 220), Vector(-1896.1, -1997, 220), Vector(-1896.1, -1997, 232), Vector(-1896.1, -2036, 232), Vector(-1896.1, -2036, 256.5), Vector(-1896.1, -2060.52, 256.5), Vector(-1896.1, -2060.52, 251), Vector(-1901.2, -2060.52, 251), Vector(-1901.2, -2060.52, 245.5)},
            shack_path_4 = {{0, 1}, {"shack_path_3_junction_1", "shack_path_4_junction_1"}, Vector(-1901.2, -2063.52, 242.5), Vector(-1896.1, -2063.52, 242.5), Vector(-1896.1, -2089, 242.5), Vector(-1896.1, -2089, 253), Vector(-1896.1, -2104.14, 253), Vector(-1896.1, -2104.14, 244.365)},
            shack_path_5 = {{3}, {"shack_path_4_junction_1"}, Vector(-1896.5, -2104.14, 238.365), Vector(-1896.5, -2104.14, 235)},
        }
        toner_junctions = {
            shack_path_1_junction_1 = {0, Vector(-1998.16, -1974, 263.9), "", "shack_path_1", "", "shack_path_2"},
            shack_path_2_junction_1 = {0, Vector(-1914, -1975, 236.08), "", "shack_path_2", "", "shack_path_3"},
            shack_path_3_junction_1 = {1, Vector(-1901.2, -2060.52, 242.5), "shack_path_4", "shack_path_3", "", ""},
            shack_path_4_junction_1 = {0, Vector(-1896.5, -2104.14, 241.365), "", "shack_path_4", "", "shack_path_5"},
        }
    end
elseif map == "a3_distillery" then
    if player:Attribute_GetIntValue("circuit_" .. map .. "_freezer_toner_junction_1_completed", 0) == 0 then
        toner_start_junction = "freezer_toner_junction_1"
        toner_start_junction_input = 2
        toner_end_path = "freezer_toner_path_6"

        toner_paths = {
            freezer_toner_path_1 = {{2}, {"freezer_toner_junction_1"}, Vector(476.447, 610, 315.269), Vector(471.5, 610, 315.269), Vector(470.5, 613, 315.269), Vector(462.2, 616, 315.269), Vector(462.2, 640, 315.269), Vector(465, 643, 315.269), Vector(467, 648, 315.269), Vector(467, 655, 315.269), Vector(469.2, 656.5, 315.269), Vector(468, 659.8, 315.269), Vector(457, 654, 315.269), Vector(447.5, 650, 315.269), Vector(447.5, 653, 315.269), Vector(440, 653, 315.269), Vector(430, 650, 315.269), Vector(420, 640, 315.269), Vector(420, 620, 315.269), Vector(426, 571, 315)},
            freezer_toner_path_2 = {{3, 2}, {"freezer_toner_junction_1", "freezer_toner_junction_2"}, Vector(426, 568, 312), Vector(426, 568, 302), Vector(426, 463.9, 302), Vector(439.9, 463.9, 302), Vector(439.9, 411.8, 302), Vector(460.1, 411.8, 302), Vector(460.1, 441.5, 302)},
            freezer_toner_path_3 = {{0, 2}, {"freezer_toner_junction_2", "freezer_toner_junction_5"}, Vector(460.1, 447.5, 302), Vector(460.1, 478.5, 302), Vector(460.1, 478.5, 291), Vector(460.1, 525, 291)},
            freezer_toner_alarm = {{1, 3}, {"freezer_toner_junction_5", "freezer_toner_junction_5a"}, Vector(460.1, 528, 294), Vector(460.1, 528, 311.01)},
            freezer_toner_alarm_2 = {{1}, {"freezer_toner_junction_5a"}, Vector(460.1, 528, 317.01), Vector(460.1, 528, 336), Vector(460.1, 530, 336)},
            freezer_toner_path_5 = {{3, 3}, {"freezer_toner_junction_5", "freezer_toner_junction_6"}, Vector(460.1, 528, 288), Vector(460.1, 528, 280), Vector(460.1, 575.9, 280), Vector(549.5, 575.9, 280), Vector(549.5, 575.9, 291.8), Vector(549.5, 572, 292), Vector(549.5, 572, 306.632)},
            freezer_toner_path_6 = {{0}, {"freezer_toner_junction_6"}, Vector(552.5, 572, 309.632), Vector(563.7, 572, 309.632), Vector(563.7, 575.9, 309.632), Vector(576.5, 575.9, 309.632), Vector(576.5, 575.9, 305)}
        }
        toner_junctions = {
            freezer_toner_junction_1 = {1, Vector(426, 568, 315), "", "", "freezer_toner_path_1", "freezer_toner_path_2"},
            freezer_toner_junction_2 = {0, Vector(460.1, 444.5, 302), "freezer_toner_path_3", "", "freezer_toner_path_2", ""},
            freezer_toner_junction_5 = {2, Vector(460.1, 528, 291), "", "freezer_toner_alarm", "freezer_toner_path_3", "freezer_toner_path_5"},
            freezer_toner_junction_5a = {0, Vector(460.1, 528, 314.01), "", "freezer_toner_alarm_2", "", "freezer_toner_alarm"},
            freezer_toner_junction_6 = {1, Vector(549.5, 572, 309.632), "freezer_toner_path_6", "", "", "freezer_toner_path_5"}
        }
    else
        toner_start_junction = "freezer_toner_junction_7"
        toner_start_junction_input = 0
        toner_end_path = "freezer_toner_path_8"

        toner_paths = {
            freezer_toner_path_7 = {{0}, {"freezer_toner_junction_7"}, Vector(427.4, 823.713, 295), Vector(427.4, 823.713, 289.394), Vector(427.4, 851.5, 289.394), Vector(300.2, 851.5, 289.394), Vector(300.2, 730.668, 289.394)},
            freezer_toner_path_8 = {{2}, {"freezer_toner_junction_7"}, Vector(300.2, 724.668, 289.394), Vector(300.2, 709.2, 289.394)},
        }
        toner_junctions = {
            freezer_toner_junction_7 = {0, Vector(302.2, 727.668, 289.394), "freezer_toner_path_7", "", "freezer_toner_path_8", ""},
        }
    end
elseif map == "a4_c17_zoo" then
    if player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 0 then
        toner_start_junction = "junction_health_trap_2"
        toner_start_junction_input = 1
        toner_end_path = ""

        toner_paths = {
            path_health_trap_1 = {{1}, {"junction_health_trap_2"}, Vector(5715.13, 1327.9, -71), Vector(5702, 1327.9, -71), Vector(5702, 1327.9, -76.25)},
            path_health_trap_7 = {{3, 1}, {"junction_health_trap_2", "health_trap_static_t2"}, Vector(5702, 1327.9, -82.25), Vector(5702, 1327.9, -88.125)},
            path_health_trap_8 = {{2, 0}, {"health_trap_static_t2", "junction_health_trap_3"}, Vector(5699, 1327.9, -91.125), Vector(5692, 1327.9, -91.125)},
            path_health_trap_5 = {{1}, {"junction_health_trap_3"}, Vector(5689, 1327.9, -88.125), Vector(5689, 1327.9, -81.625), Vector(5676.1, 1327.9, -81.625), Vector(5676.1, 1299, -81.625)},
            path_health_trap_3 = {{0, 2}, {"health_trap_static_t2", "health_trap_static_t"}, Vector(5705, 1327.9, -91.125), Vector(5716.5, 1327.9, -91.125)},
            path_health_trap_4 = {{3}, {"health_trap_static_t"}, Vector(5719.5, 1327.9, -94.125), Vector(5719.5, 1327.9, -105)},
            path_health_trap_6 = {{0, 2}, {"health_trap_static_t", "junction_health_trap_1"}, Vector(5722.5, 1327.9, -91.125), Vector(5757.63, 1327.9, -76.75)},
            path_health_trap_2 = {{0, 2}, {"junction_health_trap_1", "junction_health_trap_split"}, Vector(5763.63, 1327.9, -76.75), Vector(5783, 1327.9, -76.75)},
            path_health_trap_tripmine_1 = {{1}, {"junction_health_trap_split"}, Vector(5786, 1327.9, -73.7057), Vector(5786, 1327.9, -64.5), Vector(5827, 1327.9, -64.5)},
            path_health_trap_tripmine_3 = {{3}, {"junction_health_trap_split"}, Vector(5786, 1327.9, -79.7057), Vector(5786, 1327.9, -87), Vector(5827, 1327.9, -87)},
        }
        toner_junctions = {
            junction_health_trap_2 = {0, Vector(5702, 1327.9, -79.25), "", "path_health_trap_1", "", "path_health_trap_7"},
            health_trap_static_t2 = {4, Vector(5702, 1327.9, -91.125), "path_health_trap_3", "path_health_trap_7", "path_health_trap_8", ""},
            junction_health_trap_3 = {1, Vector(5689, 1327.9, -91.125), "path_health_trap_8", "path_health_trap_5", "", ""},
            health_trap_static_t = {4, Vector(5719.5, 1327.9, -91.125), "path_health_trap_6", "", "path_health_trap_3", "path_health_trap_4"},
            junction_health_trap_1 = {0, Vector(5760.63, 1327.9, -76.75), "path_health_trap_2", "", "path_health_trap_6", ""},
            junction_health_trap_split = {4, Vector(5786, 1327.9, -76.7057), "", "path_health_trap_tripmine_1", "path_health_trap_2", "path_health_trap_tripmine_3"},
        }
    else
        toner_start_junction = "junction_1"
        toner_start_junction_input = 2
        toner_end_path = "path_12"

        toner_paths = {
            path_1 = {{2}, {"junction_1"}, Vector(7155, 2439.9, -136), Vector(7164.1, 2439.9, -136), Vector(7164.1, 2448.1, -136), Vector(7160.1, 2448.1, -136), Vector(7160.1, 2503.9, -136), Vector(7189, 2503.9, -136)},
            path_2 = {{0, 1}, {"junction_1", "junction_2"}, Vector(7195, 2503.9, -136), Vector(7220, 2503.9, -136), Vector(7220, 2503.9, -120)},
            path_4 = {{}, {}, Vector(7409.25, 2224.25, -8), Vector(7409.25, 2218, -8.1), Vector(7409.25, 2218, -45)},
            path_3 = {{3}, {"junction_1"}, Vector(7192, 2503.9, -139), Vector(7192, 2503.9, -161), Vector(7236, 2503.9, -161), Vector(7236, 2503.9, -90)},
            path_5 = {{3, 2}, {"junction_2", "junction_3"}, Vector(7409.25, 2218, -51), Vector(7409.25, 2218, -67), Vector(7352.1, 2218, -67), Vector(7352.1, 2220, -67), Vector(7352.1, 2220, -24), Vector(7352.1, 2229, -24)},
            path_6 = {{1, 1}, {"junction_3", "junction_4"}, Vector(7352.1, 2232, -21), Vector(7352.1, 2232, -9), Vector(7370.63, 2262.63, -9)},
            path_7 = {{}, {}, Vector(7291.44, 2536.1, -127.516), Vector(7291.44, 2536.1, -142), Vector(7280.1, 2536.1, -142), Vector(7284.38, 2635.35, -135.125)},
            path_to_door = {{0, 2}, {"junction_4", "junction_7"}, Vector(7284.38, 2638.35, -138.125), Vector(7284.38, 2642.5, -138.125), Vector(7284.38, 2642.5, -121.5), Vector(7284.38, 2675.5, -121.5), Vector(7295, 2676, -121.5)},
            path_unlock_door = {{0}, {"junction_7"}, Vector(7301, 2676, -121.5), Vector(7316.5, 2676, -121.5), Vector(7316.5, 2676, -118)},
            path_8 = {{2, 2}, {"junction_4", "junction_pre_tv"}, Vector(7279.5, 2627, -136), Vector(7260, 2627, -136), Vector(7260, 2627, -142), Vector(7260,  2568.5, -142), Vector(7245.75,  2568.5, -142)},
            path_9 = {{1, 2}, {"junction_pre_tv", "junction_ab"}, Vector(7242.75, 2568.5, -133), Vector(7242.75, 2568.5, -139)},
            path_a = {{}, {}, Vector(7231.75, 2568.5, -127.75), Vector(7231.75, 2568.5, -150), Vector(7223.7, 2568.5, -150), Vector(7223.7, 2565, -150), Vector(7223.7, 2565, -119.801), Vector(7223.7, 2562, -119.801), Vector(7220.9, 2562, -119.801), Vector(7220.9, 2542.6, -119.801), Vector(7210.75, 2542.6, -119.801)},
            path_b = {{3, 2}, {"junction_ab", "junction_bc"}, Vector(7207.75, 2542.6, -122.801), Vector(7207.75, 2542.6, -166), Vector(7173, 2542.6, -166)},
            path_c = {{1, 3}, {"junction_bc", "junction_6"}, Vector(7170, 2542.6, -163), Vector(7170, 2542.6, -136), Vector(7127.5, 2542.6, -136), Vector(7127.5, 2542.6, -191.7), Vector(7127.5, 2558, -191.7), Vector(7109, 2558, -191.7)},
            path_12 = {{2}, {"junction_6"}, Vector(7106, 2555, -191.7), Vector(7106, 2536.1, -191.7), Vector(7106, 2536.1, -180)},
            path_11 = {{}, {}, Vector(6979.25, 2536.7, -169), Vector(6979.25, 2536.7, -156.3), Vector(6979.25, 2524, -156.3)},
        }
        toner_junctions = {
            junction_1 = {2, Vector(7192, 2503.9, -136), "path_2", "", "path_1", "path_3"},
            junction_2 = {0, Vector(7409.25, 2218, -48), "", "path_2", "", "path_5"},
            junction_3 = {1, Vector(7352.1, 2232, -24), "", "path_6", "path_5", ""},
            junction_4 = {1, Vector(7284.38, 2635.35, -138.125), "path_to_door", "path_6", "path_8", ""},
            junction_7 = {0, Vector(7298, 2676, -121.5), "path_unlock_door", "", "path_to_door", ""},
            junction_pre_tv = {1, Vector(7242.75, 2568.5, -142), "", "path_9", "path_8", ""},
            junction_ab = {1, Vector(7207.75, 2542.6, -119.801), "", "", "path_9", "path_b"},
            junction_bc = {1, Vector(7170, 2542.6, -166), "", "path_c", "path_b", ""},
            junction_6 = {1, Vector(7106, 2558, -191.7), "", "", "path_12", "path_c"},
        }
    end
elseif map == "a4_c17_tanker_yard" then
    toner_start_junction = "junction_demux_0"
    toner_start_junction_input = 2
    toner_end_path = ""

    toner_paths = {
        path_demux_0 = {{2}, {"junction_demux_0"}, Vector(2352.1, 6363.88, 140), Vector(2352.1, 6363.88, 138.494), Vector(2352.1, 6377.42, 138.494)},
        path_demux_1_0 = {{1, 2}, {"junction_demux_0", "junction_demux_1_0"}, Vector(2352.1, 6380.42, 141.494), Vector(2352.1, 6380.42, 152.125), Vector(2352.1, 6391.42, 152.125)},
        path_demux_1_1 = {{3, 2}, {"junction_demux_0", "junction_demux_1_1"}, Vector(2352.1, 6380.42, 135.494), Vector(2352.1, 6380.42, 119.369), Vector(2352.1, 6391.42, 119.369)},
        path_demux_2_0 = {{1, 2}, {"junction_demux_1_0", "junction_demux_2_0"}, Vector(2352.1, 6394.42, 155.125), Vector(2352.1, 6394.42, 160.125), Vector(2352.1, 6405.3, 160.125)},
        path_demux_2_1 = {{3, 2}, {"junction_demux_1_0", "junction_demux_2_1"}, Vector(2352.1, 6394.42, 149.125), Vector(2352.1, 6394.42, 143.119), Vector(2352.1, 6405.3, 143.119)},
        path_demux_2_2 = {{1, 2}, {"junction_demux_1_1", "junction_demux_2_2"}, Vector(2352.1, 6394.42, 122.369), Vector(2352.1, 6394.42, 127.369), Vector(2352.1, 6405.3, 127.369)},
        path_demux_2_3 = {{3, 2}, {"junction_demux_1_1", "junction_demux_2_3"}, Vector(2352.1, 6394.42, 116.369), Vector(2352.1, 6394.42, 108.744), Vector(2352.1, 6405.3, 108.744)},
        path_demux_3_0 = {{1}, {"junction_demux_2_0"}, Vector(2352.1, 6408.3, 163.125), Vector(2352.1, 6408.3, 167), Vector(2352.1, 6422.88, 167), Vector(2352.1, 6422.88, 161.5)},
        path_demux_3_3 = {{3}, {"junction_demux_2_1"}, Vector(2352.1, 6408.3, 140.119), Vector(2352.1, 6408.3, 136.5), Vector(2352.1, 6422.88, 136.5), Vector(2352.1, 6422.88, 143)},
        path_demux_3_6 = {{1}, {"junction_demux_2_3"}, Vector(2352.1, 6408.3, 111.744), Vector(2352.1, 6408.3, 117), Vector(2352.1, 6422.88, 117), Vector(2352.1, 6422.88, 125)},
    }
    toner_junctions = {
        junction_demux_0 = {3, Vector(2352.1, 6380.42, 138.494), "", "path_demux_1_0", "path_demux_0", "path_demux_1_1"},
        junction_demux_1_0 = {3, Vector(2352.1, 6394.42, 152.125), "", "path_demux_2_0", "path_demux_1_0", "path_demux_2_1"},
        junction_demux_1_1 = {3, Vector(2352.1, 6394.42, 119.369), "", "path_demux_2_2", "path_demux_1_1", "path_demux_2_3"},
        junction_demux_2_0 = {3, Vector(2352.1, 6408.3, 160.125), "", "path_demux_3_0", "path_demux_2_0", ""},
        junction_demux_2_1 = {3, Vector(2352.1, 6408.3, 143.119), "", "", "path_demux_2_1", "path_demux_3_3"},
        junction_demux_2_2 = {3, Vector(2352.1, 6408.3, 127.369), "", "", "path_demux_2_2", ""},
        junction_demux_2_3 = {3, Vector(2352.1, 6408.3, 108.744), "", "path_demux_3_6", "path_demux_2_3", ""},
    }
elseif map == "a4_c17_parking_garage" then
    toner_start_junction = "toner_junction_5"
    toner_start_junction_input = 0
    toner_end_path = "toner_path_8"

    toner_paths = {
        toner_path_1 = {{0}, {"toner_junction_5"}, Vector(-210, 11, 43), Vector(-210, 25, 43), Vector(-210, 25, 68.5), Vector(-210, 21.5, 68.5)},
        toner_path_9 = {{2, 1}, {"toner_junction_5", "toner_junction_1"}, Vector(-210, 15.5, 68.5), Vector(-210, 1, 68.5), Vector(-205.5, 1, 68.5), Vector(-205.5, 1, 59.25)},
        toner_path_2 = {{2, 1}, {"toner_junction_1", "toner_junction_2"}, Vector(-202.5, 1, 56.25), Vector(-197.75, 1, 56.25), Vector(-197.75, 1, 77)},
        toner_path_3 = {{}, {}, Vector(-333, -295, 68), Vector(-333, -295, 76),  Vector(-333, -320.5, 76), Vector(-329, -320.5, 76), Vector(-329, -336, 76), Vector(-329, -336, 58)},
        toner_path_6 = {{2, 3}, {"toner_junction_2", "toner_junction_3"}, Vector(-329, -339, 55), Vector(-329, -346.5, 55), Vector(-329, -346.5, 42.5), Vector(-329, -369.5, 42.5), Vector(-333, -369.5, 42.5), Vector(-333, -369.5, 49.5)},
        toner_path_5 = {{1, 3}, {"toner_junction_3", "toner_junction_4"}, Vector(-333, -369.5, 55.5), Vector(-333, -369.5, 72.5), Vector(-333, -358.5, 72.5), Vector(-333, -358.5, 80), Vector(-333, -362.5, 80)},
        toner_path_7 = {{}, {}, Vector(-190.6, -181.25, 176), Vector(-190.6, -181.25, 182.5)},
        toner_path_8 = {{1}, {"toner_junction_4"}, Vector(-190.6, -181.25, 188.5), Vector(-190.6, -181.25, 192.25), Vector(-190.6, -170, 192.25), Vector(-190.6, -170, 189.3)},
    }
    toner_junctions = {
        toner_junction_5 = {0, Vector(-210, 18.5, 68.5), "toner_path_1", "", "toner_path_9", ""},
        toner_junction_1 = {1, Vector(-205.5, 1, 56.25), "toner_path_1", "toner_path_9", "toner_path_2", ""},
        toner_junction_2 = {1, Vector(-329, -336, 55), "", "toner_path_3", "toner_path_6", ""},
        toner_junction_3 = {0, Vector(-333, -369.5, 52.5), "", "toner_path_5", "", "toner_path_6"},
        toner_junction_4 = {0, Vector(-190.6, -181.25, 185.5), "", "toner_path_8", "", "toner_path_7"},
    }
end

function DrawTonerPath(toner_path, powered)
    for i = 4, #toner_path do
        if powered then
            DebugDrawLine(toner_path[i - 1], toner_path[i], 0, 191, 255, false, -1)
        else
            DebugDrawLine(toner_path[i - 1], toner_path[i], 255, 165, 0, false, -1)
        end
    end
end

function DrawTonerJunction(junction, center, angles)
    local junction_type = junction[1]

    if junction_type == 0 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    elseif junction_type == 1 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        if map == "a4_c17_zoo" and center == Vector(7284.38, 2635.35, -138.125) then
            DrawTonerJunction(junction, Vector(7279.5, 2630, -136), angles)
        end
    elseif junction_type == 2 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-3))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    elseif junction_type == 3 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-3))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,-1,0))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-1))
        DebugDrawLine(center + min, center + max, 0, 255, 0, false, -1)
    elseif junction_type == 4 then
        local min = RotatePosition(Vector(0,0,0), angles, Vector(0,-3,0))
        local max = RotatePosition(Vector(0,0,0), angles, Vector(0,3,0))
        DebugDrawLine(center + min, center + max, 0, 255, 255, false, -1)

        min = RotatePosition(Vector(0,0,0), angles, Vector(0,0,-3))
        max = RotatePosition(Vector(0,0,0), angles, Vector(0,0,0))
        DebugDrawLine(center + min, center + max, 0, 255, 255, false, -1)
    end
end

function PowerTonerPath(junction, junction_name, junction_input)
    if map == "a2_train_yard" then
        junction_name = "5325_4704_" .. junction_name
    elseif map == "a4_c17_tanker_yard" then
        junction_name = "1489_4074_" .. junction_name
    elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
        junction_name = "589_" .. junction_name
    end

    local junction_entity = Entities:FindByName(nil, junction_name)

    if map == "a2_train_yard" then
        junction_name = string.gsub(junction_name, "5325_4704_", "")
    elseif map == "a4_c17_tanker_yard" then
        junction_name = string.gsub(junction_name, "1489_4074_", "")
    elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
        junction_name = string.gsub(junction_name, "589_", "")
    end

    local junction_rotation = junction_entity:Attribute_GetIntValue("junction_rotation", 0)

    local junction_types = {
        { -- Type 0: I Junction
            {{2}, { }, {0}, { }}, -- Rotation 0
            {{ }, {3}, { }, {1}}, -- Rotation 1
            {{2}, { }, {0}, { }}, -- Rotation 2
            {{ }, {3}, { }, {1}}, -- Rotation 3
        },
        { -- Type 1: L Junction
            {{1}, {0}, { }, { }}, -- Rotation 0
            {{ }, {2}, {1}, { }}, -- Rotation 1
            {{ }, { }, {3}, {2}}, -- Rotation 2
            {{3}, { }, { }, {0}}, -- Rotation 3
        },
        { -- Type 2: T Junction
            {{2, 3}, {    }, {0, 3}, {0, 2}}, -- Rotation 0
            {{1, 3}, {0, 3}, {    }, {0, 1}}, -- Rotation 1
            {{1, 2}, {0, 2}, {0, 1}, {    }}, -- Rotation 2
            {{    }, {2, 3}, {1, 3}, {1, 2}}, -- Rotation 3
        },
        { -- Type 3: LL Junction
            {{1}, {0}, {3}, {2}}, -- Rotation 0
            {{3}, {2}, {1}, {0}}, -- Rotation 1
            {{1}, {0}, {3}, {2}}, -- Rotation 2
            {{3}, {2}, {1}, {0}}, -- Rotation 3
        },
    }

    local junction_type = junction[1]
    if junction_type == 4 then
        junction_type = 2
    end
    local output_toner_paths = junction_types[junction_type + 1][junction_rotation + 1][junction_input + 1]

    for i = 1, #output_toner_paths do
        local toner_path_powered_name = junction[output_toner_paths[i] + 3]

        if toner_path_powered_name ~= "" then
            if map == "a2_train_yard" then
                toner_path_powered_name = "5325_4704_" .. toner_path_powered_name
            elseif map == "a4_c17_tanker_yard" then
                toner_path_powered_name = "1489_4074_" .. toner_path_powered_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                toner_path_powered_name = "589_" .. toner_path_powered_name
            end

            local toner_path_powered_entity = Entities:FindByName(nil, toner_path_powered_name)
            if toner_path_powered_entity:Attribute_GetIntValue("toner_path_powered", 0) == 0 then
                toner_path_powered_entity:Attribute_SetIntValue("toner_path_powered", 1)
                SendToConsole("ent_fire_output " .. toner_path_powered_name .. " OnPowerOn")

                if map == "a2_train_yard" then
                    toner_path_powered_name = string.gsub(toner_path_powered_name, "5325_4704_", "") 
                elseif map == "a4_c17_tanker_yard" then
                    toner_path_powered_name = string.gsub(toner_path_powered_name, "1489_4074_", "")
                elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                    toner_path_powered_name = string.gsub(toner_path_powered_name, "589_", "")
                end

                for j = 1, #toner_paths[toner_path_powered_name][1] do
                    local next_toner_junction_name = toner_paths[toner_path_powered_name][2][j]
                    if next_toner_junction_name ~= "" and next_toner_junction_name ~= junction_name then
                        local next_toner_junction = toner_junctions[next_toner_junction_name]
                        local next_toner_junction_input = toner_paths[toner_path_powered_name][1][j]
                        PowerTonerPath(next_toner_junction, next_toner_junction_name, next_toner_junction_input)
                    end
                end

                if toner_path_powered_name == toner_end_path then
                    if map == "a3_hotel_lobby_basement" then
                        if player:Attribute_GetIntValue("circuit_" .. map .. "_junction_1_completed", 0) == 0 then
                            Entities:FindByName(nil, "power_stake_2_start"):Attribute_SetIntValue("used", 0)
                        else
                            player:Attribute_SetIntValue("EnabledHotelLobbyPower", 1)
                        end
                    end

                    player:Attribute_SetIntValue("circuit_" .. map .. "_" .. toner_start_junction .. "_completed", 1)

                    if map == "a4_c17_zoo" and toner_start_junction == "junction_1" then
                        DoEntFireByInstanceHandle(Entities:FindByName(nil, "589_toner_port_5"), "RunScriptFile", "multitool", 0, nil, nil)
                    else
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())
                        StartSoundEventFromPosition("Toner.PortComplete", player:EyePosition())

                        player:SetThink(function()
                            DebugDrawClear()
                        end, "TonerComplete", 3)
                    end
                end
            end
        end
    end
end

function ToggleTonerJunction()
    local junction_name = thisEntity:GetName()

    if map == "a2_train_yard" then
        junction_name = string.gsub(junction_name, "5325_4704_", "")
    elseif map == "a4_c17_tanker_yard" then
        junction_name = string.gsub(junction_name, "1489_4074_", "")
    elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
        junction_name = string.gsub(junction_name, "589_", "")
    end

    local junction = toner_junctions[junction_name]

    if junction then
        local junction_type = junction[1]
        if junction_type == 4 then
            return
        end

        if thisEntity:Attribute_GetIntValue("junction_rotation", 0) == 3 then
            thisEntity:Attribute_SetIntValue("junction_rotation", 0)
        else
            thisEntity:Attribute_SetIntValue("junction_rotation", thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1)
        end

        DebugDrawClear()

        local angles = thisEntity:GetAngles()
        StartSoundEventFromPosition("Toner.JunctionRotate", player:EyePosition())

        local new_index = thisEntity:Attribute_GetIntValue("junction_rotation", 0) + 1
        local old_index = new_index - 1
        if old_index == 0 then
            old_index = 4
        end

        local ent = Entities:FindByClassname(nil, "info_hlvr_toner_path")
        while ent do
            ent:FireOutput("OnPowerOff", nil, nil, nil, 0)
            ent:Attribute_SetIntValue("toner_path_powered", 0)
            ent = Entities:FindByClassname(ent, "info_hlvr_toner_path")
        end

        PowerTonerPath(toner_junctions[toner_start_junction], toner_start_junction, toner_start_junction_input)

        for toner_junction_name, toner_junction in pairs(toner_junctions) do
            if map == "a2_train_yard" then
                toner_junction_name = "5325_4704_" .. toner_junction_name
            elseif map == "a4_c17_tanker_yard" then
                toner_junction_name = "1489_4074_" .. toner_junction_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                toner_junction_name = "589_" .. toner_junction_name
            end

            local junction_entity = Entities:FindByName(nil, toner_junction_name)
            local angles = junction_entity:GetAngles()
            angles = QAngle(angles.x, angles.y, junction_entity:Attribute_GetIntValue("junction_rotation", 0) * 90)
            DrawTonerJunction(toner_junction, toner_junction[2], angles)
        end

        for toner_path_name, toner_path in pairs(toner_paths) do
            if map == "a2_train_yard" then
                toner_path_name = "5325_4704_" .. toner_path_name
            elseif map == "a4_c17_tanker_yard" then
                toner_path_name = "1489_4074_" .. toner_path_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                toner_path_name = "589_" .. toner_path_name
            end

            if toner_path_name == "toner_path_1" and map ~= "a3_hotel_street" or (toner_path_name == "freezer_toner_path_1") or (toner_path_name == "freezer_toner_path_7" and player:Attribute_GetIntValue("circuit_" .. map .. "_freezer_toner_junction_1_completed", 0) == 1) or toner_path_name == "5325_4704_train_gate_path_start" or toner_path_name == "shack_path_6" or toner_path_name == "shack_path_1" or toner_path_name == "path_health_trap_1" or toner_path_name == "589_path_1" or (toner_path_name == "589_path_4" and Entities:FindByName(nil, "589_path_2"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_7" and Entities:FindByName(nil, "589_path_6"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_a" and Entities:FindByName(nil, "589_path_9"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_11" and Entities:FindByName(nil, "589_path_12"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (map == "a4_c17_parking_garage" and (toner_path_name == "toner_path_3" and Entities:FindByName(nil, "toner_path_2"):Attribute_GetIntValue("toner_path_powered", 0) == 1 or toner_path_name == "toner_path_7" and Entities:FindByName(nil, "toner_path_5"):Attribute_GetIntValue("toner_path_powered", 0) == 1)) or toner_path_name == "1489_4074_path_demux_0" then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
            end

            if map == "a3_hotel_lobby_basement" and toner_path_name == "toner_path_7" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_1_completed", 0) == 1 then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
            end

            if map == "a3_hotel_street" and toner_path_name == "toner_path_7" then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
            end

            DrawTonerPath(toner_path, Entities:FindByName(nil, toner_path_name):Attribute_GetIntValue("toner_path_powered", 0) == 1)
        end
    end
end

if class == "info_hlvr_toner_port" and (thisEntity:Attribute_GetIntValue("used", 0) == 0 or (thisEntity:Attribute_GetIntValue("redraw_toner", 0) == 1 and thisEntity:Attribute_GetIntValue("disabled", 0) == 0)) then
    DoEntFireByInstanceHandle(thisEntity, "OnPlugRotated", "", 0, nil, nil)
    DebugDrawClear()

    if name == "freezer_toner_outlet_1" then
        thisEntity:Attribute_SetIntValue("disabled", 0)
    end

    if thisEntity:Attribute_GetIntValue("redraw_toner", 0) == 0 then
        if map == "a4_c17_parking_garage" then
            if name == "toner_port" then
                Entities:FindByName(nil, "falling_cabinet_door"):ApplyLocalAngularVelocityImpulse(Vector(0, 1200, 0))
            end
        end
    end

    if toner_junctions then
        for junction_name, junction in pairs(toner_junctions) do
            if map == "a2_train_yard" then
                junction_name = "5325_4704_" .. junction_name
            elseif map == "a4_c17_tanker_yard" then
                junction_name = "1489_4074_" .. junction_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                junction_name = "589_" .. junction_name
            end

            local junction_entity = Entities:FindByName(nil, junction_name)
            local angles = junction_entity:GetAngles()
            angles = QAngle(angles.x, angles.y, junction_entity:Attribute_GetIntValue("junction_rotation", 0) * 90)
            DrawTonerJunction(junction, junction[2], angles)
        end

        for toner_path_name, toner_path in pairs(toner_paths) do
            if map == "a2_train_yard" then
                toner_path_name = "5325_4704_" .. toner_path_name
            elseif map == "a4_c17_tanker_yard" then
                toner_path_name = "1489_4074_" .. toner_path_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                toner_path_name = "589_" .. toner_path_name
            end

            if toner_path_name == "toner_path_1" and map ~= "a3_hotel_street" or toner_path_name == "freezer_toner_path_1" or (toner_path_name == "freezer_toner_path_7" and player:Attribute_GetIntValue("circuit_" .. map .. "_freezer_toner_junction_1_completed", 0) == 1) or toner_path_name == "5325_4704_train_gate_path_start" or toner_path_name == "shack_path_6" or toner_path_name == "shack_path_1" or toner_path_name == "path_health_trap_1" or toner_path_name == "589_path_1" or (toner_path_name == "589_path_4" and Entities:FindByName(nil, "589_path_2"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_7" and Entities:FindByName(nil, "589_path_6"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_a" and Entities:FindByName(nil, "589_path_9"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (toner_path_name == "589_path_11" and Entities:FindByName(nil, "589_path_12"):Attribute_GetIntValue("toner_path_powered", 0) == 1) or (map == "a4_c17_parking_garage" and (toner_path_name == "toner_path_3" and Entities:FindByName(nil, "toner_path_2"):Attribute_GetIntValue("toner_path_powered", 0) == 1 or toner_path_name == "toner_path_7" and Entities:FindByName(nil, "toner_path_5"):Attribute_GetIntValue("toner_path_powered", 0) == 1)) or toner_path_name == "1489_4074_path_demux_0" then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
                SendToConsole("ent_fire_output " .. toner_path_name .. " OnPowerOn")
            end

            if map == "a3_hotel_lobby_basement" and toner_path_name == "toner_path_7" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_1_completed", 0) == 1 then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
                SendToConsole("ent_fire_output " .. toner_path_name .. " OnPowerOn")
            end

            if map == "a3_hotel_street" and toner_path_name == "toner_path_7" then
                Entities:FindByName(nil, toner_path_name):Attribute_SetIntValue("toner_path_powered", 1)
                SendToConsole("ent_fire_output " .. toner_path_name .. " OnPowerOn")
            end
        end

        PowerTonerPath(toner_junctions[toner_start_junction], toner_start_junction, toner_start_junction_input)

        for toner_path_name, toner_path in pairs(toner_paths) do
            if map == "a2_train_yard" then
                toner_path_name = "5325_4704_" .. toner_path_name
            elseif map == "a4_c17_tanker_yard" then
                toner_path_name = "1489_4074_" .. toner_path_name
            elseif map == "a4_c17_zoo" and player:Attribute_GetIntValue("circuit_" .. map .. "_junction_health_trap_2_completed", 0) == 1 then
                toner_path_name = "589_" .. toner_path_name
            end

            DrawTonerPath(toner_path, Entities:FindByName(nil, toner_path_name):Attribute_GetIntValue("toner_path_powered", 0) == 1)
        end
    end

    thisEntity:Attribute_SetIntValue("used", 1)
    thisEntity:Attribute_SetIntValue("redraw_toner", 0)
end

if class == "info_hlvr_toner_junction" and toner_start_junction ~= nil and (player:Attribute_GetIntValue("circuit_" .. map .. "_" .. toner_start_junction .. "_completed", 0) == 0 or map == "a4_c17_zoo") then
    ToggleTonerJunction()
end

if model == "models/props_combine/combine_doors/combine_door_sm01.vmdl" or model == "models/props_combine/combine_lockers/combine_locker_doors.vmdl" then
    if thisEntity:GetSequence() == "open_idle" then
        return
    end

    local ent = Entities:FindByClassnameNearest("info_hlvr_holo_hacking_plug", thisEntity:GetCenter(), 40)

    if ent and ent:Attribute_GetIntValue("used", 0) == 0 then
        ent:Attribute_SetIntValue("used", 1)
        DoEntFireByInstanceHandle(ent, "BeginHack", "", 0, nil, nil)
        DoEntFireByInstanceHandle(ent, "EndHack", "", 1.8, nil, nil)
        ent:FireOutput("OnHackSuccess", nil, nil, nil, 1.8)
        ent:FireOutput("OnPuzzleSuccess", nil, nil, nil, 1.8)
    end
end

-- Combine Fabricator
if class == "prop_hlvr_crafting_station_console" then
    local function AnimTagListener(sTagName, nStatus)
        if sTagName == 'Bootup Done' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("crafting_station_ready", 1)
        elseif sTagName == 'Crafting Done' and nStatus == 2 then
            if Convars:GetStr("chosen_upgrade") == "pistol_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("pistol_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_aimdownsights ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_burstfire" then
                player:Attribute_SetIntValue("pistol_upgrade_burstfire", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_pistol_upgrade_burstfire ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_hopper" then
                player:Attribute_SetIntValue("pistol_upgrade_hopper", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "pistol_upgrade_lasersight" then
                player:Attribute_SetIntValue("pistol_upgrade_lasersight", 1)
                SendToConsole("give weapon_pistol")
                SendToConsole("viewmodel_update")
                SendToConsole("pistol_use_new_accuracy 1")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_grenadelauncher" then
                player:Attribute_SetIntValue("shotgun_upgrade_grenadelauncher", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_grenadelauncher ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_doubleshot" then
                player:Attribute_SetIntValue("shotgun_upgrade_doubleshot", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_shotgun_upgrade_doubleshot ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_lasersight" then
                player:Attribute_SetIntValue("shotgun_upgrade_lasersight", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "shotgun_upgrade_hopper" then
                player:Attribute_SetIntValue("shotgun_upgrade_hopper", 1)
                SendToConsole("give weapon_shotgun")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_aimdownsights" then
                player:Attribute_SetIntValue("smg_upgrade_aimdownsights", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")
                SendToConsole("ent_fire text_smg_upgrade_aimdownsights ShowMessage")
                SendToConsole("snd_sos_start_soundevent Instructor.StartLesson")
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_lasersight" then
                player:Attribute_SetIntValue("smg_upgrade_lasersight", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade does not have a model yet", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            elseif Convars:GetStr("chosen_upgrade") == "smg_upgrade_casing" then
                player:Attribute_SetIntValue("smg_upgrade_casing", 1)
                SendToConsole("give weapon_ar2")
                SendToConsole("viewmodel_update")

                -- TODO: Implement weapon upgrade and remove message
                local ent = SpawnEntityFromTableSynchronous("game_text", {["effect"]=2, ["spawnflags"]=1, ["color"]="230 230 230", ["color2"]="0 0 0", ["fadein"]=0, ["fadeout"]=0.15, ["fxtime"]=0.25, ["holdtime"]=10, ["x"]=-1, ["y"]=0.6})
                DoEntFireByInstanceHandle(ent, "SetText", "This weapon upgrade animation is not implemented", 0, nil, nil)
                DoEntFireByInstanceHandle(ent, "Display", "", 0, nil, nil)
            end

            SendToConsole("ent_fire point_clientui_world_panel Enable")
            SendToConsole("ent_fire weapon_in_fabricator Kill")
            thisEntity:SetGraphParameterBool("bCrafting", false)
            Convars:SetStr("chosen_upgrade", "")
            Convars:SetStr("weapon_in_crafting_station", "")
        elseif sTagName == 'Trays Retracted' and nStatus == 2 then
            thisEntity:Attribute_SetIntValue("cancel_cooldown_done", 1)
        end
    end

    thisEntity:RegisterAnimTagListener(AnimTagListener)
end
