//
//  StartView.swift
//  Spacyshooter
//
//  Created by Apprenant 87 on 21/09/2024.
//

import SwiftUI
import SpriteKit

var shipChoice = UserDefaults.standard

struct StartViewMiniJeu: View {
    var body: some View {
        NavigationView {
           
            ZStack {
                
                VStack {
                    
                    Spacer()
                    
                    Text("Protege toi des hackeur !")
                        .font(.custom("Avenir", size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    Spacer()
                    NavigationLink {
                        miniJeuOtionel().navigationBarHidden(true).navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Commencez")
//                        Text pour lancer la game
                            .foregroundStyle(.yellow)
                    }
                    Spacer()
                    
                    HStack {
                      
                            Button {
                                makePlayerChoice()
                            }label: {
                                Text("Ship 1")
                                    .foregroundStyle(.orange)
                            }
                        .padding()
                      
                        Button {
                            makePlayerChoice2()
                        }label: {
                            Text("Ship 2")
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        
                        Button {
                            makePlayerChoice3()
                        }label: {
                            Text("Ship 3")
                                
                                .foregroundStyle(.orange)
                                
                        }
                        .padding()
                    }
                    Spacer()
                }
            }.background(Image("ecranDepart"))
            
        }.frame(width: 500, height: 1000,alignment: .center)
         
    }
    func makePlayerChoice() {
        shipChoice.set(1,forKey: "playerChoice")
    }
    
    func makePlayerChoice2() {
        shipChoice.set(2,forKey: "playerChoice")
    }
    
    func makePlayerChoice3() {
        shipChoice.set(3,forKey: "playerChoice")
    }
}

#Preview {
    StartViewMiniJeu()
}
