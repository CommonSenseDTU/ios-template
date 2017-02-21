//
//  ViewController.swift
//  template
//
//  Created by Anders Borch on 1/30/17.
//  Copyright © 2017 Open mHealth. All rights reserved.
//

import UIKit
import RestKit
import musli

class ViewController: UIViewController {

    // TODO: Replace client id in bundle and secret here with a real client id and secret.
    let resourceManager = ResourceManager(clientSecret: "7b66-4479-97d9-02d3253bb5c5")
    
    var flowManager: ConsentFlowManager?
    
    private func presentErrorWithOKButton(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK alert button"),
                                      style: .default,
                                      handler: { (action) in
                                        alert.dismiss(animated: true, completion: nil)
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.resourceManager.survey(id: "d2dc0930-eed1-11e6-bd6f-f776b2d823f3") { (survey: Survey?, error: Error?) in
            guard error == nil else {
                self.presentErrorWithOKButton(controller: self,
                                              title: NSLocalizedString("Error", comment: "Unknown Error title"),
                                              message: NSLocalizedString("An error occurred, please try again later.", comment: "Unknown Error message"))
                return
            }
            guard survey != nil else {
                self.presentErrorWithOKButton(controller: self,
                                              title: NSLocalizedString("Survey Not Found", comment: "Survey Not Found error title"),
                                              message: NSLocalizedString("An error occurred, please try again later.", comment: "Survey Not Found error message"))
                return
            }
            self.flowManager = ConsentFlowManager(resourceManager: self.resourceManager, survey: survey!)
            let vc = self.flowManager!.viewController
            self.flowManager?.delegate.consentCompletion = { (_ controller: UIViewController, _ user: User?, authRefreshToken: String?, _ error: Error?) in
                if let userError = error as? ResourceManager.UserCreationError {
                    self.presentErrorWithOKButton(controller: controller,
                                                  title: userError.localizedTitle,
                                                  message: userError.localizedDescription)
                }
                guard user != nil else { return }
                vc.dismiss(animated: true, completion: nil)
            }
            self.present(vc, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

