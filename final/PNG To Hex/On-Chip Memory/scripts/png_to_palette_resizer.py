from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
import numpy as np
def hex_to_rgb(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
def rgb_to_hex(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
filename = input("What's the image name? ")
new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))
# palette_hex = ['0xFFFFFF','0x000000', '0x3F0606', '0xAB0000', '0x5A2712', '0xFFC78F', '0x154269', '0x111A8F'] # for kid
# palette_hex = ['0xB35810','0xEC8811', '0xFFA82A', '0xE4A542', '0xE9C565', '0xF9E182', '0xFFC85F', '0xFFD46A'] # for background
# palette_hex = ['0xFFFFFF','0x000000', '0xEFEBEF', '0x949694', '0xD6D7D6'] # for spike
# palette_hex = ['0xFFFFFF','0xABF4F9'] # for block
palette_hex = ['0xFFFFFF','0x000000', '0x737173', '0xDEDBDE', '0xEF4110', '0xDED742', '0x7B8E29', '0x00FF00'] # for checkpoint
# palette_hex = ['0xA5539F','0x000000', '0xFFFFFF'] # for dead
palette_rgb = [hex_to_rgb(color) for color in palette_hex]

pixel_tree = KDTree(palette_rgb)
im = Image.open("./sprite_originals/" + filename+ ".png") #Can be many different formats.
im = im.convert("RGBA")
layer = Image.new('RGBA',(new_w, new_h), (0,0,0,0))
layer.paste(im, (0, 0))
im = layer
#im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
pix = im.load()
pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
pix_freqs_sorted.reverse()
print(pix)
outImg = Image.new('RGB', im.size, color='white')
outFile = open("./sprite_bytes/" + filename + '.txt', 'w')
i = 0
for y in range(im.size[1]):
    for x in range(im.size[0]):
        pixel = im.getpixel((x,y))
        print(pixel)
        if(pixel[3] < 200):
            outImg.putpixel((x,y), palette_rgb[0])
            outFile.write("%x\n" %(0))
            print(i)
        else:
            index = pixel_tree.query(pixel[:3])[1]
            outImg.putpixel((x,y), palette_rgb[index])
            outFile.write("%x\n" %(index))
        i += 1
outFile.close()
outImg.save("./sprite_converted/" + filename + ".png" )
