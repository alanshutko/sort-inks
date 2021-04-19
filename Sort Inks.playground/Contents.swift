import Cocoa

import CSV

extension NSColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

var colors : Set<NSColor> = Set.init()

let path = Bundle.main.path(forResource: "josh_collected_inks", ofType: "csv")!
let stream = InputStream(fileAtPath: path)!
let csv = try! CSVReader(stream: stream, hasHeaderRow: true, delimiter: ";")
while csv.next() != nil {
    let color = NSColor.init(hexString: csv["Color"]!)
    if csv["Type"] == "bottle" {
        colors.insert(color)
    }
}

let sorted_colors = colors.sorted { (a, b) -> Bool in
    if a.hueComponent < b.hueComponent {
        return true
    }
    if a.hueComponent > b.hueComponent {
        return false
    }

    if a.saturationComponent < b.saturationComponent {
        return true
    }
    if a.saturationComponent > b.saturationComponent {
        return false
    }

    if a.brightnessComponent < b.brightnessComponent {
        return true
    }
    if a.brightnessComponent > b.brightnessComponent {
        return false
    }

    return true
}

let row_height = 1
let height = row_height*sorted_colors.count
let width = height

let size = CGSize.init(width: width, height: height)

let renderer = GraphicsImageRenderer.init(size: size)

let pngData = renderer.pngData { (ctx) in
    for i in 0 ..< sorted_colors.count {
        let color = sorted_colors[i]
        color.setFill()
        ctx.fill(CGRect.init(x: 0, y: row_height*i, width: width, height: row_height))
    }
}

let filename = "/Users/ats/inks.png"
try? pngData.write(to: URL(fileURLWithPath: filename))

