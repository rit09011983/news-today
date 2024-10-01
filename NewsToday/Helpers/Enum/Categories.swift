//
//  Categories.swift
//  NewsToday
//
//  Created by iRitesh on 28/09/24.
//

import Foundation
public enum Categories : Int,CaseIterable {
    case business = 0
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
    
    func getCategotyName()->String {
            switch self {
            case .business:
                return "Business"
            case .entertainment:
                return "Entertainment"
            case .general:
                return "General"
            case .health:
                return "Health"
            case .science:
                return "Science"
            case .sports:
                return "Sports"
            case .technology:
                return "Technology"
            }
        }
}
