//
//  ViewController.swift
//  BrowserText
//
//  Created by Fool on 2/26/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    //var webView: WKWebView!
    
    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: myPage)
        let request = URLRequest(url: url!)
        
        //webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.load(request)
        //self.view.addSubview(webView)
        
        //webView.frame.size = self.view.fittingSize
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.heightAnchor.constraint(equalTo: self.view.heightAnchor)])
    }

//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("Navigated to: \(webView.url)")
//    }
    
    
    @IBAction func getDataFromBrowser(_ sender: Any) {
        var viewContent = String()
        
        //Using ID 'ember311' I get the same text as I do by selecting all and copying
        webView.evaluateJavaScript("document.getElementById('ember311').innerText",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    viewContent = (html as? String) ?? "No string"
        })

        viewContent.copyToPasteboard()
        
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }



}
