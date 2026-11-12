# Tool hacking di ~/Proyek/hacking/tools (didahulukan agar httpx = ProjectDiscovery)
fish_add_path --path --move --prepend $HOME/Proyek/hacking/tools/bin
fish_add_path --path --append $HOME/.local/bin
set -gx PIPX_HOME $HOME/Proyek/hacking/tools/pipx
set -gx PIPX_BIN_DIR $HOME/Proyek/hacking/tools/bin
set -gx GEM_PATH $HOME/Proyek/hacking/tools/gems
