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
        
        
    }
    
    func extractTitle(from input: String) -> String {
        
        let keywords = ["today", "tomorrow", "at", "in", "next", "am", "pm", "next week", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "january", "february", "march", "april", "may", "june", "july", "august", "september", "november", "december"]
        
        let words = input.lowercased().split(separator: " ").filter {}
    }

}

