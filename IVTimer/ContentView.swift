//
//  ContentView.swift
//  IVTimer
//
//  Created by 孫揚喆 on 2022/3/20.
//

import SwiftUI
import AudioToolbox
import CoreHaptics
struct vibratePoint{
    var id:Int=0
    var hour:Int
    var minute:Int
    var second:Int
    init(hour:Int,minute:Int,second:Int,id:Int){
        self.id=id
        self.hour=hour
        self.second=second
        self.minute=minute
       
    }
}
extension UIPickerView {
    open override var intrinsicContentSize: CGSize {     return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)   } }
struct ContentView: View {
    @State var vibratePoints:[vibratePoint]=[]
    @State private var vibrateHour:Int=0
    @State private var vibrateMinute:Int=0
    @State private var vibrateSecond:Int=0
    @State private var remainingHour:Int=0
    @State private var remainingMinute:Int=0
    @State private var remainingSecond:Int=0
    @State private var PreviousSetedTime:[Int]=[0,0,0]
    @State private var totalSecond : CGFloat=0
    @State private var temp:Int=0
    @State private var trimTo:CGFloat=1
    @State private var timerIsActive=false
    @State private var timerPickerActive=true
    @State private var isPlaying=false
    @State private var afterReset=true
    @State private var engine: CHHapticEngine?
    let generator = UINotificationFeedbackGenerator()
    let timer=Timer.publish(every: 1, on: .main
                            , in: .common).autoconnect()
    //    func startTimer()->(){
    //        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate(timer:)), repeats: true)
    //    }
    //    @objc func timerUpdate(timer:Timer)->(){
    //        countdown-=1
    //
    //    }
    init(){
        UITableView.appearance().backgroundColor = .white
        UITableViewCell.appearance().backgroundColor = .white
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    func complexSuccess() {
        // make sure that the device supports haptics
        prepareHaptics()
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    var body: some View {
        VStack {
            ScrollView{
                VStack{
                    ZStack {
                        Circle()
                            .trim(from:0,to:trimTo)
                            .stroke(Color.yellow,style: StrokeStyle(lineWidth: 18, lineCap: .round))
                            .frame(width:350,height: 300)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut)
                            .padding(.top,50)
                            .shadow(color: Color.yellow,radius: 3)
                        Text("\((remainingHour>=10 ? String(remainingHour) : "0"+String(remainingHour))) : "+"\((remainingMinute>=10 ? String(remainingMinute) : "0"+String(remainingMinute))) : "+"\((remainingSecond>=10 ? String(remainingSecond) : "0"+String(remainingSecond)))")
                            .font(.system(size:48))
                            .fontWeight(.semibold)
                            .offset(y:20)
                        
                            .foregroundColor(Color.yellow)
                    }
                    .padding(.bottom,20)
                    if timerPickerActive{ GeometryReader { geometry in
                        HStack(spacing:0){
                            Picker(selection:$remainingHour, label: Text("abbd")) {
                                ForEach(0 ..< 24){
                                    item in
                                    Text(String(item)+"")
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60, alignment: .center)
                                .compositingGroup()
                                .clipped()
                            Picker(selection:$remainingMinute, label: Text("abbd")) {
                                ForEach(0 ..< 60){
                                    item in
                                    Text(String(item)+"")
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60, alignment: .center)
                                .compositingGroup()
                                .clipped()
                            Picker(selection:$remainingSecond, label: Text("abbd")) {
                                ForEach(0 ..< 60){
                                    item in
                                    Text(String(item))
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60, alignment: .center)
                                .compositingGroup()
                                .clipped()
                        }.animation(.easeInOut)
                            
                    }.frame(height:70)
                        
                    }
                    HStack{
                        Spacer()
                        Button {
                            if afterReset{
                                totalSecond = CGFloat(60*60*remainingHour+60*remainingMinute+remainingSecond)
                                PreviousSetedTime[0]=remainingHour
                                PreviousSetedTime[1]=remainingMinute
                                PreviousSetedTime[2]=remainingSecond
                            }
                            timerIsActive.toggle()
                            timerPickerActive.toggle()
                            isPlaying.toggle()
                        } label: {
                            
                            ZStack{
                                Circle()
                                    .frame(width:70,height:70)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "\(isPlaying ? "pause":"play.fill")")
                                    .font(.system(size:35))
                                    .foregroundColor(Color.white)
                            }
                            
                            
                            
                        }
                        Spacer()
                        Spacer()
                        Button {
                            afterReset=true
                            trimTo=1
                            isPlaying=false
                            timerPickerActive=true
                            timerIsActive=false
                            remainingHour=PreviousSetedTime[0]
                            remainingMinute=PreviousSetedTime[1]
                            remainingSecond=PreviousSetedTime[2]
                        } label: {
                            ZStack{
                                Circle()
                                    .frame(width:70,height:70)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size:35))
                                    .foregroundColor(Color.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top,isPlaying ? 103:25)
                    .padding(.bottom,25)
                    
                    
                    GeometryReader { geometry in

                        HStack(spacing:0){
                            Spacer()
                            Picker(selection:$vibrateHour, label: Text("abbd")) {
                                ForEach(0 ..< 24){
                                    item in
                                    Text(String(item)+"")
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60)
                                .labelsHidden()
                                .clipped()
                                .compositingGroup()
                                
                            Picker(selection:$vibrateMinute, label: Text("abbd")) {
                                ForEach(0 ..< 60){
                                    item in
                                    Text(String(item)+"")
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60)
                                .labelsHidden()
                                .clipped()
                                .compositingGroup()
                                
                            Picker(selection:$vibrateSecond, label: Text("abbd")) {
                                ForEach(0 ..< 60){
                                    item in
                                    Text(String(item))
                                }
                                
                            }.pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 60)
                                .labelsHidden()
//                                .frame(width: geometry.size.width/3, height: 60, alignment: .center)
                                .clipped()
                                .compositingGroup()
                                
                            Spacer()
                        }.animation(.easeInOut)
                            .padding(.top,20)
                    
                    }
                    .frame(height:60)
                    HStack{
                        Spacer()
                        Button (action:{
                            vibratePoints.append(vibratePoint(hour: vibrateHour,minute: vibrateMinute,second: vibrateSecond,id:vibratePoints.count))
                        } ){
                            
                                ZStack{
                                    Circle()
                                        .stroke(Color.red,style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                        .frame(width:50,height:50)
                                    Image(systemName: "plus")
                                        .font(.system(size:30))
                                        .foregroundColor(Color.red)
                                }
                                
                           
                        }
                    }.padding(.top,70)
                        VStack{
                            ForEach(0 ..< vibratePoints.count, id:\.self){
                                item in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .shadow(color: Color.yellow, radius: 5, x: 0, y: 0)
                                    HStack{
                                        Text("\(String(vibratePoints[item].hour)) : \(String(vibratePoints[item].minute)) : \(String(vibratePoints[item].second))")
                                            .font(.system(size:22))
                                        Spacer()
                                        Button(action:{
                                           vibratePoints.remove(at: item)
                                            return
                                        }){
                                            Image(systemName: "xmark")
                                                .foregroundColor(Color.red)
                                                .font(.system(size:18))
                                            
                                        }
                                    }.padding(.horizontal,10)
                                        .padding(.vertical,11)
                                }.frame(width:350)
                                    .padding(.bottom,8)
                            }
                            
                        }.padding(.top,30)
                    }.padding(.horizontal,30)
                    
                }.onReceive(timer) { _ in
                    if timerIsActive{
                        
                        trimTo -= (trimTo>0 ? (remainingSecond==1 && remainingHour==0 && remainingMinute==0 ?trimTo :Double(1)/totalSecond) : 0)
                        if remainingHour+remainingSecond+remainingMinute>0{
                            if vibratePoints.contains(where: {
                                $0.hour==remainingHour&&$0.minute==remainingMinute&&$0.second==remainingSecond
                            }){
//                                generator.notificationOccurred(.error)
                                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                                
                            }
                            if remainingSecond==0{
                                if remainingMinute==0{
                                    remainingHour-=1
                                    remainingMinute=59
                                    remainingSecond=59
                                }else{
                                    remainingMinute-=1
                                    remainingSecond=59
                                }
                            }else{
                                remainingSecond-=1
                            }
                        }
                        else{
                           
                            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                            afterReset=true
                            trimTo=1
                            isPlaying=false
                            timerPickerActive=true
                            timerIsActive=false
                            remainingHour=PreviousSetedTime[0]
                            remainingMinute=PreviousSetedTime[1]
                            remainingSecond=PreviousSetedTime[2]
                        }
                    }else{
                        return
                    }
                }
            }
        }
    
}
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .previewDevice("iPhone 13")
            ContentView()
                .previewDevice("iPhone 12")
            ContentView()
                .previewDevice("iPhone 11")
            ContentView()
                .previewDevice("iPhone 8 plus")
        }
    }
