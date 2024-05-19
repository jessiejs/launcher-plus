-- create shorthand constants
pd = playdate
gfx = pd.graphics
sys = pd.system
net = pd.server
snd = pd.sound
fontBold = playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold)
fontHeader = playdate.graphics.font.new("./fonts/header")
fontHeader = fontBold
SCREEN_WIDTH = 0
SCREEN_HEIGHT = 0
BUTTON_HEIGHT = 0
EDGE_PADDING = 0
SMALL_GAP = 5
GAMELIST = playdate.system.getInstalledGameList()
icons = {
	check = playdate.graphics.image.new("assets/icons/check"),
	x = playdate.graphics.image.new("assets/icons/x")
}
kPermissionPushbackStrong = 10
kPermissionPushbackNormal = 5
kPermissionPushbackNone = 0
