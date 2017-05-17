//
//  ViewController.swift
//  Ghost
//
//  Created by Vanessa Woo on 5/14/17.
//  Copyright © 2017 Omnicon Industries. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var field: UITextField!
    var doneProcessing: Bool = false
    var nextText: String = ""
    
    let alphabetList: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = ""
        self.field.delegate = self
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        newGameButton.isHidden = true
        
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function can either check the dictionary validity of a word
    func searchOED(word: String) -> Bool {
        //MARK: Set up HTTP request
        let appId = "45c1b2ef"
        let appKey = "86b215c7b6624e2c00422c07b2145ab1"
        let language = "en"
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
        self.doneProcessing = false
        
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
                    while (!validWordFound && tries <= 5) {
                        //pick a random word from the list of all words returned by the search
                        let resultNum = Int(arc4random_uniform(UInt32(results.count)))
                        letter = results[resultNum]["word"] as! String
                        
                        //if the found word is shorter than the already existing word, then don't use it
                        if letter.characters.count <= numberOfLetters {
                            continue
                        }
                        
                        //get the next letter after the already existing word
                        let index = letter.index(letter.startIndex, offsetBy: numberOfLetters)
                        letter = String(letter[index])
                        
                        //limit to 5 tries, if the letter ultimately chosen is an actual letter, than great!
                        validWordFound = self.alphabetList.contains(letter)
                        tries += 1
                    }
                    if tries < 6 {
                        self.nextText = letter
                        print ("Letter:", letter)
                    } else {
                        self.nextText = "0"
                    }
                }
            } else {
                print(error)
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
            self.doneProcessing = true
        }).resume()
        while !doneProcessing {
            //makes sure processing is finished before returning
        }
        return valid
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.label.text! += textField.text!
        textField.text = ""
        dismissKeyboard()
        if searchOED(word: self.label.text!) {
            if nextText != "0" {
                self.label.text! += nextText
            } else {
                self.label.text! = "I give up. You win!"
                newGameButton.isHidden = false
            }
        } else {
            self.label.text! = "\(self.label.text!) is not a valid word!"
            newGameButton.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        sender.isHidden = true
        self.label.text = ""
        self.field.text = ""
    }
}
