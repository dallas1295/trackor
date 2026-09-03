package main

import "core:fmt"
import "core:os"
import "core:strings"
import i "issues"

main :: proc() {
	if len(os.args) <= 1 {
		usage_new()
		usage_ls()
		usage_edit()
		return
	}
	args := os.args[1:]

	switch args[0] {
	// new creates a new issue with the provided arguments (DESC, PRIORTY, STATUS) it will error out if something goes wrong
	case "c":
		if len(args) < 4 {
			usage_new()
			return
		}
		up_p, perr := strings.to_upper(args[2])
		defer delete(up_p)
		if perr != nil {
			fmt.eprintfln("error parsing argument: {}: {}", args[2], perr)
			return
		}
		p, pok := i.priority_from_string(up_p)
		if !pok {
			fmt.eprintfln("error: invalid priority: {}", args[2])
			return
		}
		up_s, serr := strings.to_upper(args[3])
		defer delete(up_s)
		if serr != nil {
			fmt.eprintfln("error parsing argument: {}: {}", args[3], serr)
			return
		}
		s, sok := i.status_from_string(up_s)
		if !sok {
			fmt.eprintfln("error: invalid status: {}", args[3])
			return
		}
		if !i.save_issue(args[1], p, s) {
			return
		}
	case "now":
		i.parse_issues()
		defer i.free_issues()

		if len(args) >= 2 && args[1] == "-t" {
			i.sort_issues(i.sort_urgency)
			i.show_issues(status = .TODO)
		} else if len(args) == 1 {
			i.sort_issues(i.sort_urgency)
			i.show_issues(status = .ACTIVE)
		} else {
			fmt.println("usage: trackor now [-t]")
		}

	/////////////////////
	/* EDIT COMMANDS */
	/////////////////////
	case "e":
		i.parse_issues()
		defer i.free_issues()
		if len(args) < 2 {
			usage_edit()
			return
		}
		switch args[1] {
		case "-s":
			if len(args) < 4 {
				usage_edit()
				return
			}
			if ok := i.set_status(args[2], args[3]); !ok do return
		case "-p":
			if len(args) < 4 {
				usage_edit()
				return
			}
			if ok := i.set_priority(args[2], args[3]); !ok do return
		case "-d":
			if len(args) < 3 {
				usage_edit()
				return
			}
			if ok := i.set_done(args[2]); !ok do return
		case:
			usage_edit()
			return

		}
	// running raw trackor ls will output the issues on a most recent date -> status -> priority matching
	case "ls":
		i.parse_issues()
		defer i.free_issues()
		if len(args) == 1 {
			i.sort_issues()
			i.show_issues()
		} else if len(args) >= 2 {
			//////////////////////
			/* SORTING COMMANDS */
			//////////////////////
			switch args[1] {
			// -so flag will sort from oldest but in the same matching order as raw ls
			case "-so":
				i.sort_issues(i.sort_oldest)
				i.show_issues()
			case "-su":
				i.sort_issues(i.sort_urgency)
				i.show_issues()
			case "-sur":
				i.sort_issues(i.sort_rev_urgency)
				i.show_issues()
			case "-a":
				i.sort_issues()
				i.show_issues(hide_done = false)
			/////////////////////
			/* FILTER COMMANDS */
			/////////////////////
			// -fs will filter status based on the arg provided (argument can be lower or uppercase STATUS)
			case "-fs":
				if len(args) < 3 {
					usage_ls()
					return
				}
				i.filter_status(args[2])
			// -fp will filter status based on the arg provided (argument can be lower or uppercase PRIORITY)
			case "-fp":
				if len(args) < 3 {
					usage_ls()
					return
				}
				i.filter_priority(args[2])
			// in the case where nothign is in the switch it'll just reiterate how to use
			case "-fd":
				i.filter_status("DONE")
			case:
				usage_ls()
				return
			}
		}
	case:
		usage_new()
		usage_edit()
		usage_ls()
		return
	}
}

usage_new :: proc() {
	fmt.println("usage: trackor new DESC PRIORITY STATUS")
}

usage_edit :: proc() {
	fmt.println("usage: trackor e -s ID STATUS")
	fmt.println("       trackor e -p ID PRIORITY")
	fmt.println("       trackor e -d ID")
}
usage_ls :: proc() {
	fmt.println("usage: trackor ls [-so | -su | -sur | -a | -fd]")
	fmt.println("       trackor ls -fs STATUS")
	fmt.println("       trackor ls -fp PRIORITY")
}
