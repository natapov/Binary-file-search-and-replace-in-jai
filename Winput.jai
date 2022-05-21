#import "Windows";
kernel32 :: #foreign_system_library "kernel32";
stdin  : HANDLE;
stdin_set := false;
stdout : HANDLE;
ReadConsoleA  :: (
    hConsoleHandle: HANDLE, 
    buff : *u8, 
    chars_to_read : s32,  
    chars_read : *s32, 
    lpInputControl := *void 
) -> BOOL #foreign kernel32;
input :: () -> string {
    MAX_BYTES_TO_READ :: 1024;
    temp : [MAX_BYTES_TO_READ] u8;
    result: string = ---;
    bytes_read : s32;
    if !stdin_set{
		stdin = GetStdHandle( STD_INPUT_HANDLE );
		stdin_set = true;
	}
    if !ReadConsoleA(stdin , temp.data, xx temp.count, *bytes_read )
        return "";
    result.data  = alloc(bytes_read);
    result.count = bytes_read;
    memcpy(result.data, temp.data, bytes_read);
    return result;
}
