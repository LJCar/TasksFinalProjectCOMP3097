//
//  ViewController.swift
//  Task
//
//  Created by Tech on 2025-04-11.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var taskTextField: UITextField!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    var tasks: [Tasks]?
    
    let appDelegate = UIApplication.shared.delegate

    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        fetchTasks()
    }
    
    @IBAction func addTask(_ sender: UITextField) {
        guard let input = sender.text, !input.isEmpty else { return }

        let title = extractTitle(from: input)
        let dueDate = extractDueDate(from: input)
        let id = UUID()
        
        guard let context = (appDelegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        
        let newTask = Tasks(context: context)
        newTask.taskTitle = title
        newTask.date = dueDate
        newTask.id = id
        
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Failed to save Task")
        }

        sender.text = ""
    }
    
    func fetchTasks() {
        guard let context = (appDelegate as? AppDelegate)?.persistentContainer.viewContext
        else { return }
        
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            tasks = try context.fetch(fetchRequest)
            taskTableView.reloadData()
        } catch {
            print("Failed to fetch Tasks")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        
        if let task = tasks?[indexPath.row] {
            
            cell.textLabel?.text = task.taskTitle ?? "Untitled Task"
            
            if let dueDate = task.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                cell.detailTextLabel?.text = formatter.string(from: dueDate)
            } else {
                cell.detailTextLabel?.text = "No due date"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = (appDelegate as? AppDelegate)?.persistentContainer.viewContext
            else { return }
            if let taskToDelete = tasks?[indexPath.row] {
                context.delete(taskToDelete)
                do {
                    try context.save()
                    fetchTasks()
                } catch {
                    print("Error Removing Task")
                }
            }
        }
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

    func weekdayFromInput(_ input: String) -> Int? {
        let weekdays = ["sunday": 1, "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6, "saturday": 7]
        
        for (day, value) in weekdays {
            if input.lowercased().contains(day) {
                return value
            }
        }
        return nil
    }

    func findDate(from input: String) -> String? {
         let patterns = [
            #"([a-zA-Z]+ \d{1,2}(.*?)\d{1,2}(:\d{2})?\s*[ap]m)"#,    // "April 18 8am"
            #"([a-zA-Z]+ \d{1,2} at \d{1,2}(:\d{2})?\s*[ap]m)"#,     // "April 20 at 3pm" or "May 5 at 3:30pm"
            #"(\d{1,2} [a-zA-Z]+ at \d{1,2}(:\d{2})?\s*[ap]m)"#,     // "20 April at 3pm"
            #"([a-zA-Z]+ \d{1,2})"#,                                 // "April 20"
            #"(\d{1,2} [a-zA-Z]+)"#                                  // "20 April"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(input.startIndex..., in: input)
                if let match = regex.firstMatch(in: input, options: [], range: range),
                    let matchRange = Range(match.range, in: input) {
                        return String(input[matchRange])
                    }
            }
        }

        return nil   
    }

    func extractDueDate(from input: String) -> Date?{
        let input = input.lowercased()
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)

        let words = input.split(separator: " ")

        for (i, word) in words.enumerated() {

            // "in"
            if word == "in", i + 2 < words.count {
                let value = Int(words[i + 1]) ?? 0
                let unit = words[i + 2]

                switch unit {
                case "minute", "minutes":
                    return calendar.date(byAdding: .minute, value: value, to: now)
                case "hour", "hours":
                    return calendar.date(byAdding: .hour, value: value, to: now)
                case "day", "days":
                    return calendar.date(byAdding: .day, value: value, to: now)
                case "month", "months":
                    return calendar.date(byAdding: .month, value: value, to: now)
                case "year", "years":
                    return calendar.date(byAdding: .year, value: value, to: now)
                default: break
                }
            }

            // "next"
            if word == "next", i + 1 < words.count {
                let nextWord = String(words[i + 1])

                switch nextWord {
                case "week":
                    return calendar.date(byAdding: .day, value: 7, to: now)
                case "month":
                    return calendar.date(byAdding: .month, value: 1, to: now)
                case "year":
                    return calendar.date(byAdding: .year, value: 1, to: now)
                case "day":
                    return calendar.date(byAdding: .day, value: 1, to: now)
                case "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday":
                    if let weekday = weekdayFromInput(nextWord) {
                        return calendar.nextDate(after: now, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTimePreservingSmallerComponents)
                    }
                default: break
                }      
            }
        }

        // Tomorrow
        if input.contains("tomorrow") {
            components.day! += 1
        }

        // Day of the week
        if let weekday = weekdayFromInput(input) {
            if let nextDay = calendar.nextDate(
                after: now,
                matching: DateComponents(weekday: weekday),
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) {
                components = calendar.dateComponents([.year, .month, .day], from: nextDay)
            }
        }

        // Time extraction
        let timeRegex = try! NSRegularExpression(pattern: #"((1[0-2]|0?[1-9])(:\d{2})?\s*[ap]m|\d{1,2}:\d{2})"#, options: [.caseInsensitive])
        if let match = timeRegex.firstMatch(in: input, options: [], range: NSRange(input.startIndex..., in: input)) {
            let matchString = String(input[Range(match.range, in: input)!])
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current

            if matchString.contains("am") || matchString.contains("pm") {
                formatter.dateFormat = "h:mma"
            } else {
                formatter.dateFormat = "HH:mm"
            }

            if let time = formatter.date(from: matchString.replacingOccurrences(of: " ", with: "")) {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
            }
        }

        // Date extraction
        var dateText = findDate(from: input.lowercased()) ?? ""
        
        if let timeMatch = timeRegex.firstMatch(in: input, options: [], range: NSRange(input.startIndex..., in: input)) {
            let matchString = String(input[Range(timeMatch.range, in: input)!])
            dateText += " \(matchString)"
        }
        
        let dateFormats = [ "MMMM d h:mma", "d MMMM h:mma", "MMMM d 'at' h:mma", "d MMMM 'at' h:mma", "MMMM d", "d MMMM"]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateText) {
                return date
            }
        }

        return calendar.date(from: components)
    }
}

