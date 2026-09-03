package issues

import "core:fmt"
import "core:sort"
import "core:strings"

tiebreak :: proc(a, b: Issue) -> int {
	if r := int(a.status) - int(b.status); r != 0 {
		return r
	}

	if r := int(b.priority) - int(a.priority); r != 0 {
		return r
	}

	return strings.compare(a.id, b.id)
}

sort_oldest :: proc(a, b: Issue) -> int {
	if r := strings.compare(get_date(a), get_date(b)); r != 0 {
		return r
	}

	return tiebreak(a, b)
}

sort_newest :: proc(a, b: Issue) -> int {
	if r := strings.compare(get_date(b), get_date(a)); r != 0 {
		return r
	}

	return tiebreak(a, b)
}

sort_urgency :: proc(a, b: Issue) -> int {
	if r := int(b.priority) - int(a.priority); r != 0 {
		return r
	}

	if r := strings.compare(get_date(a), get_date(b)); r != 0 {
		return r
	}

	return tiebreak(a, b)
}

sort_rev_urgency :: proc(a, b: Issue) -> int {
	return -sort_urgency(a, b)
}


sort_issues :: proc(cmp := sort_newest) {
	sort.quick_sort_proc(issues[:], cmp)
}

filter_priority :: proc(priority: string) {
	up, err := strings.to_upper(priority)
	defer delete(up)
	if err != nil {
		fmt.eprintfln("error parsing argument: {}: {}", priority, err)
		return
	}

	p, ok := priority_from_string(up)
	if !ok {
		fmt.eprintfln("error: invalid priority: {}", priority)
		fmt.println("usage: trackor ls -fp PRIORITY")
		return
	}

	sort_issues()
	show_issues(priority = p)
}

filter_status :: proc(status: string) {
	up, err := strings.to_upper(status)
	defer delete(up)
	if err != nil {
		fmt.eprintfln("error parsing argument: {}: {}", status, err)
		return
	}

	s, ok := status_from_string(up)
	if !ok {
		fmt.eprintfln("error: invalid status: {}", status)
		fmt.println("usage: trackor ls -fs STATUS")
		return
	}

	if s == .DONE {
		sort_issues()
		show_issues(status = s, hide_done = false)
	} else {
		sort_issues()
		show_issues(status = s)
	}

}

// This function displays the issues into the terminal with formatting
show_issues :: proc(status := Status(0), priority := Priority(0), hide_done := true) {
	fmt.println(
		"---------------------------------------------------------------------------------------------",
	)
	for issue in issues {
		if int(status) != 0 && issue.status != status {
			continue
		}
		if int(priority) != 0 && issue.priority != priority {
			continue
		}

		if hide_done && issue.status == .DONE {
			continue
		}


		t := truncate_desc(issue.desc)
		fmt.printfln(
			"| {:8v} | {:-6v} | {:-7v} | {:-50v} |",
			issue.id,
			issue.priority,
			issue.status,
			t,
		)
		delete(t)
	}
	fmt.println(
		"---------------------------------------------------------------------------------------------",
	)
}
