program define rebuild_git
	args project
	assert_msg inlist("`project'", "quipu", "reghdfe"), msg("project does not exist: `project'")
	cap cls
	di as text "(note: rebuilding will silently fail if we cannot run .py files directly from the command line)"
	local gitpath "D:/Github"
	local projectpath "`gitpath'/`project'"
	local makefile "`projectpath'/build/build.py"
	
	di as text _n "{title:Running build.py}"
	di as text `"[cmd] shell `makefile"'
	shell "`makefile'"

	di as text _n "{title:Old version if already installed:}"
	cap noi which `project'

	di as text _n "{title:Uninstalling if already installed}"
	cap ado uninstall `project'
	if ("`project'"=="reghdfe") cap ado uninstall hdfe

	di as text _n "{title:Installing from local git repo}"
	qui net from "`projectpath'/package/"
	net install `project'
	if ("`project'"=="reghdfe") net install hdfe

	di as text _n "{title:New version:}"
	cap noi which `project'
end
