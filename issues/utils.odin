package issues


import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:time"

get_trackor_dir :: proc() -> string {
	p, err := os.get_executable_directory(context.allocator)
	if err != nil {
		fmt.eprintf("failed to get working directory: {}", err)
		return ""
	}

	issues_path := fmt.aprintf("{}/.trackor", p)

	f, ferr := os.stat(issues_path, context.allocator)
	if ferr != nil {
		mkdir_err := os.make_directory(issues_path)
		if mkdir_err != nil {
			fmt.eprintf("cannot create directory: {}", mkdir_err)
			return ""
		}
	} else if f.type != .Directory {
		fmt.eprintf("found file at path: {}\nCannot create directory.\n", issues_path)
		return ""
	}


	return issues_path
}

generate_id :: proc() -> string {
	y, m, d := time.date(time.now())
	gen := rand.uint32()

	id := fmt.aprintf("{}{}{}-{}", y, i32(m), d, gen)
	return id
}

status_from_string :: proc(s: string) -> (Status, bool) {
	switch s {
	case "IN_PROGRESS":
		return Status.IN_PROGRESS, true
	case "WAITING":
		return Status.WAITING, true
	case "COMPLETE":
		return Status.COMPLETE, true
	case:
		return nil, false
	}
}

priority_from_string :: proc(s: string) -> (Priority, bool) {
	switch s {
	case "LOW":
		return Priority.LOW, true
	case "MEDIUM":
		return Priority.MEDIUM, true
	case "HIGH":
		return Priority.HIGH, true
	case:
		return nil, false
	}
}
