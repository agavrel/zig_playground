const std = @import("std");
const zpng = @import("zpng");

const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

// Compile-time palette
const jabcode_palette = comptime generateJABCodePalette();

pub fn main() !void {
    const width = 16;
    const height = 16;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var image = try zpng.Image.createRGB8(allocator, width, height);

    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.timestamp()));
    const random = prng.random();

    for (image.pixels.items) |*pixel| {
        const index = random.uintLessThan(u8, 256);
        const color = jabcode_palette[index];
        pixel.* = .{ .r = color.r, .g = color.g, .b = color.b };
    }

    var file = try std.fs.cwd().createFile("jabcode_random.png", .{ .truncate = true });
    defer file.close();

    try image.writeToFile(file.writer());
    std.debug.print("Saved 16x16 PNG with random JABCode colors as 'jabcode_random.png'\n", .{});
}

fn generateJABCodePalette() [256]RGB {
    var palette: [256]RGB = undefined;

    // Grayscale ramp: 16 shades from black to white
    for (0..16) |i| {
        const v: u8 = @intCast(u8, i * 17);
        palette[i] = .{ .r = v, .g = v, .b = v };
    }

    // 6×6×6 RGB cube: combinations of {0, 51, 102, 153, 204, 255}
    const steps = [_]u8{0, 51, 102, 153, 204, 255};
    var i: usize = 16;
    for (steps) |r| {
        for (steps) |g| {
            for (steps) |b| {
                if (i < 256) {
                    palette[i] = .{ .r = r, .g = g, .b = b };
                    i += 1;
                }
            }
        }
    }

    return palette;
}