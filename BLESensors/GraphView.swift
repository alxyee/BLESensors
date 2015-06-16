//
//  GraphView.swift
//  BLESensors
//
//  Created by Alex Yee on 6/15/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//
import Charts
class GraphView: LineChartView {
    var plotLineColors = PlotChartChoices.pastel()
    var dataSource: [[ChartDataEntry]]!
    var graphView: LineChartView!
    
    func plotData(){
        setupViewSettings()
        doPlot()
    }
    func setupViewSettings(){
        setDelegation()
        setLineChartSettings()
        setLineChartAxisSettings()
        setLineChartLegendSettings()
    }
    func doPlot(){
        var dataSets = [LineChartDataSet]()
        for dataEntry in dataSource{
        var set1 = LineChartDataSet(yVals: dataEntry, label: "Data")
        dataSets.append(set1)
        }
        var xAxisInd = [Int]()
        for i in 0...100 {
            xAxisInd.append(i)
        }
        var data = LineChartData(xVals: xAxisInd, dataSets: dataSets)
        data.setValueTextColor(UIColor.clearColor())
        
        var colorCounter = 0
        for lines in dataSets{
            lines.setColor(plotLineColors[colorCounter])
            lines.setCircleColor(plotLineColors[colorCounter])
            lines.lineWidth = 4.0
            lines.circleRadius = 0
            colorCounter = (colorCounter + 1) % plotLineColors.count
        }
        graphView.data = data
    }
}
extension GraphView{
    //Setup Chart
    func setDelegation(){
        graphView = self
        graphView.delegate = self
    }
    func setLineChartSettings(){
        graphView.highlightEnabled = true
        graphView.drawGridBackgroundEnabled = false
        graphView.drawBordersEnabled = false
        graphView.borderColor = UIColor.whiteColor()
        graphView.descriptionText = ""
        graphView.noDataTextDescription = ""
    }
    func setLineChartAxisSettings(){
        graphView.xAxis.gridColor = UIColor.whiteColor()
        graphView.xAxis.drawGridLinesEnabled = false
        graphView.xAxis.drawAxisLineEnabled = false
        
        graphView.leftAxis.gridColor = UIColor.whiteColor()
        graphView.leftAxis.labelFont = UIFont (name: "HelveticaNeue-UltraLight", size: 15)!
        graphView.leftAxis.startAtZeroEnabled = false
        graphView.leftAxis.drawGridLinesEnabled = false
        graphView.leftAxis.drawAxisLineEnabled = false
        
        graphView.rightAxis.gridColor = UIColor.whiteColor()
        graphView.rightAxis.drawGridLinesEnabled = false
        graphView.rightAxis.drawAxisLineEnabled = false
        graphView.rightAxis.drawLabelsEnabled = false
    }
    func setLineChartLegendSettings(){
        graphView.legend.font = UIFont (name: "HelveticaNeue-UltraLight", size: 18)!
        graphView.legend.position = .RightOfChartInside
        graphView.legend.form = .Circle
    }
}
extension GraphView: ChartViewDelegate{
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight){}
    func chartValueNothingSelected(chartView: ChartViewBase){}
    func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat){}
    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat){}
}



