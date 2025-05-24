zig translate-c -Isrc/jabcode/include src/jabcodeReader/jabreader.c > src/jabcodeReader/jabreader.zig
zig translate-c -Isrc/jabcode/include -Isrc/jabcodeWriter/jabwriter.h src/jabcodeWriter/jabwriter.c > src/jabcodeWriter/jabreader.zig
zig build