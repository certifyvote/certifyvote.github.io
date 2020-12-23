import UIKit

var str = "Hello, playground"
var dateFormatter = DateFormatter()
var isoFormatter = ISO8601DateFormatter()
let createdStr = "2020-12-19 14:20:14 +0000"
let now = Date()
print(now.timeIntervalSince1970)
print(createdStr)
let isoStr = "2020-12-19T14:12:08.000000Z"
let isodDate = isoFormatter.date(from: isoStr)
print(isodDate)
