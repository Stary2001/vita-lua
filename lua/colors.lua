-- colors
local bit = require 'bit'

colors = {}

colors.red = 0xff0000ff
colors.green = 0xff00ff00
colors.blue = 0xffff0000
colors.white = 0xffffffff
colors.black = 0xff000000
colors.yellow = bit.bor(colors.red, colors.green)
colors.purple = bit.bor(colors.red, colors.blue)
colors.cyan = bit.bor(colors.green, colors.blue)
