text = "Space Invaders"
from PIL import Image, ImageDraw, ImageFont
import numpy as np
myfont = ImageFont.truetype("verdanab.ttf", 54)
size = myfont.getbbox(text)[2:]
img = Image.new("1",size,"black")
draw = ImageDraw.Draw(img)
draw.text((0, 0), text, "white", font=myfont)
# w = 
pixels = np.array(img, dtype=np.uint8)
chars = np.array(['0','4'], dtype="U1")[pixels]
strings = chars.view('U' + str(chars.shape[1])).flatten()
# print( "\n".join(strings))

# print(len(strings[1]))
# print(len(strings[32]))

depth = (640 * 480)

preface = "-- Copyright (C) 2017  Intel Corporation. All rights reserved. \n-- Your use of Intel Corporation's design tools, logic functions \n-- and other software and tools, and its AMPP partner logic \n-- functions, and any output files from any of the foregoing \n-- (including device programming or simulation files), and any \n-- associated documentation or information are expressly subject \n-- to the terms and conditions of the Intel Program License \n-- Subscription Agreement, the Intel Quartus Prime License Agreement,\n-- the Intel MegaCore Function License Agreement, or other \n-- applicable license agreement, including, without limitation, \n-- that your use is for the sole purpose of programming logic \n-- devices manufactured by Intel and sold by Intel or its \n-- authorized distributors.  Please refer to the applicable \n-- agreement for further details.\n\n-- Quartus Prime generated Memory Initialization File (.mif)\n\nWIDTH=4;\nDEPTH={};\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\nCONTENT BEGIN\n".format(depth)

footer = "END;\n"

file = open("start_menu.mif", "w")

file.write(preface)

address = 0

print(len(strings))
print(len(strings[1]))
line = 0
while line < len(strings):
    data = ""
    # for i in range(0, round((640 - len(strings[1])) / 2)):
    data += data + "0" * 105

    data += strings[line]

    # for i in range(0, round((640 - len(strings[1])) / 2)):
    data += data + "0" * 106

    # print("\t{}    :   {};".format(address, data))
    for i in range(len(data)):
        file.write("\t{}    :   {};\n".format(address, data[i]))
        address += 1
    line += 1

# print(" i got here")
while address < (640 * 480):
    file.write("\t{}    :   0;\n".format(address))
    address += 1
print(footer)
file.write(footer)
file.close()