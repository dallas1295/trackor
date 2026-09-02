package main

import "core:fmt"
import "core:os"
import i "issues"

main :: proc() {

	if len(os.args) <= 1 {
		fmt.println("trackor requires more than one argument")
		return
	}
	args := os.args[1:]

	switch args[0] {
	case "new":
		if len(args) < 4 {
			fmt.println("usage: trackor new DESC PRIORITY STATUS")
			return
		}
		p, pok := i.priority_from_string(args[2])
		if !pok {
			fmt.eprintfln("error: invalid priority: {}", args[2])
			return
		}
		s, sok := i.status_from_string(args[3])
		if !sok {
			fmt.eprintfln("error: invalid status: {}", args[3])
			return
		}
		i.new_issue(args[1], p, s)
	case "ls":
		i.show_issues()
	case:
		fmt.println("usage: tracker CMD ARGS...")
	}
}
