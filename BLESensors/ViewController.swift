//
//  ViewController.swift
//  BLESensors
//
//  Created by Alex Yee on 6/10/15.
//  Copyright (c) 2015 Alex Yee. All rights reserved.
//

import UIKit
import Charts
import MessageUI
/*
1). INITIALIZE - a) BLE + b) Chart View
2). STORE DATA - BLE delegate
3). PREPARE DATA - Chart View
4). DISPLAY DATA - Chart View
5). EMAIL DATA - MFMaildelegate
*/
class ViewController: UIViewController, BLEManagerDelegate {
    enum GraphViews {
        case AllAccelerometers
        case AllX
        case AllY
        case AllZ
    }
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var segmentControlView: UISegmentedControl!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var plotView: GraphView!
    
    //Plot variables
    let PLOT_WINDOW = 100
    var plotLineColors = PlotChartChoices.pastel()
    var whatToGraph = GraphViews.AllAccelerometers
    
    //BLE variables
    var bluetoothManager:BLEManager!
    var connectedDevices = [String: Accelerometer]()
    var plottedDevices = [String: GraphData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1). INITIALIZE
        initializeViewController()
    }
    //2). STORE DATA
    func notifyBLEDataReceived(data: [UInt8], sensorName: String) {
        for var index = 0; index + 3 <= data.count; index += 3 {
            var rawData = Int16(data[index+1]) << 8 | Int16(data[index+2])
            var timeDate = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.MediumStyle)
            connectedDevices[sensorName]?.timeStamp.append(timeDate)
            if(data[index] == 0x0A){
                setAccelerometerValues(sensorName, rawValue: Double(rawData)/4096, sensorEnum: "X")
            }
            if(data[index] == 0x0B){
                setAccelerometerValues(sensorName, rawValue: Double(rawData)/4096, sensorEnum: "Y")
            }
            if(data[index] == 0x0C){
                setAccelerometerValues(sensorName, rawValue: Double(rawData)/4096, sensorEnum: "Z")
            }
        }
        setupPlotData(sensorName)
        plotData()
    }
    //Store accelerometer data in connected device dictionary
    func setAccelerometerValues(sensorName: String, rawValue: Double, sensorEnum: String){
        if(sensorEnum == "X"){
            connectedDevices[sensorName]?.storeXVal(rawValue)
        }
        if(sensorEnum == "Y"){
            connectedDevices[sensorName]?.storeYVal(rawValue)
        }
        if(sensorEnum == "Z"){
            connectedDevices[sensorName]?.storeZVal(rawValue)
        }
    }
    //3). PREPARE DATA for plotting
    func setupPlotData(sensorName:String){
        plottedDevices[sensorName]?.accelX = []
        plottedDevices[sensorName]?.accelY = []
        plottedDevices[sensorName]?.accelZ = []
        
        let dataCountX = connectedDevices[sensorName]?.accelX.count
        let dataCountY = connectedDevices[sensorName]?.accelY.count
        let dataCountZ = connectedDevices[sensorName]?.accelZ.count
        for i in 0...PLOT_WINDOW{
            
            let safeguardX = getValidPlotIndex(dataCountX! - 1 - PLOT_WINDOW + i, sizeOfArray: dataCountX!)
            let safeguardY = getValidPlotIndex(dataCountY! - 1 - PLOT_WINDOW + i, sizeOfArray: dataCountY!)
            let safeguardZ = getValidPlotIndex(dataCountZ! - 1 - PLOT_WINDOW + i, sizeOfArray: dataCountZ!)
            
            let dataX = connectedDevices[sensorName]?.accelX[safeguardX] as Double!
            let xDataEntry = ChartDataEntry(value: dataX, xIndex: i)
            plottedDevices[sensorName]?.accelX.append(xDataEntry)
            
            let dataY = connectedDevices[sensorName]?.accelY[safeguardY] as Double!
            let yDataEntry = ChartDataEntry(value: dataY, xIndex: i)
            plottedDevices[sensorName]?.accelY.append(yDataEntry)
            
            let dataZ = connectedDevices[sensorName]?.accelZ[safeguardZ] as Double!
            let zDataEntry = ChartDataEntry(value: dataZ, xIndex: i)
            plottedDevices[sensorName]?.accelZ.append(zDataEntry)
        }
    }
    func getValidPlotIndex(expectedIndex:Int, sizeOfArray:Int)->Int{
        let validPlotIndex =  max(min(expectedIndex, sizeOfArray-1), 0)
        return validPlotIndex
    }
    
    //4). DISPLAY DATA on Chart View
    func plotData(){
        plotView.dataSource = []
        for keys in plottedDevices.keys {
            if(plottedDevices[keys]!.accelX.count > 0){
                switch(whatToGraph){
                case GraphViews.AllX:
                    plotView.dataSource?.append(plottedDevices[keys]!.accelX)
                case GraphViews.AllY:
                    plotView.dataSource?.append(plottedDevices[keys]!.accelY)
                case GraphViews.AllZ:
                    plotView.dataSource?.append(plottedDevices[keys]!.accelZ)
                default:
                    plotView.dataSource?.append(plottedDevices[keys]!.accelX)
                    plotView.dataSource?.append(plottedDevices[keys]!.accelY)
                    plotView.dataSource?.append(plottedDevices[keys]!.accelZ)
                }
            }
        }
        plotView.plotData()
    }
}
//MARK: View Controller Initialization
extension ViewController{
    func initializeViewController(){
        //a) Setup BLE
        bluetoothManager = BLEManager()
        bluetoothManager.bleDelegate = self
        
        setConnectedDeviceDictionary()
        
        //Setup Buttons
        mailButton.setTitle("\u{f0ee}", forState: UIControlState.Normal)
        connectButton.setTitle("\u{f00d}", forState: UIControlState.Normal)
        connectButton.tintColor = UIColor(red: 255/255.0, green: 105/255.0, blue: 97/255.0, alpha: 1.0)
    }
    func setConnectedDeviceDictionary(){
        connectedDevices["Accel A"] = Accelerometer()
        plottedDevices["Accel A"] = GraphData()
        connectedDevices["Accel B"] = Accelerometer()
        plottedDevices["Accel B"] = GraphData()
        connectedDevices["Accel C"] = Accelerometer()
        plottedDevices["Accel C"] = GraphData()
        connectedDevices["Accel D"] = Accelerometer()
        plottedDevices["Accel D"] = GraphData()
    }
}
//MARK: GUI Button Handler
extension ViewController{
    //ACTION - Connection button pressed
    @IBAction func connectionButtonPressed(sender: UIButton) {
        if(connectButton.titleLabel?.text == "\u{f20e}"){
            connectBLEPeripherals()
        }
        else{
            disconnectBLEPeripherals()
        }
    }
    func connectBLEPeripherals(){
        connectButton.setTitle("\u{f00d}", forState: UIControlState.Normal)
        connectButton.tintColor = UIColor(red: 255/255.0, green: 105/255.0, blue: 97/255.0, alpha: 1.0)
        bluetoothManager.centralManager.scanForPeripheralsWithServices([BLEConstants.RBL_SERVICE_UUID], options: nil)
    }
    func disconnectBLEPeripherals(){
        connectButton.setTitle("\u{f20e}", forState: UIControlState.Normal)
        connectButton.tintColor = self.view.tintColor
        for peripherals in bluetoothManager.connectedPeripherals{
            bluetoothManager.centralManager.cancelPeripheralConnection(peripherals)
        }
        bluetoothManager.connectedPeripherals = []
    }
    //ACTION - Segment Control pressed
    @IBAction func chooseGraphView(sender: AnyObject) {
        switch segmentControlView.selectedSegmentIndex
        {
        case 0: whatToGraph = GraphViews.AllAccelerometers
        case 1: whatToGraph = GraphViews.AllX
        case 2: whatToGraph = GraphViews.AllY
        case 3: whatToGraph = GraphViews.AllZ
        default: whatToGraph = GraphViews.AllAccelerometers
        }
    }
}
//MARK: ChartViewDelegate
extension ViewController: ChartViewDelegate{
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight){}
    func chartValueNothingSelected(chartView: ChartViewBase){}
    func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat){}
    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat){}
}
//MARK: MFMaildelegate
// 5) EMAIL DATA
extension ViewController: MFMailComposeViewControllerDelegate{
    @IBAction func sendEmail(sender : AnyObject) {
        var emailTitle = "Accel Data"
        var messageBody = "Data from accelerometers"
        var toRecipents = ["alxyee1@gmail.com"]
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        var sensorData = NSMutableString()
        var longestDataLength = 0
        var titleString = ""
        for keys in connectedDevices.keys{
            let numElems = connectedDevices[keys]!.accelX.count-1
            if(numElems > 0){
                titleString += "\(keys) Date, \(keys) Time, \(keys), AccelX \(keys) AccelY, \(keys) AccelX, "
            }
            if(numElems > longestDataLength){
                longestDataLength = numElems
            }
        }
        titleString += "\n"
        sensorData.appendString(titleString)
        for i in 0...longestDataLength {
            for keys in connectedDevices.keys{
                if(i < connectedDevices[keys]!.accelX.count){
                    sensorData.appendFormat("%@, %0.3f, %0.3f, %0.3f,",
                        connectedDevices[keys]!.timeStamp[i],
                        connectedDevices[keys]!.accelX[i],
                        connectedDevices[keys]!.accelY[i],
                        connectedDevices[keys]!.accelZ[i])
                }
            }
            sensorData.appendFormat("\n")
        }
        mc.addAttachmentData(sensorData.dataUsingEncoding(NSUTF8StringEncoding), mimeType: "text/csv", fileName: "SensorData.csv")
        self.presentViewController(mc, animated: true, completion: nil)
    }
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}

