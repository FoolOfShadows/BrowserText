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
//        webView.becomeFirstResponder()
//        webView.selectAll(self)
        
        //let url = webView.url!
        //let currentURLRequest = URLRequest(url:url)
//        let urlCache = URLCache.shared
//        let currentPage = urlCache.cachedResponse(for: currentURLRequest)
        //let currentDataString = String(data: currentPage!.data, encoding: .utf8)!
        
        //print(url)
//        do {
//            let allText = try String(contentsOf: url, encoding: .utf8)
//            let pasteBoard = NSPasteboard.general
//            pasteBoard.clearContents()
//            pasteBoard.setString(currentDataString, forType: NSPasteboard.PasteboardType.string)
//            
//        } catch {
//            print("Failed to get text from URL")
//        }
        var viewContent = String()
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    viewContent = (html as? String) ?? "No string"
//                                    let pasteBoard = NSPasteboard.general
//                                    pasteBoard.clearContents()
//                                    pasteBoard.setString(viewContent, forType: NSPasteboard.PasteboardType.string)
                                    //print(html)
//                                    print("Name: \(viewContent.findRegexMatchesOf(RegularExpressions.ptName.rawValue).map( { $0.cleanTheTextOf(extraPtNameBits)}))\nAge: \(viewContent.findRegexMatchesOf(RegularExpressions.ptAgeGender.rawValue).map( { $0.cleanTheTextOf(extraPtAgeGenderBits)}))\nDOB: \(viewContent.findRegexMatchesOf(RegularExpressions.ptDOB.rawValue).map( { $0.cleanTheTextOf(extraPtDOBBits)}))\nDx: \(viewContent.findRegexMatchesOf(RegularExpressions.ptDx.rawValue).map( { $0.cleanTheTextOf(extraPtDxBits)}))")
//                                    print("PSH: \(cleanPMH(viewContent.simpleRegExMatch(RegularExpressions.psh.rawValue).cleanTheTextOf(extraPSHBits)))\nPMH: \(cleanPMH(viewContent.simpleRegExMatch(RegularExpressions.pmh.rawValue).cleanTheTextOf(extraPMHBits)))")
        })
        //Using ID 'ember311' I get the same text as I do by selecting all and copying
        webView.evaluateJavaScript("document.getElementById('ember311').innerText",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    viewContent = (html as? String) ?? "No string"

                                    let pasteBoard = NSPasteboard.general
                                    pasteBoard.clearContents()
                                    pasteBoard.setString(viewContent, forType: NSPasteboard.PasteboardType.string)
        })

        
//        webView.copy()
//        let pasteBoard = NSPasteboard.general
        
        //NSApplication.shared.sendAction(#selector(copy), to: webView, from: self)
//        let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text"))
        
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }



}
