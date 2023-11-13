x_bits = 10
y_bits = 9
point_width = 14
x_coor = 0 
y_coor = 1
depth = 4096

point1 = (60, 320)
point2 = (180, 350)

preface = "-- Copyright (C) 2017  Intel Corporation. All rights reserved. \n-- Your use of Intel Corporation's design tools, logic functions \n-- and other software and tools, and its AMPP partner logic \n-- functions, and any output files from any of the foregoing \n-- (including device programming or simulation files), and any \n-- associated documentation or information are expressly subject \n-- to the terms and conditions of the Intel Program License \n-- Subscription Agreement, the Intel Quartus Prime License Agreement,\n-- the Intel MegaCore Function License Agreement, or other \n-- applicable license agreement, including, without limitation, \n-- that your use is for the sole purpose of programming logic \n-- devices manufactured by Intel and sold by Intel or its \n-- authorized distributors.  Please refer to the applicable \n-- agreement for further details.\n\n-- Quartus Prime generated Memory Initialization File (.mif)\n\nWIDTH=39;\nDEPTH={};\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\nCONTENT BEGIN\n".format(depth)

footer = "END;\n"

white = 1
black = 0

static_starts = [
    (305, 54),
    (237, 413),
    (259, 300)
]

static_ends = [
    (387, 420),
    (306, 51),
    (360, 300)
]

start_points = [
    (60, 320),
    (60, 47),
    (61, 47)
]

end_points = [
    (180, 350),
    (61, 320),
    (180, 20)
]

file = open("line_data.mif", "w")

file.write(preface)

address = 0
line_number = 0
while line_number < len(static_starts):
    number = 1
    number = (number << x_bits) + static_starts[line_number][x_coor]
    number = (number << y_bits) + static_starts[line_number][y_coor]
    
    number = (number << x_bits) + static_ends[line_number][x_coor]
    number = (number << y_bits) + static_ends[line_number][y_coor]
        
    print("\t{}    :   {};".format(address, number))
    file.write("\t{}    :   {};\n".format(address, number))
    line_number += 1
    address += 1

animation_step = 0
while animation_step < 100:
    for i in range (1, -1, -1):
        line_number = 0
        while line_number < len(start_points):
            number = i
            number = (number << x_bits) + start_points[line_number][x_coor]
            number = (number << y_bits) + (start_points[line_number][y_coor] + animation_step)

            number = (number << x_bits) + end_points[line_number][x_coor]
            if (line_number == 2):
                number = (number << y_bits) + end_points[line_number][y_coor]
            else:
                number = (number << y_bits) + (end_points[line_number][y_coor] + animation_step)
                
            print("\t{}    :   {};".format(address, number))
            file.write("\t{}    :   {};\n".format(address, number))
            line_number += 1
            address += 1
    
    animation_step += 1

if address < depth - 1:
    print("\t[{}..{}]  :   0;".format(address, depth - 1))
    file.write("\t[{}..{}]  :   0;\n".format(address, depth - 1))

print(footer)
file.write(footer)
file.close()