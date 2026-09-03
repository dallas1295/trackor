package issues

import "core:fmt"
import "core:os"
import "core:strings"

// persistant issue to a .md file in the .trackor directory, if there is an empty id it will generate a unique id
// if the id is provided it will overwrite the issues properties as defined in mutation.odin (update)
save_issue :: proc(description: string, priority: Priority, status: Status, id := "") -> bool {
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

	// if we provide it with an ID in say a situation where we are overwriting to mutate an issue we check and confirm everything is okay
	if len(id) != 0 && len(id) == 17 {
		// Name the file the ID
		fname := fmt.aprintf("{}.md", id)
		defer delete(fname)
		// join .trackor/fname
		fpath = fmt.aprintf("{}/{}", ppath, fname)

		data = fmt.aprintf(
			"---\nid: {}\npriority: {}\nstatus: {}\n---\n\n{}",
			id,
			priority,
			status,
			description,
		)
	} else {
		// the loop generates an id but ensures the id isn't already in the .trackor dir, it'll try 5 times before erroring out, at which point we got a problem...
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
			fmt.eprintf("cannot check {}: {}\n", fpath, err)
			// if the stat fails we error out delete the path and return false (something's wrong man...)
			delete(fpath)
			return false
		}

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
	if id == "" {
		fmt.printf("issue created\n")
	}
	return true
}
