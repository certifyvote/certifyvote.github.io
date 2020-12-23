import UIKit

struct X {
    let a: NSNull = NSNull()
}

let x = X()
print(x)
var str = "{\"document_number\":{\"essential\":true},\"portrait_hash\":{\"essential\":true}}"

print(str)
let json = JSONSerialization.isValidJSONObject(str)
//print(json)



