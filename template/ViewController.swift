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
    
    var consentManager: ConsentFlowManager?
    var taskManager: TaskFlowManager?
    
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

        self.resourceManager.survey(id: "6a9fb9f0-139f-11e7-8358-e501073245bf") { (survey: Survey?, error: Error?) in
            guard error == nil else {
                var title = NSLocalizedString("Error", comment: "Unknown Error title")
                var message = NSLocalizedString("An error occurred, please try again later.", comment: "Unknown Error message")
                if let response = (error as? NSError)?.userInfo[AFRKNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        title = NSLocalizedString("Resource Not Found", comment: "404 Error title")
                        message = NSLocalizedString("The survey could not be found. Contact support or try again later.", comment: "404 Error message")
                    }
                }
                self.presentErrorWithOKButton(controller: self,
                                              title: title,
                                              message: message)
                return
            }
            guard survey != nil else {
                self.presentErrorWithOKButton(controller: self,
                                              title: NSLocalizedString("Survey Not Found", comment: "Survey Not Found error title"),
                                              message: NSLocalizedString("An error occurred, please try again later.", comment: "Survey Not Found error message"))
                return
            }

            self.consentManager = ConsentFlowManager(resourceManager: self.resourceManager, survey: survey!)
            self.taskManager = TaskFlowManager(resourceManager: self.resourceManager, survey: survey!)

            let consentController = self.consentManager!.viewController
            self.consentManager?.delegate.consentCompletion = { (_ controller: UIViewController, _ user: User?, authRefreshToken: String?, _ error: Error?) in
                if let userError = error as? ResourceManager.UserCreationError {
                    self.presentErrorWithOKButton(controller: controller,
                                                  title: userError.localizedTitle,
                                                  message: userError.localizedDescription)
                }
                guard user != nil else { return }
                consentController.dismiss(animated: true, completion: {
                    guard let taskController = self.taskManager!.viewController(task: survey!.task) else { return }
                    self.taskManager?.start(task: survey!.task)
                    self.present(taskController, animated: false, completion: nil)
                })
            }
            self.present(consentController, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

