#import "Basic";
#import "String";
#load "Winput.jai";
#import "File";
#import "File_Utilities";

settings_file := "settings.txt";

parse_settings :: () -> string, [] string, [..] Spot{
	data, success := read_entire_file(settings_file);
	defer free(data);
	if(!success){
		print("Couldn't find %\n", settings_file);
		hang_before_exit();
	}
	line := split(data,"\n");
	
	parent_path := "";
	must_contain := "";
	spots: [..] Spot;
	even := true;
	empty_spot : Spot;
	for i: 0..line.count - 1{
		line[i]= trim(line[i], "\n\r\t");
		if (line[i] == "" || starts_with(line[i], "#") ){
			continue;
		}
		if !parent_path {
			parent_path = copy_string(line[i]);
			continue;
		}
		if  must_contain == "" {
			must_contain = copy_string(line[i]);
			continue;
		}
		if(even){
			array_add(*spots, empty_spot);
			spots[spots.count - 1].from = copy_string(hex_to_string(line[i]));
		}
		else{
			spots[spots.count - 1].to   = copy_string(hex_to_string(line[i]));
		}
		even = !even;
	}
	if(!even){
		print("Error parsing %: odd number of hex strings\n", settings_file);
		hang_before_exit();
	}
	must_contain_array : [] string = split(must_contain, " ");
	for i: 0.. must_contain_array.count -1{
		must_contain_array[i] = trim(must_contain_array[i]," \n\r\t");
	}
	return parent_path, must_contain_array, spots;
}


generate_backup_file_name :: (file: string) -> string{
	//build a string for the backup file;
	builder: String_Builder;
    init_string_builder(*builder);
    append(*builder, path_strip_extension(file));
    append(*builder, "_backup.");
    append(*builder, path_extension(file));
	return builder_to_string(*builder);
}

patch :: (file_name: string,  spots: [] Spot){
	defer print("\n");	
	print("Patching: %\n", file_name);
	data := read_entire_file(file_name);
	defer free(data);
	backup_name :string = generate_backup_file_name(file_name);

	//the below "if" is important so that we only back up one time,
	//otherwise we'll overwrite previous "pure" backups if we run the program twice!
	if !file_exists(backup_name){
		print("Backing up...\n");
		if !write_entire_file(backup_name, data){
			print("Error backing up file: #%. Are you running as Administrator?\n", GetLastError());
			hang_before_exit(-1);
		}
	}
	success : int = 0;
	data_old : string;
	for spots{
		data_old = data;
		data, success = replace(data, it.from ,it.to);
		free(data_old);//free .data instead?
		if(success == 1){
			print("Patched spot % (1 time)\n", it_index + 1);
		}
		else if(success){
			print("Patched spot % (% times)\n", it_index + 1, success);
		}
		else{
			print("Spot % not found\n",it_index + 1 );
		}
	}
	file_delete(file_name);
	print("Writing...\n");
	if !write_entire_file(file_name, data){
		print("Error writing file: #%. Are you running as Administrator?\n", GetLastError());
		hang_before_exit(-1);
	}
}


Spot :: struct {
	from : string;
	to : string;
}

Data :: struct {
	files : [..] string;
	must_contain : [] string;
}

main :: () {
	data : Data;
	parent_path, must_contain_, spots := parse_settings();
	data.must_contain = must_contain_;

	print("We'll search for files in: %\n", parent_path);
	print("File must include: %\n", data.must_contain);
	print("Number of spots: %\n\n", spots.count);
	print("Is this correct?\n");
	confirm_with_user();
	
	//path : Path = parse_path(parent_path);
	// fully_exists, how_much_exists := how_much_of_path_exists_on_the_local_filesystem(path);
	// if !fully_exists {  
	// 	partial := path;
	// 	partial.words.count = how_much_exists;
	// 	partial_string := path_to_string(partial);
	// 	print("Error: Only this much of the path exists: %\n", partial_string);
	// 	hang_before_exit();
	// }


	visit_files(parent_path, recursive=true, *data, my_visitor, follow_symlinks=true);
	if data.files.count == 0 {
		print("No files found\n");
		hang_before_exit(0);
	}
	print("Found the following files:\n");
	for data.files{
		print("%\n", it);
	}
	print("\nAre you sure you want to patch these files? They will all be backed up.\n");
	confirm_with_user();
	for data.files{
		patch(it,spots);
	}
	print("\n");
	print("Done!\n");
	hang_before_exit(0);
}

my_visitor :: (info: *File_Visit_Info, data: *Data) {
	name := path_filename(info.full_name);
	if contains(name ,"_backup.") return;
	for data.must_contain{
		if !contains(name, it){
			return;
		}
	}
	array_add(*data.files, copy_string(info.full_name));
}

is_hex_digit :: (c: u8) -> bool {
    a := c >= #char "0" && c <= #char "9";
	b := (c >= #char "a" && c <= #char "h") || (c >= #char "A" && c <= #char "H");
	return a || b;
}

hex_to_string :: (hex: string) -> string{
	//trimmed := trim(hex);
	bytes := split(hex, " ");
	builder : String_Builder;
    init_string_builder(*builder);

	for bytes{
		if(it.count != 2){
			print("Bad hex string given, make sure to use spaces: \n\"%\" is too long in line: %\n", it, hex);
			hang_before_exit();
		}
	
		if !is_hex_digit(it[0]) || !is_hex_digit(it[1]){
			print("Bad hex string given, invalid characters: \n\"%\" in line: %\n", it , hex);
			hang_before_exit();
		}
		num : int = string_to_int(it, 16);
		assert(num < 256);
		char : u8 = xx num; 
		append(*builder, char);

	}
	str := builder_to_string(*builder);
	return str;
}

hang_before_exit :: (ret : int = 0){
	print("Press Enter to exit the program\n");
	input();
	exit(xx ret);
}
confirm_with_user ::(){
	print("Press Enter to continue or type Ctrl+C to exit\n");
	input();
}

