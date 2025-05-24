

const std = @import("std");

// Declare external function from C
extern fn hello_from_c() void;

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
    hello_from_c();

    const Z = std.meta.Int(.unsigned, 1024); // theoritically 65535 is max
    var e: Z = 0xffff_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_ffff_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_ffff_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_ffff_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

    //
    // std.debug.print("Original:\n", .{});
    // printBits(e);

    e = setBit(e, 4);
    std.debug.print("\nAfter setting bit index 4:\n", .{});
    printBits(e);

    e = setBit(e, 6);
    std.debug.print("\nAfter set bit index 6:\n", .{});
    printBits(e);

    e = toggleBit(e, 4);
    std.debug.print("\nAfter toggle:\n", .{});
    printBits(e);

    e = clearBit(e, 1023); // Clear bit 511
    std.debug.print("\nAfter clearing bit 1023:\n", .{});
    printBits(e);

}

fn u3_print() void {
    const bit_len = 3;
    var foo_buf: [bit_len]u8 = undefined;
    const foo_str = std.fmt.bufPrint(&foo_buf, "{b}", .{foo.c}) catch unreachable;
    var padded_foo_buf: [bit_len]u8 = undefined;
    _ = std.fmt.bufPrint(&padded_foo_buf, "{s:0>3}", .{foo_str}) catch unreachable;
    _ = std.debug.print("Padded to 3 bits: {s}\n", .{&padded_foo_buf});

}

fn u11_print() void {
    var bin_buf: [11]u8 = undefined;
    const bin_str = std.fmt.bufPrint(&bin_buf, "{b}", .{foo.b}) catch unreachable;
    var padded_buf: [11]u8 = undefined;
    _ = std.fmt.bufPrint(&padded_buf, "{s:0>11}", .{bin_str}) catch unreachable;
    _ = std.debug.print("Padded to 11 bits: {s}\n", .{&padded_buf});

}



fn u19_print() void {
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
    const padded_str = std.fmt.bufPrint(&padded_buf, "{s:0>1024}", .{bin_str}) catch unreachable;

    var spaced_buf: [bits*2]u8 = undefined;
    const spaced_str = insertBitSpacing(padded_str, &spaced_buf) catch unreachable;

    std.debug.print("{s}\n", .{spaced_str});
}

fn insertBitSpacing(input: []const u8, buffer: []u8) ![]const u8 {
    var fbs = std.io.fixedBufferStream(buffer);
    const writer = fbs.writer();
    const group_size = 4;
    const line_size = 32;

    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        if (i > 0 and (i % group_size == 0)) {
            try writer.writeByte(' ');
        }

        if (i > 0 and (i % line_size == 0)) {
            try writer.writeByte('\n');
        }

        try writer.writeByte(input[i]);
    }
    try writer.writeByte('\n');

    return fbs.getWritten();
}

fn setBit(e: anytype, comptime bit_index: usize) @TypeOf(e) {
    return e | (@as(@TypeOf(e), 1) << bit_index);
}

fn clearBit(e: anytype, comptime bit_index: usize) @TypeOf(e) {
    return e & ~(@as(@TypeOf(e), 1) << bit_index);
}

fn toggleBit(e: anytype, comptime bit_index: usize) @TypeOf(e) {
    return e ^ (@as(@TypeOf(e), 1) << bit_index);
}