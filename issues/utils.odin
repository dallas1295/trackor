package issues

import "core:fmt"
import "core:os"
import "core:strings"

// get trackor tries to get a .trackor directory from the working directory, if it's not present it makes it
// NOTE: not sure i want it to do that... if it err's maybe we create seperately but for now it's a 100% it'll get or make it
get_trackor_dir :: proc() -> string {
	p, err := os.get_working_directory(context.allocator)
	if err != nil {
		fmt.eprintf("failed to get working directory: {}", err)
		return ""
	}
	defer delete(p)

	issues_path := fmt.aprintf("{}/.trackor", p)

	f, ferr := os.stat(issues_path, context.allocator)
	defer delete(f.fullpath)
	if ferr != nil {
		mkdir_err := os.make_directory(issues_path)
		if mkdir_err != nil {
			fmt.eprintf("cannot create directory: {}", mkdir_err)
			delete(issues_path)
			return ""
		}
	} else if f.type != .Directory {
		fmt.eprintf("found file at path: {}\nCannot create directory.\n", issues_path)
		delete(issues_path)
		return ""
	}


	return issues_path
}

status_from_string :: proc(s: string) -> (Status, bool) {
	su, err := strings.to_upper(s)
	defer delete(su)
	if err != nil do return nil, false

	switch su {
	case "OPEN":
		return Status.OPEN, true
	case "CLOSED":
		return Status.CLOSED, true
	case:
		return nil, false
	}
}

priority_from_string :: proc(s: string) -> (Priority, bool) {
	su, err := strings.to_upper(s)
	defer delete(su)
	if err != nil do return nil, false

	switch su {
	case "LOW":
		return Priority.LOW, true
	case "MEDIUM":
		return Priority.MEDIUM, true
	case "HIGH":
		return Priority.HIGH, true
	case "URGENT":
		return Priority.URGENT, true
	case "":
		return Priority.NULL, true
	case:
		return nil, false
	}
}

tag_from_string :: proc(s: string) -> (Tag, bool) {
	su, err := strings.to_upper(s)
	defer delete(su)
	if err != nil do return nil, false

	switch su {
	case "BUG":
		return Tag.BUG, true
	case "REFAC":
		return Tag.REFAC, true
	case "FEAT":
		return Tag.FEAT, true
	case "DESIGN":
		return Tag.DESIGN, true
	case "IDEA":
		return Tag.IDEA, true
	case "":
		return Tag.NULL, true
	case:
		return nil, false
	}
}

property_to_string :: proc(v: $T) -> string {
	when T == Status {
		switch v {
		case .OPEN:
			return "open"
		case .CLOSED:
			return "closed"
		}
	} else when T == Priority {
		switch v {
		case .LOW:
			return "low"
		case .MEDIUM:
			return "medium"
		case .HIGH:
			return "high"
		case .URGENT:
			return "urgent"
		case .NULL:
			return ""
		case:
			return "" // .NULL
		}
	} else when T == Tag {
		switch v {
		case .BUG:
			return "bug"
		case .REFAC:
			return "refac"
		case .IDEA:
			return "idea"
		case .DESIGN:
			return "design"
		case .FEAT:
			return "feat"
		case .NULL:
			return ""
		case:
			return "" // .NULL
		}
	} else {
		compile_error("property_to_string expects Status, Priority, or Tag")
	}

	return ""
}

// Truncates the description to fit in the 50 character limit
truncate_desc :: proc(d: string, t: string) -> string {
	full: string
	if t == "" {
		full = fmt.aprintf("{}", d)
	} else {
		full = fmt.aprintf("[{}] {}", t, d)
	}

	length := len(full)

	if length <= 50 do return full
	t := fmt.aprintf("{}...", full[:50 - 3])

	delete(full)
	return t
}

get_date :: proc(i: Issue) -> string {
	return i.id[:min(len(i.id), 8)]
}

get_id_from_prefix :: proc(p: string) -> (matches: [dynamic]string, ok: bool) {
	found: [dynamic]string
	if len(p) > 8 {
		fmt.eprintfln("error: malformed id length cannot get id, must be at most 8 digits")
		return found, false
	}

	for issue in issues {
		if len(issue.id) != 17 {
			fmt.eprintfln("error: found issue with malformed id: {}", issue.id)
			continue
		}
		if strings.has_prefix(issue.id[9:], p) do append(&found, issue.id)
	}

	if len(found) >= 1 {
		return found, true
	}

	return found, false

}
