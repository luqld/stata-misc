* Same as -do- but with autocomplete

* Current limitations:
* - Do-files must be in the working directory

capture program drop doa
program define doa
	syntax [anything(name=pattern)], [Verbose] [noCopy]
	loc pattern `pattern' // remove quotes

	* Intersect empty case, and list files
	if ("`pattern'" == "") {
		ListDoFiles
		exit
	}

	* List all filenames with this pattern
	loc k = strlen(`"`pattern'"')
	loc pattern `"`pattern'*.do"'
	loc dofiles : dir "." files "`pattern'", respectcase
	loc numfiles : list sizeof dofiles
	
	_assert `numfiles' != 0, msg(`"No files match the pattern "`pattern'""') rc(601)
	*_assert `numfiles' == 1, msg(`"More than one file matches the pattern "`pattern'""')
	if (`numfiles' > 1) {
		di as error `"`numfiles' files match the pattern "`pattern'"; candidates:"'
		di as error "{hline 60}"
		loc i 0
		loc dofiles : list sort dofiles
		foreach dofile of local dofiles {
			if (`++i' > 5) exit 603
			FindShortestMatch, fn("`dofile'") k(`k')
			di as error `" - `dofile': {stata doa "`abbrev'":`abbrev'}"'
		}
		exit 603
	}
	loc dofile `dofiles'

	if ("`copy'" == "") {
		tempfile tempdo
		copy "`dofile'" "`tempdo'"
		loc copy_text " (copy)"
	}
	else {
		loc tempdo `dofile'
	}

	if ("`verbose'"!="") di as text `"Executing {stata doedit "`dofile'":`dofile'}`copy_text'"'
	di as text "{hline 60}"
	do "`tempdo'"
end


capture program drop FindShortestMatch
program define FindShortestMatch
	syntax, fn(string) k(integer)
	loc n = strlen("`fn'") - 3 // ".do"

	while (`k' < `n') {
		loc part = substr("`fn'", 1, `++k')
		loc pattern `"`part'*.do"'
		loc dofiles : dir "." files "`pattern'", respectcase
		loc numfiles : list sizeof dofiles

		if (`numfiles' == 1) {
			c_local abbrev "`part'"
			exit
		}
	}
	assert 0
end


capture program drop ListDoFiles
program define ListDoFiles

	loc k = strlen(`"`pattern'"')
	loc dofiles : dir "." files "*.do", respectcase
	loc numfiles : list sizeof dofiles

	if (`numfiles' == 0) {
		di as text `"No do-files in working directory ({res}`c(pwd)'{txt})"'
		exit
	}

	di as text `"`numfiles' do-files in the working directory:"'
	di as text "{hline 60}"
	loc i 0
	loc dofiles : list sort dofiles
	foreach dofile of local dofiles {
		if (`++i' > 10) exit
		FindShortestMatch, fn(`dofile') k(`k')
		loc preview_smcl `"{stata type "`dofile'", lines(5):type}"'
		loc edit_smcl `"{stata doedit "`dofile'":edit}"'
		loc abbrev_smcl `"{stata doa "`abbrev'":doa `abbrev'}"'
		di as text `"`abbrev_smcl'{col 14}`dofile'{col 49} `preview_smcl'{col 55}- `edit_smcl'"'
	}

end
