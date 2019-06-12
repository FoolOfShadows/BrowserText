//
//  LetterheadPrinting.swift
//  BrowserText
//
//  Created by Fool on 6/6/19.
//  Copyright © 2019 Fool. All rights reserved.
//

import Foundation
import Quartz

func printLetterheadWithText(_ text:String, fontName:String = "Times New Roman", fontSize: CGFloat = 12.0) {
    
    guard let img = NSImage(named: NSImage.Name("WPCM Letterhead Blank Cropped")) else { return }
    let imageView = NSImageView(frame: NSRect(origin: .zero, size: img.size))
    imageView.image = img
    
    let textView = NSTextView()
    textView.setFrameSize(NSSize(width: imageView.frame.width - 100, height: imageView.frame.height - 400))
    let theUserFont = NSFont(name: fontName, size: fontSize)
    let fontAttributes = NSDictionary(object: theUserFont!, forKey: NSAttributedString.Key.font as NSCopying)
    textView.typingAttributes = fontAttributes as! [NSAttributedString.Key : Any]
    
    textView.string = text
    
    imageView.addSubview(textView)
    textView.setFrameOrigin(NSPoint(x: imageView.frame.maxX - 575, y: imageView.frame.maxY - 125))
    
    let printInfo = NSPrintInfo.shared
    //This gets really close to fitting
    printInfo.leftMargin = 0
    printInfo.rightMargin = 0
    printInfo.isHorizontallyCentered = false
    printInfo.topMargin = -600
    printInfo.bottomMargin = -100
    
    let operation:NSPrintOperation = NSPrintOperation(view:imageView, printInfo: printInfo)
    operation.run()
    
}