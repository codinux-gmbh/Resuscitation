import Foundation


extension StringProtocol {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var isBlank: Bool {
        return isEmpty || trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isNotBlank: Bool {
        return !isBlank
    }
    

    subscript(_ i: Int) -> String {
      let idx1 = index(startIndex, offsetBy: i)
      let idx2 = index(idx1, offsetBy: 1)
      return String(self[idx1..<idx2])
    }

    subscript (r: Range<Int>) -> String {
      let start = index(startIndex, offsetBy: r.lowerBound)
      let end = index(startIndex, offsetBy: r.upperBound)
      return String(self[start ..< end])
    }

    subscript (r: CountableClosedRange<Int>) -> String {
      let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
      let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
      return String(self[startIndex...endIndex])
    }
    
    
    var firstLetterUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
    
}

extension String {
        
        
        func localize() -> String {
            return NSLocalizedString(self, comment: "")
        }
        
        func localize(_ arguments: CVarArg) -> String {
            return String(format: NSLocalizedString(self, comment: ""), arguments)
        }

}



extension Optional where Wrapped == String {
    
    var isNullOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
    var isNullOrBlank: Bool {
        return self?.isBlank ?? true
    }
    
}


extension Array {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
}
