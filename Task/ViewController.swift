//
//  ViewController.swift
//  Task
//
//  Created by Tech on 2025-04-11.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var taskTextField: UITextField!
    
    var tasks: [Tasks]?
    
    let appDelegate = UIApplication.shared.delegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addTask(_ sender: UITextField) {
        guard let input = sender.text, !input.isEmpty else { return }

        let title = extractTitle(from: input)
        
        
    }
    
    func extractTitle(from input: String) -> String {
        
        let keywords = ["today", "tomorrow", "at", "in", "next", "am", "pm", "week", "next", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "january", "february", "march", "april", "may", "june", "july", "august", "september", "november", "december"]
        
        let months = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "november", "december"]
        
        let inputToLower = input.lowercased()
        
        let timeRegex = try! NSRegularExpression(
            pattern: #"(\d{1,2}(:\d{2})?\s*[ap]m|\d{1,2}:\d{2})"#, options: [.caseInsensitive]
        )
        
        let inputNoTime = timeRegex.stringByReplacingMatches(in: inputToLower, options: [], range: NSRange(location: 0, length: inputToLower.utf16.count), withTemplate: "")
        
        let words = inputNoTime.split(separator: " ")
        var title: [String] = []

        for i in 0..<words.count {
            let word = String(words[i])

            if keywords.contains(word){
                continue
            }
            if i > 0, months.contains(String(words[i - 1])), Int(word) != nil {
                continue
            } 

            title.append(word)
        }
        return title.joined(separator: " ").capitalized
    }

    func extractDueDate(from input: String) -> Date?{
        let input = input.lowercased()
        let today = Date()
    }
}

