import Foundation

public enum SwiftJSONFormatter {
    private static func format(_ value: String, indent: String, newLine: String, separator: String) -> String {
        var formatted = ""
        let chars = Array(value)
        var index = 0
        var indentLevel = 0

        while index < chars.count {
            let char = chars[index]

            switch char {
            case "{", "[":
                formatted.append(char)

                index = consumeWhitespaces(chars, from: index + 1)
                let next = index + 1
                if next < chars.count, chars[next] == "}" || chars[next] == "]" {
                    formatted.append(chars[next])
                    index = next
                } else {
                    indentLevel += 1
                    formatted.append(newLine)
                    formatted.append(String(repeating: indent, count: max(0, indentLevel)))
                }
            case "}", "]":
                indentLevel -= 1
                formatted.append(newLine)
                formatted.append(String(repeating: indent, count: max(0, indentLevel)))
                formatted.append(char)
            case "\"":
                let (string, newIndex) = consumeString(chars, from: index)
                formatted.append(string)
                index = newIndex
            case ",":
                index = consumeWhitespaces(chars, from: index + 1)
                formatted.append(",")
                let next = index + 1
                if next < chars.count, chars[next] != "}" && chars[next] != "]" {
                    formatted.append(newLine)
                    formatted.append(String(repeating: indent, count: max(0, indentLevel)))
                }
            case ":":
                formatted.append(":\(separator)")
            default:
                if !char.isWhitespace {
                    formatted.append(char)
                }
            }

            index += 1
        }

        return formatted
    }

    public static func beautify(_ value: String, indent: String = "    ") -> String {
        format(value, indent: indent, newLine: "\n", separator: " ")
    }

    public static func minify(_ value: String) -> String {
        format(value, indent: "", newLine: "", separator: "")
    }

    private static func consumeWhitespaces(_ chars: [Character], from index: Int) -> Int {
        var newIndex = index
        while newIndex < chars.count, chars[newIndex].isWhitespace {
            newIndex += 1
        }
        return newIndex - 1
    }

    private static func consumeString(_ chars: [Character], from index: Int) -> (String, Int) {
        var string = "\""
        var escaping = false
        var currentIndex = index + 1

        while currentIndex < chars.count {
            let char = chars[currentIndex]
            if char.isNewline {
                return (string, currentIndex)
            }
            string.append(char)

            if escaping {
                escaping = false
            } else {
                if char == "\\" {
                    escaping = true
                }
                if char == "\"" {
                    return (string, currentIndex)
                }
            }
            currentIndex += 1
        }

        return (string, currentIndex)
    }
}
