//
//  ViewController.swift
//  Ghost
//
//  Created by Vanessa Woo on 5/14/17.
//  Copyright © 2017 Omnicon Industries. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var giveUp: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet var letters: [UIButton]!
    let dictionary: Dictionary = Dictionary()
    
    //MARK: Static Variables
    //will be modified by the dictionary
    static var nextText: String = ""
    static var lastWord = ""
    
    //This variable tracks the process of the dictionary async thread
    var alphabetRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = ""
        newGameButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Actions
    @IBAction func newGame(_ sender: UIButton) {
        sender.isHidden = true
        self.label.text = ""
        self.giveUp.isHidden = true
        for button in letters {
            button.isEnabled = true
        }
    }
    
    @IBAction func alphabetPressed(_ sender: UIButton) {
        if !alphabetRunning {
            alphabetRunning = true
            self.label.text! += sender.currentTitle!
            giveUp.isHidden = false
            if dictionary.searchOED(word: self.label.text!) {
                if ViewController.nextText != "0" {
                    self.label.text! += ViewController.nextText
                } else {
                    self.label.text! = "I give up. You win!"
                    newGameButton.isHidden = false
                    for button in letters {
                        button.isEnabled = false
                    }
                }
            } else {
                self.label.text! = "\(self.label.text!) is not a valid word, but \(ViewController.lastWord) is."
                for button in letters {
                    button.isEnabled = false
                }
                newGameButton.isHidden = false
                giveUp.isHidden = true
            }
            alphabetRunning = false
        } else {
            print ("realized wasn't done.")
        }
    }
    
    @IBAction func forfeit(_ sender: UIButton) {
        if ViewController.lastWord != self.label.text {
            self.label.text! = "I win... but you could have continued. My word would have been \(ViewController.lastWord)."
        } else {
            self.label.text! = "I win! :)"
        }
        for button in letters {
            button.isEnabled = false
        }
        newGameButton.isHidden = false
        sender.isHidden = true
    }
    
}
