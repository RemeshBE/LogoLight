import AppKit

let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
            bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let context = NSGraphicsContext.current!.cgContext
        context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)

        let tile = NSBezierPath(roundedRect: NSRect(x: 72, y: 72, width: 880, height: 880),
                                xRadius: 196, yRadius: 196)
        NSGradient(starting: NSColor(srgbRed: 0.08, green: 0.12, blue: 0.25, alpha: 1),
                   ending: NSColor(srgbRed: 0.31, green: 0.17, blue: 0.54, alpha: 1))!
            .draw(in: tile, angle: 55)
        let lid = NSBezierPath(roundedRect: NSRect(x: 236, y: 330, width: 552, height: 360),
                               xRadius: 53, yRadius: 53)
        NSColor(srgbRed: 0.15, green: 0.17, blue: 0.31, alpha: 1).setFill()
        lid.fill()
        NSColor(srgbRed: 0.64, green: 0.67, blue: 0.89, alpha: 1).setStroke()
        lid.lineWidth = 15
        lid.stroke()
        let base = NSBezierPath(roundedRect: NSRect(x: 180, y: 295, width: 664, height: 34),
                                xRadius: 17, yRadius: 17)
        NSColor(srgbRed: 0.70, green: 0.73, blue: 0.93, alpha: 1).setFill()
        base.fill()
        let star = NSBezierPath()
        let points: [NSPoint] = [
            .init(x: 512, y: 626), .init(x: 542, y: 540), .init(x: 628, y: 510),
            .init(x: 542, y: 480), .init(x: 512, y: 394), .init(x: 482, y: 480),
            .init(x: 396, y: 510), .init(x: 482, y: 540)
        ]
        star.move(to: points[0])
        for point in points.dropFirst() { star.line(to: point) }
        star.close()
        context.setShadow(offset: .zero, blur: 58, color: NSColor.cyan.cgColor)
        NSColor(srgbRed: 0.68, green: 1, blue: 0.97, alpha: 1).setFill()
        star.fill()
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        try bitmap.representation(using: .png, properties: [:])!
            .write(to: folder.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}

let entries = [
    ("icp4", "icon_16x16.png"), ("icp5", "icon_32x32.png"),
    ("ic07", "icon_128x128.png"), ("ic08", "icon_256x256.png"),
    ("ic09", "icon_512x512.png"), ("ic10", "icon_512x512@2x.png"),
    ("ic11", "icon_16x16@2x.png"), ("ic12", "icon_32x32@2x.png"),
    ("ic13", "icon_128x128@2x.png"), ("ic14", "icon_256x256@2x.png")
]
func lengthBytes(_ count: Int) -> Data {
    var value = UInt32(count).bigEndian
    return withUnsafeBytes(of: &value) { Data($0) }
}
var chunks = Data()
for (type, file) in entries {
    let png = try Data(contentsOf: folder.appendingPathComponent(file))
    chunks.append(contentsOf: type.utf8)
    chunks.append(lengthBytes(png.count + 8))
    chunks.append(png)
}
var icon = Data("icns".utf8)
icon.append(lengthBytes(chunks.count + 8))
icon.append(chunks)
try icon.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
