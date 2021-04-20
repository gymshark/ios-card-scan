extension Int {
    var isOdd: Bool {
        (self & 1) == 1
    }
}

struct CardCheck {
    private init () {}
    
    enum Logo: String {
        case amex
        case mastercard
        case visa
        
        var title: String {
            switch self {
            case .amex:
                return "American Express"
            case .mastercard:
                return "Mastercard"
            case .visa:
                return "Visa"
            }
        }
    }
    
    static func logo(fromTitle: String) -> Logo? {
        switch fromTitle.lowercased() {
        case Logo.amex.title.lowercased():
            return .amex
        case Logo.visa.title.lowercased():
            return . visa
        case Logo.mastercard.title.lowercased():
            return .mastercard
        default:
            return nil
        }
    }
    
    static func logo(for text: String) -> Logo? {
        let digits = text.compactMap { $0.wholeNumberValue }
        guard digits.count > 1 else {
            return nil
        }
        if digits[0] == 4 {
            return .visa
        }
        if digits[0] == 5 {
            return .mastercard
        }
        if digits[0] == 3 && [4, 7].contains(digits[1]) {
            return .amex
        }
        return nil
    }
    
    static func hasValidLuhnChecksum(_ text: String) -> Bool {
        var digits = text.compactMap { $0.wholeNumberValue }
        guard let checksum = digits.popLast(), digits.count > 8 else {
            return false
        }
        let sum = digits.reversed().enumerated().reduce(0) { (total, value) in
            let preCapValue = value.element * (value.offset.isOdd ? 1 : 2 )
            return total + (preCapValue > 9 ? preCapValue - 9 : preCapValue)
        }
        return (sum * 9) % 10 == checksum
    }
}
