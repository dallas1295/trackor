package issues

import "core:fmt"
import "core:os"
import "core:strings"

// Using inforation provided from user generates a new issue and places the file into an md in the current working directory
new_issue :: proc(description: string, priority: Priority, status: Status) -> bool {
	d := strings.trim_space(description)
	if len(d) == 0 {
		fmt.eprintf("cannot have empty description field\n")
		return false
	}

	ppath := get_trackor_dir()
	if len(ppath) == 0 {
		return false
	}
	defer delete(ppath)

	fname: string
	fpath: string
	data: string

	for i := 0; i < 5; i += 1 {
		gen_id := generate_id()
		defer delete(gen_id)

		fname = fmt.aprintf("{}.md", gen_id)
		fpath = fmt.aprintf("{}/{}", ppath, fname)

		f, err := os.stat(fpath, context.allocator)
		if err == .Not_Exist {
			// valid path so we can build and break
			data = fmt.aprintf(
				"---\nid: {}\npriority: {}\nstatus: {}\n---\n\n{}",
				gen_id,
				priority,
				status,
				description,
			)
			break
		}

		if err == nil {
			delete(f.fullpath)
			delete(fpath)
			continue
		}

		fmt.eprintf("cannot check {}: {}\n", fpath, err)
		delete(fpath)
		return false
	}


	err := os.write_entire_file(fpath, data)
	if err != nil {
		fmt.eprintf("error creating issue\n")
		return false
	}

	fmt.printf("issue created\n")
	return true
}
