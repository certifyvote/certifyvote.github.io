//
//  SurveyViewController.swift
//  Vagus
//
//  Created by Johan Sellström on 2020-10-29.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import Foundation
import CareKit
import CareKitUI
import CareKitStore
import ResearchKit

// 1. Subclass a task view controller to customize the control flow and present a ResearchKit survey!
class SurveyViewController: OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {

    // 2. This method is called when the use taps the button!
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {

        // 2a. If the task was marked incomplete, fall back on the super class's default behavior or deleting the outcome.
        if !isComplete {
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
            return
        }

        // 2b. If the user attempted to mark the task complete, display a ResearchKit survey.
        let answerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 1, defaultValue: 5, step: 1, vertical: false,
                                                 maximumValueDescription: "Very painful", minimumValueDescription: "No pain")
        let painStep = ORKQuestionStep(identifier: "pain", title: "Pain Survey", question: "Rate your pain", answer: answerFormat)
        let surveyTask = ORKOrderedTask(identifier: "survey", steps: [painStep])
        let surveyViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        surveyViewController.delegate = self

        // 3a. Present the survey to the user
        present(surveyViewController, animated: true, completion: nil)

    }

    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
        guard reason == .completed else {
            taskView.completionButton.isSelected = false
            return
        }

        // 4a. Retrieve the result from the ResearchKit survey
        let survey = taskViewController.result.results!.first(where: { $0.identifier == "pain" }) as! ORKStepResult
        let painResult = survey.results!.first as! ORKScaleQuestionResult
        let answer = Int(truncating: painResult.scaleAnswer!)

        // 4b. Save the result into CareKit's store
        controller.appendOutcomeValue(withType: answer, at: IndexPath(item: 0, section: 0), completion: nil)
    }
}
