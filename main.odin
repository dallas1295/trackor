package main

import "core:fmt"
import "core:os"
import i "issues"

main :: proc() {
	if len(os.args) == 1 {
		i.parse_data_from_issue()
		defer i.free_issues()
		i.sort_issues()
		i.show_issues()
	} else {

		args := os.args[1:]

		switch args[0] {
		// new creates a new issue with the provided arguments (DESC, PRIORTY, STATUS) it will error out if something goes wrong
		case "help":
			usage_new()
			usage_ls()
			usage_edit()
		case "new":
			if len(args) < 2 || len(args) > 5 {
				usage_new()
				return
			}

			status: string
			priority: string
			tag: string

			if len(args) == 2 {
				status = "open"
				tag = ""
				priority = ""
			}

			if len(args) == 4 {
				if _, arg3 := i.priority_from_string(args[3]); arg3 {
					priority = args[3]
				} else {
					priority = ""
				}
				if _, arg3 := i.tag_from_string(args[3]); arg3 {
					tag = args[3]
				} else {
					tag = ""
				}
			}
			if len(args) == 5 do tag = args[4]

			issue, ok := i.build_issue(args[1], status, priority, tag)
			if !ok {
				fmt.eprintfln("error: could not build issue data")
				return
			}

			defer delete(issue.id)
			defer delete(issue.desc)
			defer delete(issue.path)
			if saved := i.save_issue(issue); !saved do return
			fmt.println("new issue created")
		case "delete":
			i.parse_data_from_issue()
			defer i.free_issues()
			if len(args) == 2 {
				if ok := i.delete_issue(args[1]); ok {
					fmt.printfln("issue deleted")
				} else {
					fmt.eprintln("error: could not delete issue")
				}
			} else {
				usage_delete()
			}
		case "open":
			i.parse_data_from_issue()
			defer i.free_issues()

			if len(args) == 1 {
				i.sort_issues(i.sort_urgency)
				i.show_issues(status = .OPEN)
			} else {
				fmt.println("usage: trackor now [-t]")
			}

		case "grep":
			i.parse_data_from_issue()
			defer i.free_issues()
			i.sort_issues()

			if len(args) >= 2 {
				switch args[1] {
				case "-c":
					i.issues_grep(status = .CLOSED, hide_done = false)
				case "-p":
					p, ok := i.priority_from_string(args[2])
					if !ok {
						fmt.eprintfln("error: provided priority is not valid")
						return
					}
					i.issues_grep(priority = p)
				case "-t":
					t, ok := i.tag_from_string(args[2])
					if !ok {
						fmt.eprintfln("error: provided tag is not valid")
						return
					}
					i.issues_grep(tag = t)
				}
			} else {
				i.issues_grep()
			}


		/////////////////////
		/* EDIT COMMANDS */
		/////////////////////
		case "e":
			i.parse_data_from_issue()
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
			case "-c":
				if len(args) < 3 {
					usage_edit()
					return
				}
				if ok := i.set_closed(args[2]); !ok do return
			case:
				usage_edit()
				return

			}
		// running raw trackor ls will output the issues on a most recent date -> status -> priority matching
		case "ls":
			i.parse_data_from_issue()
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
					i.filter_status("CLOSED")
				case:
					usage_ls()
					return
				}
			}
		case "gen":
			gen_id := i.generate_id()
			ok := i.validate_id(gen_id)
			if ok {
				fmt.printfln("generated filename: {}", gen_id)
				fmt.println(
					"Use this as the name of your md file and match the frontmatter to create your own issues.",
				)
			} else {
				fmt.println("error: failed to generate a valid id and filename please try again")
			}
		case:
			usage_new()
			usage_delete()
			usage_edit()
			usage_ls()
			return
		}
	}

	usage_new :: proc() {
		fmt.println("usage: trackor new DESC [STATUS] [PRIORITY] TAG]")
	}

	usage_edit :: proc() {
		fmt.println("usage: trackor e -s ID STATUS")
		fmt.println("       trackor e -p ID PRIORITY")
		fmt.println("       trackor e -c ID")
	}
	usage_ls :: proc() {
		fmt.println("usage: trackor grep")
		fmt.println("")
		fmt.println("usage: trackor ls [-so | -su | -a | -fd]")
		fmt.println("       trackor ls -fs STATUS")
		fmt.println("       trackor ls -fp PRIORITY")
	}

	usage_delete :: proc() {
		fmt.println("usage: trackor delete ID")
		fmt.println("       delete will find it based on information provided")
	}
}
