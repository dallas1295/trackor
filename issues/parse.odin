package issues
import "core:fmt"
import "core:os"
import "core:strings"

Priority :: enum {
	LOW,
	MEDIUM,
	HIGH,
}

Status :: enum {
	IN_PROGRESS,
	COMPLETE,
	WAITING,
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
	path := get_trackor_dir()
	if len(path) == 0 {
		return
	}

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

		if os.ext(file.name) != ".md" {
			continue
		}

		clone_path := strings.clone(file.fullpath)
		append(&ipaths, clone_path)
	}

	return
}

free_paths :: proc() {for path in ipaths {delete(path)
	}
	delete(ipaths)
}

parse_issues :: proc() {
	Parts :: enum {
		TOP,
		METADATA,
		DESCRIPTION,
	}

	walk_issues()
	defer free_paths()

	if len(ipaths) == 0 {
		return
	}

	file_loop: for path in ipaths {
		data, err := os.read_entire_file_from_path(path, context.allocator)
		if err != nil {
			fmt.eprintf("error reading path: {}\n", path)
			continue
		}
		defer delete(data)

		content := string(data)

		id: string
		desc: string
		priority: Priority
		status: Status

		state := Parts.TOP
		remaining := content
		consumed: int
		line_loop: for {
			line, found := strings.split_iterator(&remaining, "\n")
			if !found do break
			consumed += len(line) + 1

			trimmed := strings.trim_space(line)
			switch state {
			case .TOP:
				if trimmed != "---" do continue file_loop
				state = .METADATA
			case .METADATA:
				if trimmed == "---" {
					state = .DESCRIPTION
				} else if trimmed != "" {
					key, match, val := strings.partition(trimmed, ":")
					if match == "" do continue
					key = strings.trim_space(key)
					val = strings.trim_space(val)
					switch key {
					case "id":
						id = strings.clone(val)
					case "priority":
						if p, ok := priority_from_string(val); ok {
							priority = p
						}
					case "status":
						if s, ok := status_from_string(val); ok {
							status = s
						}
					}
				}
			case .DESCRIPTION:
				desc = strings.clone(strings.trim_space(content[consumed - (len(line) + 1):]))
				new := Issue {
					id       = id,
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
