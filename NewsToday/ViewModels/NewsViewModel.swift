//
//  NewsViewModel.swift
//  NewsToday
//
//  Created by iRitesh on 29/09/24.
//

import Foundation
import UIKit


class NewsViewModel: NSObject {
    
    var success: Observable<News?> = Observable(nil)
    var errorMessage: Observable<NSDictionary?> = Observable(nil)
    
    var isFreash:Bool = false
    
    override init() {
        super.init()
    }
    
    func getNewsFromCateory(category: String) {
        
        NetworkRequester.makeNetworkRequest(category: category, onCompletion: { (News,errorDic) in
            
            if let _errorDic = errorDic, _errorDic.count > 0 {
                self.errorMessage.value = _errorDic
                
            } else {
                self.success.value = News
            }
        })
    }
}

