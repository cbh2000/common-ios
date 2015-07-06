//
//  PaginatedVCExample.swift
//  IzeniCommon
//
//  Created by Christopher Bryan Henderson on 6/3/15.
//  Copyright (c) 2015 Christopher Bryan Henderson. All rights reserved.
//

import UIKit

class PaginatedVCExample: PaginatedTableViewController, PaginatedTableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    var data: [String] = []
    
    func downloadPage(page: Int, success: (serializedResponse: AnyObject) -> Void, failure: () -> Void) -> NSURLSessionDataTask {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        let url = "https://demo.toweez.com/api/ticket/?page=\(page + 1)"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "Token 1973d2b956c77db82c94b90802f8988bf7d4fa9c"
        ]
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error?.code == NSURLErrorCancelled {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? 0
                println("\(statusCode) \(url)")
                if statusCode == 200 {
                    let serialized = NSJSONSerialization.JSONObjectWithData(data!, options: .allZeros, error: nil) as! [String:AnyObject]
                    success(serializedResponse: serialized)
                } else {
                    failure()
                }
            })
        })
        println("GET \(url)")
        task.resume()
        return task
    }
    
    func isLastPage(serializedResponse: AnyObject) -> Bool {
        let json = (serializedResponse as! [String:AnyObject])
        return json["next"] as? String == nil
    }
    
    func clearData() {
        data = []
    }
    
    func appendPageData(serializedResponse: AnyObject) {
        let response = serializedResponse as! [String:AnyObject]
        for result in response["results"] as? [[String:AnyObject]] ?? [] {
            let id = result["id"] as! String
            assert(!contains(data, id))
            data.append(id)
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel!.text = data[indexPath.row]
        return cell
    }
}