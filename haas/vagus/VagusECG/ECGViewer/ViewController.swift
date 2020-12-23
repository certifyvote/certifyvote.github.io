//
//  ViewController.swift
//  ECGViewer
//
//  Created by Johan Sellström on 2020-11-05.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import UIKit
import CorePlot

class ViewController: UIViewController, CPTPlotDelegate, CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 0
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        switch fieldEnum {
            case UInt(CPTScatterPlotField.X.rawValue):
                return Double(idx)
            case UInt(CPTScatterPlotField.Y.rawValue):
                return 0.0
            default:
                return nil
        }
    }

    let kFrameRate = 5.0  // frames per second
    let kAlpha     = 0.25 // smoothing constant
    let kMaxDataPoints = 52
    let kPlotIdentifier = "Data Source Plot"

    var plotData = CPTMutableNumericData()
    var currentIndex = 0
    var dataTimer = Timer()
    var graph: CPTGraph!
    var titleSize = 8.0
    var animated = true

    var graphView: CPTGraphHostingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        graphView = CPTGraphHostingView(frame: self.view.frame)
        graph = CPTXYGraph(frame: graphView.bounds)

        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor.init(genericGray: 0.2).withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.1)

        let axisSet = graph.axisSet
        let x = axisSet?.axis(for: .X, at: 0)
        x?.labelingPolicy = .automatic
        x?.position = CGPoint(x: 0, y: 0)
        x?.majorGridLineStyle = majorGridLineStyle
        x?.minorGridLineStyle = minorGridLineStyle
        x?.minorTicksPerInterval = 9
        x?.labelOffset = 0.25
        x?.title = "X Axis"
        x?.titleOffset = 1.5

        let labelFormatter = NumberFormatter()
        labelFormatter.numberStyle = .none
        x?.labelFormatter = labelFormatter

        let y = axisSet?.axis(for: .Y, at: 0)
        y?.labelingPolicy = .automatic
        y?.position = CGPoint(x: 0, y: 0)
        y?.majorGridLineStyle = majorGridLineStyle
        y?.minorGridLineStyle = minorGridLineStyle
        y?.minorTicksPerInterval = 3
        y?.labelOffset = 0.25
        y?.title = "Y Axis"
        y?.titleOffset = 1.25

        x?.labelRotation = CGFloat(Double.pi/4.0)

        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.dataSource = self
        dataSourceLinePlot.interpolation = .curved
        dataSourceLinePlot.identifier = NSString("Data Source Plot")
        dataSourceLinePlot.cachePrecision = .double
        //var lineStyle = dataSourceLinePlot.dataLineStyle?.copy(with: nil)
        //lineStyle?.lineWidth = 3.0
        //lineStyle?.lineColor = CPTColor.green()

        graph.add(dataSourceLinePlot)
        
        let plotSpace = CPTXYPlotSpace()
        plotSpace.allowsUserInteraction = false
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: NSNumber(value: kMaxDataPoints-2))
        plotSpace.yRange = CPTPlotRange(location: 0.0, length: NSNumber(value: 1.0))

        dataTimer.invalidate()

        if animated {
            self.dataTimer = Timer.init(timeInterval: 0.3/kFrameRate, target: self, selector: #selector(newData), userInfo: nil, repeats: true)
            self.dataTimer.fire()
        }

    }

    @objc func newData() {

       // var theGraph = CPTGraph()
       // var thePlot = theGraph.plot(withIdentifier: <#T##NSCopying?#>)

    }
}

