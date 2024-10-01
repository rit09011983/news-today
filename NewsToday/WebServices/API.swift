//
//  API.swift
//  NewsToday
//
//  Created by iRitesh on 28/09/24.
//

import Foundation
import UIKit
import CoreData

class API {
    
    static let shared = API()
    
    private init() {}
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getDataFromApi(category: String, completion: @escaping (News?) -> Void){
        
        var result: News?
        let url = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=3a4a09c27c8946ebbdff9c55ea5be425"
        
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            
            print("\n\n\nURLSession.shared.dataTask Started\n\n\n")
            
            guard let data = data, error == nil else {
                print("Error: ", error!)
                return
            }
            print(data)
            do {
                let decoder = JSONDecoder()
                //decoder.dateDecodingStrategy = .iso8601
                result = try decoder.decode(News.self, from: data)
            }
            catch {
                print(error.localizedDescription)
                return
            }

            guard let json = result else {
                print("Error :(")
                return
            }
            completion(json)
            
        }
        task.resume()
    }
}
