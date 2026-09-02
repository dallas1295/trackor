package issues

import "core:fmt"
import "core:os"
import "core:strings"

// Using inforation provided from user generates a new issue and places the file into an md in the current working directory
new_issue :: proc(description: string, priority: Priority, status: Status) -> bool {
	// trim description & ensure it's not len 0 cause it can't be empty
	d := strings.trim_space(description)
	if len(d) == 0 {
		fmt.eprintf("cannot have empty description field\n")
		return false
	}

	// we get the trackor directory (or create it)
	ppath := get_trackor_dir()
	if len(ppath) == 0 {
		return false
	}
	defer delete(ppath)

	// define our file information
	fpath: string
	data: string

	// the loop generates an id but ensures the id hasn't already be created, it'll try 5 times before erroring out, at which point we got a problem...
	// NOTE: It's an incredible small change in a u32 to get a duplicate but just in case
	for i := 0; i < 5; i += 1 {
		gen_id := generate_id()
		defer delete(gen_id)

		// Name the file the ID
		fname := fmt.aprintf("{}.md", gen_id)
		defer delete(fname)
		// join .trackor/fname
		fpath = fmt.aprintf("{}/{}", ppath, fname)

		// checks if it exists or not
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

		// if it fails we delete our string allocations and try again
		if err == nil {
			delete(f.fullpath)
			delete(fpath)
			continue
		}

		// if the stat fails we error out delete the path and return false (something's wrong man...)
		fmt.eprintf("cannot check {}: {}\n", fpath, err)
		delete(fpath)
		return false
	}

	// make sure the data is actually populated as descriptions aren't allowed to be empty
	if len(data) == 0 {
		fmt.eprintf("could not generate a unique id after 5 tries\n")
		return false
	}

	// then when we break the loop we write the file with the generated data.
	err := os.write_entire_file(fpath, data)
	delete(data)
	delete(fpath)
	if err != nil {
		fmt.eprintf("error creating issue\n")
		return false
	}

	// lil' print for the homies to know it's done
	fmt.printf("issue created\n")
	return true
}
