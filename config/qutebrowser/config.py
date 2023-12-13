config.load_autoconfig()

c.content.default_encoding = "UTF-8"
c.content.pdfjs = True # View PDFs in-browser

# Show confirmation box when there are ongoing downloads
c.confirm_quit = ["downloads"]

c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = True
c.input.insert_mode.auto_load = True
c.input.insert_mode.leave_on_load = True

c.scrolling.bar = "always"
c.tabs.last_close = "close"

c.tabs.mousewheel_switching = False
c.tabs.show = "multiple"
c.tabs.tabs_are_windows = True # Change to False to not use sway tabs

c.content.blocking.method = "adblock"
c.content.blocking.adblock.lists = ["https://easylist.to/easylist/easylist.txt", "https://easylist.to/easylist/easyprivacy.txt", "https://easylist-downloads.adblockplus.org/easylistdutch.txt", "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt", "https://www.i-dont-care-about-cookies.eu/abp/", "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"]

# Extreme privacy, breaks most things 
c.content.cookies.accept = "never" # Disallow all cookies
c.content.cookies.store = False
c.content.canvas_reading = False # Disallow sites to read canvas
c.content.desktop_capture = False # Disallow screen capture
c.content.media.audio_video_capture = False
c.content.media.video_capture = False
c.content.autoplay = False # Disallow autoplay
c.content.geolocation = False # Disallow location
c.content.headers.do_not_track = True # Send Do-Not-Track header
c.content.headers.referer = "never" # Don't send referer header
c.content.javascript.enabled = False #  Disable JavaScript
c.content.local_storage = False # Disable localStorage & WebSQL
c.content.notifications.enabled = False # Disable notifications
c.content.webgl = False # Disable WebGL
c.content.site_specific_quirks.enabled = False # Don't try to make sites work. Fuck em!

c.fonts.completion.entry = "default_size default_family"
c.fonts.contextmenu = "default_size sans-serif"
c.fonts.default_family = "monospace"
c.fonts.default_size = "14pt"
c.fonts.web.family.fixed = "monospace"
c.fonts.web.family.serif = "serif"
c.fonts.web.family.standard = "sans-serif"
c.fonts.web.size.default = 17
c.fonts.web.size.default_fixed = 21

c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]

c.url.searchengines['DEFAULT'] = "https://lite.qwant.com/?q={}"
c.url.searchengines['g'] = "https://www.google.com/search?hl=en&q={}"
c.url.searchengines['m'] = "https://search.marginalia.nu/search?query={}"
c.url.searchengines['w'] = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1"

config.bind("<Alt-Left>", "back", mode="normal")
config.bind("<Alt-Right>", "forward", mode="normal")
config.bind("<Ctrl-->", "zoom-out", mode="normal")
config.bind("<Ctrl-=>", "zoom-in", mode="normal")
config.bind("<Ctrl-Shift-i>", "devtools", mode="normal")
config.bind("<Ctrl-Shift-l>", "yank pretty-url", mode="normal")
config.bind("<Ctrl-Tab>", "tab-next", mode="normal")
config.bind("<Ctrl-f>", "cmd-set-text /", mode="normal")
config.bind("<Ctrl-l>", "cmd-set-text -s :open", mode="normal")
config.bind("<Ctrl-r>", "reload", mode="normal")
config.bind("<Ctrl-t>", "cmd-set-text -s :open -t ", mode="normal")
config.bind("<Ctrl-u>", "view-source", mode="normal")

# Duplicated from above but for insert mode
config.bind("<Alt-Left>", "back", mode="insert")
config.bind("<Alt-Right>", "forward", mode="insert")
config.bind("<Ctrl-->", "zoom-out", mode="insert")
config.bind("<Ctrl-=>", "zoom-in", mode="insert")
config.bind("<Ctrl-Shift-i>", "devtools", mode="insert")
config.bind("<Ctrl-Shift-l>", "yank pretty-url", mode="insert")
config.bind("<Ctrl-Tab>", "tab-next", mode="insert")
config.bind("<Ctrl-f>", "cmd-set-text /", mode="insert")
config.bind("<Ctrl-l>", "cmd-set-text -s :open", mode="insert")
config.bind("<Ctrl-r>", "reload", mode="insert")
config.bind("<Ctrl-t>", "cmd-set-text -s :open -t ", mode="insert")
config.bind("<Ctrl-u>", "view-source", mode="insert")

