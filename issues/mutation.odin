package issues

import "core:fmt"
import "core:strings"

set_status :: proc(id, s: string) -> bool {
	up, err := strings.to_upper(s)
	defer delete(up)
	if err != nil {
		fmt.eprintfln("error parsing argument: {}: {}", s, err)
		return false
	}

	new_status, sok := status_from_string(up)
	if !sok {
		fmt.eprintfln("error: invalid status: {}", s)
		return false
	}

	matches, ok := get_id_from_prefix(id)
	if !ok {
		fmt.eprintfln("failed to retrieve matches")
		return false
	}
	defer delete(matches)

	if len(matches) != 1 {
		fmt.eprintfln("FOUND MULTIPLE MATCHES:")
		for match in matches {
			fmt.eprintfln("{}", match)
		}
		return false
	} else {
		for issue in issues {
			if issue.id == matches[0] {
				if issue.status == new_status {
					fmt.eprintfln("issue #{}: status is current", issue.id)
					return false
				}
				saved := save_issue(issue.desc, issue.priority, new_status, issue.id)
				if !saved {
					fmt.eprintfln("error: failed to save issue")
					return false
				}
				fmt.printfln("issue #{}: status changed to {}", issue.id, new_status)
				return true
			}
		}

		fmt.eprintfln(
			"error: could not find matching issue id\nfile changed in system or is no longer present",
		)
		return false
	}
}

set_priority :: proc(id, p: string) -> bool {
	up, err := strings.to_upper(p)
	defer delete(up)
	if err != nil {
		fmt.eprintfln("error parsing argument: {}: {}", p, err)
		return false
	}

	new_priority, pok := priority_from_string(up)
	if !pok {
		fmt.eprintfln("error: invalid priority: {}", p)
		return false
	}

	matches, ok := get_id_from_prefix(id)
	if !ok {
		fmt.eprintfln("failed to retrieve matches")
		return false
	}
	defer delete(matches)

	if len(matches) != 1 {
		fmt.eprintfln("FOUND MULTIPLE MATCHES:")
		for match in matches {
			fmt.eprintfln("{}", match)
		}
		return false
	} else {
		for issue in issues {
			if issue.id == matches[0] {
				if issue.priority == new_priority {
					fmt.eprintfln("issue #{}: priority is current", issue.id)
					return false
				}
				saved := save_issue(issue.desc, new_priority, issue.status, issue.id)
				if !saved {
					fmt.eprintfln("error: failed to save issue")
					return false
				}
				fmt.printfln("issue #{}: priority changed to {}", issue.id, new_priority)
				return true
			}
		}

		fmt.eprintfln(
			"error: could not find matching issue id\nfile changed in system or is no longer present",
		)
		return false
	}
}

set_done :: proc(id: string) -> bool {
	return set_status(id, "DONE")
}
