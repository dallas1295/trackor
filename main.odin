// OKAY the goal of this project is to create a simple CLI issue tracker that can be used to manage things via priority... LOW MED HIGH HIGH_PLUS...
// need to create a CLI to manage them and have a terminal output that will display a sorted list of issues to be tackled... this is a simple app just to get the juices flowing...
// FOR NOW it'll be in Odin, but rust is a consideration for rewrite


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
		if len(args) < 3 {
			fmt.println("usage: trackor new DESC STATUS PRIORITY")
			return
		}
		p, pok := i.priority_from_string(args[2])
		if !pok {
			fmt.eprintfln("error: invalid priority: {}", p)
		}
		s, sok := i.status_from_string(args[3])
		if !sok {
			fmt.eprintfln("error: invalid status: {}", s)
		}
		i.new_issue(args[1], p, s)
	case:
		fmt.println("usage: tracker CMD ARGS...")
	}
}
