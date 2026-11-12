source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Fastfetch: tampil sekali per sesi terminal
#if status is-interactive; and type -q fastfetch; and not set -q FASTFETCH_SHOWN
 #   set -gx FASTFETCH_SHOWN 1
  #  fastfetch --config ~/.config/fastfetch/config.jsonc
#end
# SekaiPop: sapaan terminal = fastfetch dengan logo dari wallpaper
if status is-interactive; and command -q sekai-fetch
    function fish_greeting
        sekai-fetch
    end
end

# sekaipop: managed block, removed by Settings -> Desktop -> App colours (revert)
status is-interactive; and test -f '@HOME@/.local/state/sekaipop/terminal/sequences.txt'; and cat '@HOME@/.local/state/sekaipop/terminal/sequences.txt'
