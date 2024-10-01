//
//  NetworkRequester.swift
//  NewsToday
//
//  Created by iRitesh on 29/09/24.
//

//  kCFURLErrorUnknown   = -998,
//  kCFURLErrorCancelled = -999,
//  kCFURLErrorBadURL    = -1000,
//  kCFURLErrorTimedOut  = -1001,
//  kCFURLErrorUnsupportedURL = -1002,
//  kCFURLErrorCannotFindHost = -1003,
//  kCFURLErrorCannotConnectToHost    = -1004,
//  kCFURLErrorNetworkConnectionLost  = -1005,
//  kCFURLErrorDNSLookupFailed        = -1006,
//  kCFURLErrorHTTPTooManyRedirects   = -1007,
//  kCFURLErrorResourceUnavailable    = -1008,
//  kCFURLErrorNotConnectedToInternet = -1009,
//  kCFURLErrorRedirectToNonExistentLocation = -1010,
//  kCFURLErrorBadServerResponse             = -1011,
//  kCFURLErrorUserCancelledAuthentication   = -1012,
//  kCFURLErrorUserAuthenticationRequired    = -1013,
//  kCFURLErrorZeroByteResource        = -1014,
//  kCFURLErrorCannotDecodeRawData     = -1015,
//  kCFURLErrorCannotDecodeContentData = -1016,
//  kCFURLErrorCannotParseResponse     = -1017,
//  kCFURLErrorInternationalRoamingOff = -1018,
//  kCFURLErrorCallIsActive               = -1019,
//  kCFURLErrorDataNotAllowed             = -1020,
//  kCFURLErrorRequestBodyStreamExhausted = -1021,
//  kCFURLErrorFileDoesNotExist           = -1100,
//  kCFURLErrorFileIsDirectory            = -1101,
//  kCFURLErrorNoPermissionsToReadFile    = -1102,
//  kCFURLErrorDataLengthExceedsMaximum   = -1103,


import Foundation

enum RequestMethod: String {
    case POST
    case GET
    case DELETE
    case PUT
}

struct NetworkRequester {
    static func makeNetworkRequest(category: String, onCompletion: @escaping (News?, NSDictionary?) -> Void){
        
        var result: News?
        
        let url = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=3a4a09c27c8946ebbdff9c55ea5be425"
        
        let resultErrorJSON:NSMutableDictionary = NSMutableDictionary()
        
        if !IfInternet.connected() {
            resultErrorJSON.setValue(false, forKey: "status")
            resultErrorJSON.setValue(NetworkRequester.getErrorMessageFromErrorCode(code: -1009), forKey: "errorMessage")
            resultErrorJSON.setValue("-1009", forKey: "errorCode")
            onCompletion(nil, resultErrorJSON)
            
        } else {
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
                
                print("\n\n\nURLSession.shared.dataTask Started\n\n\n")
                
                guard let data = data, error == nil else {
                    print("Error: ", error!)
                    resultErrorJSON.setValue(false, forKey: "status")
                    resultErrorJSON.setValue(NetworkRequester.getErrorMessageFromErrorCode(code: -1009), forKey: "errorMessage")
                    resultErrorJSON.setValue("-1009", forKey: "errorCode")
                    onCompletion(nil, resultErrorJSON)
                    return
                }
                print(data)
                
                do {
                    let decoder = JSONDecoder()
                    result = try decoder.decode(News.self, from: data)
                } catch {
                    print(error.localizedDescription)
                    if let httpResponse = response as? HTTPURLResponse {
                        resultErrorJSON.setValue(false, forKey: "success")
                        resultErrorJSON.setValue(NetworkRequester.getErrorMessageFromErrorCode(code: httpResponse.statusCode), forKey: "message")
                        resultErrorJSON.setValue(String(httpResponse.statusCode), forKey: "code")
                    }
                    onCompletion(nil, resultErrorJSON)
                }
                
                guard let json = result else {
                    print("Error :(")
                    if let httpResponse = response as? HTTPURLResponse {
                        resultErrorJSON.setValue(false, forKey: "success")
                        resultErrorJSON.setValue(NetworkRequester.getErrorMessageFromErrorCode(code: httpResponse.statusCode), forKey: "message")
                        resultErrorJSON.setValue(String(httpResponse.statusCode), forKey: "code")
                    }
                    onCompletion(nil, resultErrorJSON)
                    return
                }
                
                onCompletion(json, nil)
                
            }
            
            task.resume()
        }
    }
}


extension NetworkRequester {
    
    static func getErrorMessageFromErrorCode(code:Int) ->String
    {
        switch code {
        case -1001:
            //kCFURLErrorTimedOut
            return "Error Timed Out"
        case -1003:
            //kCFURLErrorCannotFindHost
            return "Cannot Find Host"
        case -1004:
            //kCFURLErrorCannotConnectToHost
            return "Cannot Connect To Host"
        case -1005:
            //kCFURLErrorNetworkConnectionLost
            return "Error Network Connection Lost"
        case -1009:
            //kCFURLErrorNotConnectedToInternet
            return "No internet connection"
        case 404:
            return  "REQUESTED RESOURCE NOT FOUND"
        default:
            return "ERROR_UNKNOWN"
        }
    }
}

