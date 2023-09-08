//
//  ShareViewController.swift
//  harFiles
//
//  Created by cdd on 8/9/23.
//

import UIKit
import SwiftUI

class ShareViewController: UIViewController {
   override func viewDidLoad() {
       super.viewDidLoad()
       handleSharedData()
   }

    private func handleSharedData() {
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in extensionItems {
                if let attachments = item.attachments as? [NSItemProvider] {
                    for attachment in attachments {
                        if attachment.hasItemConformingToTypeIdentifier("public.url") {
                            attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] data, error in
                                if let url = data as? URL {
                                    if let jsonData = try? Data(contentsOf: url) {
                                        if let logData = try? JSONDecoder().decode(LogData.self, from: jsonData) {
                                            if let req = logData.log.entries.first?.request {
                                                DispatchQueue.main.async {
                                                    self?.presentApiView(with: req)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Complete the extension
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    private func presentApiView(with req: Request) {
        let storedRequest = StoredRequest(request: req, name: "请输入api名称")
        let contentView = ApiView(storedRequest: storedRequest, isRequestStored: false)
        let hostingController = UIHostingController(rootView: NavigationView {
            contentView
               .navigationBarTitle("API View")
       })
        self.addChild(hostingController)
        hostingController.view.frame = self.view.frame
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
