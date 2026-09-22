package issues

import "core:fmt"
import "core:os"
import "core:os/file"
import "core:strings"

set_status :: proc(id, s: string) -> bool {
	new_status, sok := status_from_string(s)
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
				new_issue := Issue {
					issue.id,
					issue.desc,
					issue.priority,
					new_status,
					issue.tag,
					issue.path,
				}

				saved := save_issue(new_issue)
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
				new_issue := Issue {
					issue.id,
					issue.desc,
					new_priority,
					issue.status,
					issue.tag,
					issue.path,
				}

				saved := save_issue(new_issue)
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

set_closed :: proc(id: string) -> bool {
	return set_status(id, "CLOSED")
}

delete_issue :: proc(id: string) -> bool {
	if len(id) > 8 {
		fmt.eprintln("error: provided id is too long")
		return false
	}

	full, ok := get_id_from_prefix(id)
	if !ok {
		fmt.eprintfln("error: could not find valid id with prefix {}", id)
		return false
	}

	ppath := get_trackor_dir()
	if len(ppath) == 0 {
		fmt.eprintln("error: could not retreive trackor directory")
		return false
	}
	defer delete(ppath)
	fpath := fmt.aprintf("{}/{}.md", ppath, full)
	defer delete(fpath)
	if err := os.remove(fpath); err != nil {
		fmt.eprintln("error: could not delete issue")
		return false
	}

	fmt.printfln("issue: {} delete", full)
	return true

}
