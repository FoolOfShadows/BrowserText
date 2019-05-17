//
//  WebMonitoringView.swift
//  BrowserText
//
//  Created by Fool on 5/13/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Cocoa
import WebKit

class WebMonitoringView: NSView, WKNavigationDelegate {

    let myPage = "https://static.practicefusion.com/apps/ehr/index.html?#/login"
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    

    
    private func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: myPage)!))
        
        return webView
    }
}
