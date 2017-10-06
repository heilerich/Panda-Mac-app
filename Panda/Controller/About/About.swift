//
//  About.swift
//  Panda
//
//  Created by Paolo Tagliani on 11/22/14.
//  Copyright (c) 2014 Paolo Tagliani. All rights reserved.
//

import Cocoa

class About: NSWindowController, NSTextFieldDelegate {

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var developerLabel: NSTextField!
    @IBOutlet weak var graphicLabel: NSTextField!
    @IBOutlet weak var developerLabelWidth: NSLayoutConstraint!

    @IBOutlet weak var graphicLabelWidth: NSLayoutConstraint!
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.window?.titleVisibility = NSWindow.TitleVisibility.hidden;

        versionLabel.isEditable = false
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.stringValue = "Version \(version)"
        }

        let html = "<a style =\"text-decoration: none; color:white;\" href=\"http://pablosproject.com/\">@PablosPoject</a>"
        let developerString = attributedStringFromHTML(HTML: html as NSString)
        developerLabel.isSelectable = true
        developerLabel.allowsEditingTextAttributes = true
        developerLabel.isEditable = false
        developerLabel.attributedStringValue = developerString
        let size = developerLabel.sizeThatFits(NSSize(width: 10000, height: 1100));
        developerLabelWidth.constant = size.width

        let html_graphic = "<a style =\"text-decoration: none; color:white;\" href=\"http://www.beatricevivaldi.graphics/\">@BeatriceVivaldi</a>"
        let graphicString = attributedStringFromHTML(HTML: html_graphic as NSString)
        graphicLabel.isSelectable = true
        graphicLabel.allowsEditingTextAttributes = true
        graphicLabel.isEditable = false
        graphicLabel.attributedStringValue = graphicString
        let size_graphic = graphicLabel.sizeThatFits(NSSize(width: 10000, height: 1100));
        graphicLabelWidth.constant = size_graphic.width

    }

    func attributedStringFromHTML(HTML: NSString) -> NSAttributedString {
        let font = NSFont(name: "HelveticaNeue-Light", size: 24)
        let htmlString = "<span style=\"color: white; font-family:'\(font!.fontName)'; font-size:\(font!.pointSize)px;\">\(HTML)</span>"
        let data = htmlString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let string = try? NSAttributedString(data: data!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)

        return string!;
    }
}

