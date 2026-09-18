package issues

import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:strings"
import "core:time"

build_issue :: proc(description: string, status, priority, tag: string) -> (Issue, bool) {
	issue: Issue
	// trim description & ensure it's not len 0 cause it can't be empty
	d := strings.trim_space(description)
	if len(d) == 0 {
		fmt.eprintf("cannot have empty description field\n")
		return issue, false
	}

	// validate our parameters
	p, pok := priority_from_string(priority)
	if !pok {
		fmt.eprintfln("error: invalid priority: {}", priority)
		return issue, false
	}
	s, sok := status_from_string(status)
	if !sok {
		fmt.eprintfln("error: invalid status: {}", status)
		return issue, false
	}
	t, tok := tag_from_string(tag)
	if !tok {
		fmt.eprintfln("error: invalid tag: {}\n", tag)
		return issue, false
	}

	id := generate_id()

	return Issue{id, strings.clone(d), p, s, t}, true
}

save_issue :: proc(issue: Issue) -> bool {
	// get our trackor dir or create it if it doesn't exist
	ppath := get_trackor_dir()
	defer delete(ppath)
	if len(ppath) == 0 {
		fmt.eprintfln("failed to generate trackor issue directory.")
		return false
	}

	// get the id
	id := issue.id
	// 5 time loop to generate a valid id
	if !validate_id(id) {
		found: bool
		for i := 0; i < 5; i += 1 {
			gen_id := generate_id()
			if validate_id(gen_id) {
				id = gen_id
				found = true
				break
			}
			delete(gen_id)
		}
		// it failed to create an ID that's valid so we fail
		// NOTE:: this is definitely someehting really wrong if it happens so we need to check.
		if !found {
			fmt.eprintln(
				"error: could not create issue with valid ID after 5 tries, please try again.",
			)
			return false
		}
	}

	// generate the file name and it's path
	fname := fmt.aprintf("{}.md", id)
	defer delete(fname)
	// join .trackor/fname
	fpath := fmt.aprintf("{}/{}", ppath, fname)
	defer delete(fpath)

	// valid path so we can build and break
	priority := property_to_string(issue.priority)
	status := property_to_string(issue.status)
	tag := property_to_string(issue.tag)

	data := fmt.aprintf(
		"---\nid: {}\nstatus: {}\npriority: {}\ntag: {}\n---\n\n{}",
		id,
		status,
		priority,
		tag,
		issue.desc,
	)
	defer delete(data)

	// then when we break the loop we write the file with the generated data.
	err := os.write_entire_file(fpath, data)
	if err != nil {
		fmt.eprintf("error creating issue\n")
		return false
	}

	// lil' print for the homies to know it's done
	fmt.printf("issue created\n")
	return true
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

validate_id :: proc(id: string) -> bool {
	ppath := get_trackor_dir()
	if len(ppath) == 0 {
		return false
	}
	defer delete(ppath)
	// create the filename and path
	fname := fmt.aprintf("{}.md", id)
	defer delete(fname)
	// join .trackor/fname
	fpath := fmt.aprintf("{}/{}", ppath, fname)
	defer delete(fpath)

	// checks if it exists or not
	f, err := os.stat(fpath, context.allocator)
	defer delete(f.fullpath)
	if err == .Not_Exist {
		return true
	}

	return false
}
