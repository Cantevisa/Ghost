//
//  Dictionary.swift
//  Ghost
//
//  Created by Vanessa Woo on 5/17/17.
//  Copyright © 2017 Omnicon Industries. All rights reserved.
//

import Foundation

class Dictionary {
    
    //MARK: Constants
    let appId = "45c1b2ef"
    let appKey = "86b215c7b6624e2c00422c07b2145ab1"
    let language = "en"
    let alphabetList: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    func searchOED(word: String, smart: Bool, numLetters: Int) -> Bool {
        //MARK: Set up HTTP request
        let word_id = word.lowercased() //word id is case sensitive and lowercase is required
        let url = URL(string: "https://od-api.oxforddictionaries.com/api/v1/search/\(language)?q=\(word_id)&prefix=true")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        //MARK: Data Variables
        var valid = true
        var letter: String = ""
        var validWordFound = false
        var tries = 0
        var doneProcessing = false
        
        //MARK: Actions
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                //turns results list into indexable dictionary of words
                guard let results = jsonData?["results"] as? [[String: Any]] else {
                    // Handle error here
                    print ("error")
                    return
                }
                valid = results.count > 0
                if valid {
                    let numberOfLetters: Int = word.characters.count
                    var numResults: Int = results.count
                    if !smart && numResults > 1 {
                        numResults /= 2
                        if numResults > 10 {
                            numResults = 10
                        }
                    }
                    while (!validWordFound && tries <= numResults) {
                        tries += 1
                        //pick a random word from the list of all words returned by the search
                        let resultNum = Int(arc4random_uniform(UInt32(results.count)))
                        letter = results[resultNum]["word"] as! String
                        
                        //if the found word is shorter than the already existing word, then don't use it
                        //also if it's a proper noun, then don't use it
                        if letter.characters.count <= numberOfLetters || letter.lowercased() != letter || letter.contains("-") || letter.contains(" ") || letter.contains(".") {
                            continue
                        }
                        
                        if smart && (numLetters % 2 == letter.characters.count % 2) && tries < numResults {
                            continue
                        }
                        
                        ViewController.lastWord = letter
                        
                        //get the next letter after the already existing word
                        let index = letter.index(letter.startIndex, offsetBy: numberOfLetters)
                        letter = String(letter[index])
                        
                        //limit to 5 tries, if the letter ultimately chosen is an actual letter, than great!
                        validWordFound = self.alphabetList.contains(letter)
                    }
                    if tries < numResults + 1 {
                        ViewController.nextText = letter
                        print ("Letter:", letter)
                    } else {
                        ViewController.nextText = "0"
                    }
                } else {
                    ViewController.nextText = "0"
                }
            } else {
                print(error)
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
            doneProcessing = true
        }).resume()
        while !doneProcessing {
            //makes sure processing is finished before returning
        }
        return valid
    }
}
