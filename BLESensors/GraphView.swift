//
//  GraphView.swift
//  BLESensors
//
//  Created by Alex Yee on 6/15/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//
import Charts
class GraphView: LineChartView {
    var graphView: LineChartView!
    var dataLabelAndArray = [(String, [Double])]()
    var plotWindowLength = 100
    private var plotLineColors = PlotChartChoices.pastel()
    func plotData(){
        setupViewSettings()
        doPlot()
    }
    private func setupViewSettings(){
        setDelegation()
        setLineChartSettings()
        setLineChartAxisSettings()
        setLineChartLegendSettings()
    }
    
    private func doPlot(){
        var dataSets = [LineChartDataSet]()
        for (dataLabel, rawDataArray) in dataLabelAndArray{
            var dataSet = LineChartDataSet(yVals: getChartDataEntry(rawDataArray), label: dataLabel)
            dataSets.append(dataSet)
        }
        var xAxisInd = [Int]()
        for i in 0...plotWindowLength {
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
    private func getChartDataEntry(dataArray:[Double])->[ChartDataEntry]{
        var dataEntryFromDouble = [ChartDataEntry]()
        for i in 0..<dataArray.count {
            dataEntryFromDouble.append(ChartDataEntry(value: dataArray[i], xIndex: i))
        }
        return dataEntryFromDouble
    }
}
extension GraphView{
    //Setup Chart
    private func setDelegation(){
        graphView = self
        graphView.delegate = self
    }
    private func setLineChartSettings(){
        graphView.highlightEnabled = true
        graphView.drawGridBackgroundEnabled = false
        graphView.drawBordersEnabled = false
        graphView.borderColor = UIColor.whiteColor()
        graphView.descriptionText = ""
        graphView.noDataTextDescription = ""
    }
    private func setLineChartAxisSettings(){
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
    private func setLineChartLegendSettings(){
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



