package issues

import "core:strings"

import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:time"

// get tracker tries to get a .trackor directory from the working directory, if it's not present it makes it
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
	defer delete(f.fullpath)


	return issues_path
}

// generates an id for an issue
generate_id :: proc() -> string {
	// get the date from the current time
	y, m, d := time.date(time.now())
	// generates a random u32 integer from the range of 10,000,000 to 99,999,999 (8 digits for uniformity)
	gen := rand.uint32_range(10000000, 99999999)

	// id is formated to at leading zeros to single digit months and days, then appends the the generated number
	id := fmt.aprintf("{:04d}{:02d}{:02d}-{}", y, i32(m), d, gen)
	return id
}


// TODO: this line of thinking is correct but to make these 2 functions more reusable
// need to add guard for more writable strings as an arg input
status_from_string :: proc(s: string) -> (Status, bool) {
	switch s {
	case "ACTIVE":
		return Status.ACTIVE, true
	case "DONE":
		return Status.DONE, true
	case "TODO":
		return Status.TODO, true
	case "BLOCKED":
		return Status.BLOCKED, true
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
	case "URGENT":
		return Priority.HIGH, true
	case:
		return nil, false
	}
}

// Truncates the description to fit in the 50 character limit
truncate_desc :: proc(d: string) -> string {
	if len(d) <= 50 do return strings.clone(d)
	t := fmt.aprintf("{}...", d[:50 - 3])

	return t
}
