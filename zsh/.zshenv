# Home Manager does not manage zsh, so nothing else loads its session variables.
hm_session_vars="/etc/profiles/per-user/$USERNAME/etc/profile.d/hm-session-vars.sh"
[[ -r "$hm_session_vars" ]] && source "$hm_session_vars"
unset hm_session_vars
