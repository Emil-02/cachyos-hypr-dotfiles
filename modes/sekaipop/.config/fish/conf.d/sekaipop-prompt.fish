# sekaipop: managed file, removed by Settings -> Desktop -> App colours (revert)
if status is-interactive
    test -f '@HOME@/.local/state/sekaipop/terminal/prompt-sequences.txt'; and cat '@HOME@/.local/state/sekaipop/terminal/prompt-sequences.txt'
    function __sekaipop_define_prompt
        function fish_prompt
            set -l last $status
            if test -f '@HOME@/.local/state/sekaipop/terminal/prompt.sh'
                sh '@HOME@/.local/state/sekaipop/terminal/prompt.sh' $last "$CMD_DURATION" "$PWD" "$COLUMNS"
            else
                functions --erase fish_prompt
                fish_prompt
            end
        end
    end
    __sekaipop_define_prompt
    function __sekaipop_keep_prompt --on-event fish_prompt
        __sekaipop_define_prompt
        functions --erase __sekaipop_keep_prompt
    end
end
