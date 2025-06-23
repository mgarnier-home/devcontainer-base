#!/usr/bin/env fish

if status is-interactive
    # execute the script ~/.container-config.fish if it exists
    if test -f ~/.container-config.fish
        source ~/.container-config.fish
    end

end
