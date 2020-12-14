def remap_in_all_modes(remappings):
    for mode in c.bindings.default:
        new_dict = {}
        for key in c.bindings.default[mode]:
            if key[0] == '<':
                # ignore meta-characters
                new_dict[key] = c.bindings.default[mode][key]
            else:
                new_key = ""
                for key_character in key:
                    new_key_character = key_character
                    if key_character in remappings:
                        new_key_character = remappings[key_character]
                    new_key += new_key_character
                new_dict[new_key] = c.bindings.default[mode][key]
        c.bindings.default[mode] = new_dict

remappings = {'i': 'u', 'j': 'n', 'k': 'e', 'l': 'i', 'n': 'k', 'u': 'l', 'I': 'U', 'J': 'N', 'K': 'E', 'L': 'I', 'N': 'K', 'U': 'L', 'x': 'd', 'd': 'x'}
remap_in_all_modes(remappings)

config.load_autoconfig()

config.bind('z', 'hint links spawn --detach mpv --force-window --no-terminal --ytdl {hint-url}')

config.bind('t', 'set-cmd-text -s :open -t')

config.bind('ss', 'session-save')
config.bind('sl', 'set-cmd-text -s :session-load -t')
config.bind('<Ctrl-x>', 'spawn xdotool windowkill (xdotool getactivewindow)')

config.bind('p', 'tab-pin')

config.unbind('T')
config.bind('TIH', 'config-cycle -p -u *://*.{url:host}/* content.images ;; reload')
config.bind('TIh', 'config-cycle -p -u *://{url:host}/* content.images ;; reload')
config.bind('TIu', 'config-cycle -p -u {url} content.images ;; reload')
config.bind('TPH', 'config-cycle -p -u *://*.{url:host}/* content.plugins ;; reload')
config.bind('TPh', 'config-cycle -p -u *://{url:host}/* content.plugins ;; reload')
config.bind('TPu', 'config-cycle -p -u {url} content.plugins ;; reload')
config.bind('TSH', 'config-cycle -p -u *://*.{url:host}/* content.javascript.enabled ;; reload')
config.bind('TSh', 'config-cycle -p -u *://{url:host}/* content.javascript.enabled ;; reload')
config.bind('TSu', 'config-cycle -p -u {url} content.javascript.enabled ;; reload')
config.bind('Th', 'back -t')
config.bind('TiH', 'config-cycle -p -t -u *://*.{url:host}/* content.images ;; reload')
config.bind('Tih', 'config-cycle -p -t -u *://{url:host}/* content.images ;; reload')
config.bind('Tiu', 'config-cycle -p -t -u {url} content.images ;; reload')
config.bind('Tl', 'forward -t')
config.bind('TpH', 'config-cycle -p -t -u *://*.{url:host}/* content.plugins ;; reload')
config.bind('Tph', 'config-cycle -p -t -u *://{url:host}/* content.plugins ;; reload')
config.bind('Tpu', 'config-cycle -p -t -u {url} content.plugins ;; reload')
config.bind('TsH', 'config-cycle -p -t -u *://*.{url:host}/* content.javascript.enabled ;; reload')
config.bind('Tsh', 'config-cycle -p -t -u *://{url:host}/* content.javascript.enabled ;; reload')
config.bind('Tsu', 'config-cycle -p -t -u {url} content.javascript.enabled ;; reload')
# config.bind('<Ctrl-g>', 'enter-mode', mode='passthrough')
config.bind('<Shift-Esc>', 'enter-mode passthrough')
# config.bind('<Ctrl-Alt-v>', 'leave-mode', mode='passthrough')
# config.bind('<Ctrl-Alt-g>', 'enter-mode passthrough')
