import Foundation
import SwiftSoup

let text = """
<a href="/tags/organizations/sbu/" target="_blank">Служба безопасности Украины</a> (СБУ) подтвердила факт вывода на подконтрольную Киеву территорию Украины Светланы Дрюк (позывной Ветерок), ранее воевавшей на стороне самопровозглашенной Донецкой народной республики (ДНР). Сообщение об этом появилось на странице СБУ в <a href="https://www.facebook.com/SecurSerUkraine/photos/a.1539443172952349/2340002259563099/?type=3&theater" target="_blank">Facebook</a>.
"""

func parseContent(content: String) -> NSAttributedString {
    var attributedString = NSMutableAttributedString(string: content, attributes: nil)
    guard let els: Elements = try? SwiftSoup.parse(content).select("a") else { return attributedString }
    let linkAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.secondColor,
        NSAttributedString.Key.underlineColor: UIColor.secondColor,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    for element: Element in els.array() {
        //guard let hrefLink: String = try? element.attr("href") else { break }
        guard let textLink: String = try? element.text() else { break }
        guard let outerHtml: String = try? element.outerHtml() else { break }
        guard let foundRange: NSRange = (attributedString.string as NSString).range(of: outerHtml, options: .literal)  else { break }
        attributedString.setAttributes(linkAttributes, range: foundRange)
        attributedString.mutableString.replaceOccurrences(of: outerHtml, with: textLink, options: [], range: foundRange)
    }
    return attributedString
}

parseContent(content: text)
