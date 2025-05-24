const std = @import("std");

const Foo = packed struct {
    a: u3,
    b: u11,
    c: u3,
};

var foo = Foo {
    .a = 1,
    .b = 63,
    .c = 3,
};


pub fn main() void {
    const bit_len = 3;
    var foo_buf: [bit_len]u8 = undefined;
    const foo_str = std.fmt.bufPrint(&foo_buf, "{b}", .{foo.c}) catch unreachable;
    var padded_foo_buf: [bit_len]u8 = undefined;
    _ = std.fmt.bufPrint(&padded_foo_buf, "{s:0>3}", .{foo_str}) catch unreachable;
    _ = std.debug.print("Padded to 3 bits: {s}\n", .{&padded_foo_buf});

    var bin_buf: [11]u8 = undefined;
    const bin_str = std.fmt.bufPrint(&bin_buf, "{b}", .{foo.b}) catch unreachable;
    var padded_buf: [11]u8 = undefined;
    _ = std.fmt.bufPrint(&padded_buf, "{s:0>11}", .{bin_str}) catch unreachable;
    _ = std.debug.print("Padded to 11 bits: {s}\n", .{&padded_buf});

    const U = std.meta.Int(.unsigned, 19);
    const d: U = 4095;
    //const d: u19 = 4095;

    printBits(d);
}


fn printBits(x: anytype) void {
    const T = @TypeOf(x);
    const bits = @bitSizeOf(T);

    var bin_buf: [bits]u8 = undefined;
    const bin_str = std.fmt.bufPrint(&bin_buf, "{b}", .{x}) catch unreachable;

    var padded_buf: [bits]u8 = undefined;
    const padded_str = std.fmt.bufPrint(&padded_buf, "{s:0>19}", .{bin_str}) catch unreachable;

    var spaced_buf: [bits*2]u8 = undefined;
    const spaced_str = insertBitSpacing(padded_str, &spaced_buf) catch unreachable;

    std.debug.print("Formatted bits: {s}\n", .{spaced_str});
}
//

fn insertBitSpacing(input: []const u8, buffer: []u8) ![]const u8 {
    var fbs = std.io.fixedBufferStream(buffer);
    const writer = fbs.writer();
    const len = input.len;

    var i: usize = 0;
    while (i < len) : (i += 1) {
        if (i > 0 and (len - i) % 4 == 0) {
            try writer.writeByte(' ');
        }
        try writer.writeByte(input[i]);
    }

    return fbs.getWritten();
}