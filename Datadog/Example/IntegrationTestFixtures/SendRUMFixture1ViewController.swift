/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import UIKit

internal class SendRUMFixture1ViewController: UIViewController {
    @IBOutlet weak var pushNextScreenButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the "Push Next Screen" button until simulated resource is loaded
        pushNextScreenButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        rumMonitor.startView(viewController: self)
        rumMonitor.startResourceLoading(
            resourceName: "/resource/1",
            request: URLRequest(url: URL(string: "https://foo.com/resource/1")!)
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rumMonitor.stopResourceLoading(
                resourceName: "/resource/1",
                response: HTTPURLResponse(
                    url: URL(string: "https://foo.com/resource/1")!,
                    mimeType: "image/jpeg",
                    expectedContentLength: -1,
                    textEncodingName: nil
                )
            )

            // Reveal the "Push Next Screen" button so UITest can continue
            self.pushNextScreenButton.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        rumMonitor.stopView(viewController: self)
    }
}
