//
//  TapFrenzy.swift
//  Tap_frenzy_game
//
//  Created by TEST on 2026-06-10.
//

import SwiftUI
internal import Combine

struct TapFrenzy: View {
    
    @State var countDownTimer = 10
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var score = 0
    
    @State private var showGameOver = false
    
    private func resetGame() {
        
            showGameOver = false
            countDownTimer = 10
            score = 0
            
            
        }
//    private func checkHighScore()
//    {
//        if score > ScoreManager.shared.tapFrenzyHighScore{
//            ScoreManager.shared.tapFrenzyHighScore = score
//        }
//    }
    
    var body: some View {
        VStack {
           
            Text("Tap Frenzy")
                .frame(alignment: .top)
                .font(.largeTitle)
                .bold()
                .padding(20)
            
            Text("Score : \(score)")
                .font(.system(size: 25))
            Spacer()
            
            Button(action: {
                if(countDownTimer > 0 && timerRunning == true){
                    score += 1
            
                }
                else{
                    timerRunning = true
                }
                
            }) {
                Text("TAP")
                    .font(.headline)
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color.blue)
                    .clipShape(Circle())
                
            }
            .contentShape(Circle())
            .padding(60)
            
            
            Spacer()
            
            
            VStack{
                Text("\(countDownTimer)").onReceive(timer){ _ in
                    if countDownTimer > 0 && timerRunning{
                        countDownTimer -= 1
                    }else if countDownTimer == 0{
                        timerRunning = false
                        showGameOver = true
                        //checkHighScore()
                    }
                }
                .font(.system(size: 45))
                .alert("Game Over", isPresented: $showGameOver) {
                    Button("Play Again") {
                        
                        resetGame()
                        
                    }
                } message: {
                    Text("Final Score: \(score) points")
                }
                
            }
            
        }
    }
    
        

        
}


#Preview {
    TapFrenzy()
}
