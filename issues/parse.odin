package issues
import "core:fmt"
import "core:os"
import "core:strings"

Priority :: enum {
	LOW = 1,
	MEDIUM,
	HIGH,
	URGENT,
}

Status :: enum {
	TODO = 1,
	ACTIVE,
	DONE,
	BLOCKED,
}

Issue :: struct {
	id:       string,
	desc:     string,
	priority: Priority,
	status:   Status,
}

issues: [dynamic]Issue
ipaths: [dynamic]string

walk_issues :: proc() {
	// get the root of the project and find the .trackor dir
	path := get_trackor_dir()
	defer delete(path)

	// if for some reason it fails we bail
	if len(path) == 0 {
		return
	}

	// initialize walker on the path and defer it's destruction
	w := os.walker_create(path)
	defer os.walker_destroy(&w)

	for {
		file, ok := os.walker_walk(&w)
		if !ok {
			break
		}

		// this get's any errs from our walk prints them out and continues
		if _, walk_err := os.walker_error(&w); walk_err != nil {
			continue
		}

		// so we want to ensure we just skip over any non .md's in the folder for now
		// NOTE: this may change but for now it's okay.
		if os.ext(file.name) != ".md" {
			continue
		}

		// clone the paths into our global ipaths array
		clone_path := strings.clone(file.fullpath)
		append(&ipaths, clone_path)
	}

	// now that the array is populated we can return
	return
}

// Simple destructor for all the path allocations
free_paths :: proc() {
	for path in ipaths {
		delete(path)
	}
	delete(ipaths)
}

// Simple destructor for all of our allocated strings in issues array
free_issues :: proc() {
	for issue in issues {
		delete(issue.id)
		delete(issue.desc)
	}
	delete(issues)
}

parse_issues :: proc() {
	// This enum gives us easier stepping through the data in our .md
	Parts :: enum {
		TOP,
		METADATA,
		DESCRIPTION,
	}

	// start walking through tracor
	walk_issues()
	defer free_paths()

	// if we don't get an paths after walking we return
	if len(ipaths) == 0 {
		return
	}

	// file loop will iterate per path in the ipaths array
	file_loop: for path in ipaths {
		// get our data in the path and read the file, this allocates so it needs to be freed
		data, err := os.read_entire_file_from_path(path, context.allocator)
		if err != nil {
			fmt.eprintf("error reading path: {}\n", path)
			continue
		}
		defer delete(data)

		content := string(data)

		// define the allocations for our second loop to create our Issue struct per file
		id: string
		desc: string
		priority: Priority
		status: Status

		state := Parts.TOP
		remaining := content
		consumed: int


		// line loop goes line to line matching the iteration's information with the relevant portion of the text via our Parts enum
		line_loop: for {
			// ensure there's a line if not we break
			line, found := strings.split_iterator(&remaining, "\n")
			if !found do break

			// we've used up a line so we add to consumed
			consumed += len(line) + 1

			// just to ensure the output is sanitized
			trimmed := strings.trim_space(line)

			switch state {
			case .TOP:
				// if there is no --- at the top of the file we need to go to the next file because it isn't a trackor issue
				if trimmed != "---" do continue file_loop
				// it is there we go to the next part of the file
				state = .METADATA
			case .METADATA:
				// NOTE: it's worth noting this is a safe parser so it will sill try to parse things out.
				// BUT if it's not write the helper util functions error out and print out
				// if for some change it's close immediately we just fill in the description
				if trimmed == "---" {
					state = .DESCRIPTION
				} else if trimmed != "" {
					// we conver the line into a key value pairs based on the ':' char.
					key, match, val := strings.partition(trimmed, ":")
					// if it can't find it we continue
					if match == "" do continue

					// we match the key and val into the switch to parse out which key value it will be
					key = strings.trim_space(key)
					val = strings.trim_space(val)
					switch key {
					case "id":
						// NOTE: if there is an id here from the previous iteration we delete it than repopulate it with a cloned string from val
						id = val
					case "priority":
						// here we parse out the priority from the metadata from the string into the enum
						if p, ok := priority_from_string(val); ok {
							priority = p
						}
					case "status":
						// here we parse out the status from the metadata from the string into the enum
						if s, ok := status_from_string(val); ok {
							status = s
						}
					}
				}
			case .DESCRIPTION:
				// again because strings in Odin are allocated we must clone the value before we go to the next iteration
				desc = strings.clone(strings.trim_space(content[consumed - (len(line) + 1):]))
				// then we create our issue using the data we have then append it and break the line loop
				new := Issue {
					id       = strings.clone(id),
					priority = priority,
					status   = status,
					desc     = desc,
				}

				append(&issues, new)
				break line_loop
			}
		}
	}
}
