//
//  AppDelegate.swift
//  BrightIntosh
//
//  Created by Niklas Rousset on 12.07.23.
//

import Cocoa
import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var active = true
    
    private var overlayAvailable = false

    var overlayWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let builtInScreen = getBuiltInScreen() {
            setupOverlay(screen: builtInScreen)
        }
        
        // Observe displays
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleScreenParameters),
                    name: NSApplication.didChangeScreenParametersNotification,
                    object: nil)
                
        // Menu bar app
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sun.max.circle", accessibilityDescription: "1")
        }
        setupMenus()
    }
    
    func setupOverlay(screen: NSScreen) {
        let rect = NSRect(x: screen.visibleFrame.origin.x, y: screen.visibleFrame.origin.y, width: screen.frame.width, height: screen.frame.height)
        overlayWindow = OverlayWindow(rect: rect, screen: screen)
        overlayAvailable = true
    }
    
    func destroyOverlay() {
        if let overlayWindow {
            overlayWindow.close()
            overlayAvailable = false
        }
    }
    
    func getBuiltInScreen() -> NSScreen? {
        for screen in NSScreen.screens {
            let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
            let displayId: CGDirectDisplayID = screenNumber as! CGDirectDisplayID
            if (CGDisplayIsBuiltin(displayId) != 0) {
                return screen
            }
        }
        return nil
    }

    func setupMenus() {
        let menu = NSMenu()
        
        let title = NSMenuItem(title: "BrightIntosh", action: nil, keyEquivalent: "")
        let toggle = NSMenuItem(title: active ? "Disable" : "Activate", action: #selector(toggleBrightIntosh) , keyEquivalent: "1")
        let exit = NSMenuItem(title: "Exit", action: #selector(exitBrightIntosh) , keyEquivalent: "2")
        menu.addItem(title)
        menu.addItem(toggle)
        menu.addItem(exit)
        statusItem.menu = menu
    }
    
    @objc func toggleBrightIntosh() {
        active.toggle()
        setupMenus()
        if (active == true) {
            if let builtInScreen = getBuiltInScreen() {
                setupOverlay(screen: builtInScreen)
            }
        } else {
            destroyOverlay()
        }
    }
    
    @objc func handleScreenParameters() {
        if let builtInScreen = getBuiltInScreen() {
            if (!overlayAvailable) {
                setupOverlay(screen: builtInScreen)
            }
        } else {
            destroyOverlay()
        }
    }
    
    @objc func exitBrightIntosh() {
        exit(0)
    }
}
