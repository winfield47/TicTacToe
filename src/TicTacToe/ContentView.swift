//
//  ContentView.swift
//  KYLE-GameAppChallenge
//
//  Created by Kyle Winfield Burnham on 6/11/23.
//

import SwiftUI

struct TicTacToeSpot: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    var primaryColorOpposite: Color {
        colorScheme == .light ? Color.black : Color.white
    }
    var ultraThinMaterialOpposite: Color {
        colorScheme == .light ? Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.45) : Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.25)
    }
    func body(content: Content) -> some View {
        content
            .frame(width: 100, height: 100)
            .background(ultraThinMaterialOpposite)
            .foregroundColor(primaryColorOpposite)
            .border(primaryColorOpposite, width: 1)
    }
}

extension View {
    func ticTacToeSpot() -> some View {
        modifier(TicTacToeSpot())
    }
}

struct ContentView: View {
    // ⌘ + Shift + A -> toggle dark/light mode
    @Environment(\.colorScheme) var colorScheme
    
    var primaryColorOpposite: Color {
        colorScheme == .light ? Color.black : Color.white
    }
    var ultraThinMaterialOpposite: Color {
        colorScheme == .light ? Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.45) : Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.25)
    }
    
    @State var title = "Tic Tac Toe"
    @State var spots = ["","","","","","","","",""]
    @State var score = 0
    @State var displayScore = 0
    @State var pointsScoredText = ""
    @State var gamesPlayed = 0
    @State var showingGameOverAlert = false
    @State var gameOver = false
    @State var playerPiece = "O"
    @State var computerPiece = "X"
    
    let winningCombinations = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    
    var body: some View {
        
        Section {
            ZStack {
                AngularGradient(gradient: Gradient(colors: [.yellow,.green,.indigo,.red,.indigo,.purple]), center: (colorScheme == .light ? .topLeading : .bottomTrailing))
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text(title)
                        .font(.system(size: 56))
                        .bold()
                        .foregroundColor(primaryColorOpposite)
                    Text("Games played: \(gamesPlayed)")
                        .font(.subheadline)
                    VStack{
                        ForEach(0..<3) { i in
                            HStack {
                                ForEach(0..<3) { j in
                                    Spacer()
                                    // i*3+j is the position of each spot
                                    Button {
                                        gameOver == false ? (spots[i*3+j] == "" ? pressButton(i*3+j) : doNothing()) : doNothing()
                                    } label: {
                                        Text("\(spots[i*3+j])")
                                            .font(.system(size: 50))
                                            .ticTacToeSpot()
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    HStack{
                        Spacer()
                        Text("Score:")
                            .foregroundColor(primaryColorOpposite)
                            .font(.system(size: 40))
                            .italic()
                            .bold()
                        Text("\(displayScore) \(pointsScoredText)")
                            .foregroundColor(primaryColorOpposite)
                            .font(.system(size: 46))
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                    Button {
                        reset()
                    } label: {
                        Image(systemName:gameOver == true ? "play" : "flag.fill")
                        Text("\(gameOver == true ? "Play again!" : "Concede!")")
                    }
                    .bold()
                    .foregroundColor(primaryColorOpposite)
                    .frame(width: 120, height: 40)
                    .border(.primary)
                    .background(ultraThinMaterialOpposite)
                    Group {
                        Spacer()
                        HStack {
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Text("~Kyle Winfield Burnham")
                                .foregroundColor(primaryColorOpposite)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .alert("Game over!", isPresented: $showingGameOverAlert) {
                Button("Restart", action: restartGameCompletely)
            } message: {
                Text("You scored \(score) point\(score == 1 ? "" : "s") out of 10 games!")
            }
        }
    }
    
    func pressButton(_ position: Int){
        spots[position] = playerPiece
        checkGameOver()
        if !gameOver {
            pickComputerSpot()
        }
    }
    
    func pickComputerSpot() {
        var availableSpots: [Int] = []
        var spotsLeft = 0
        
        for spot in spots {
            if spot == "" {
                availableSpots.append(spotsLeft)
            }
            spotsLeft += 1
        }
        
        //
        // COMPUTER A.I.
        //
        if availableSpots.count != 0 {
            
            var isPickingSpot = true
            
            // GO FOR THE WIN
            for combination in winningCombinations {
                var oCount = 0
                for spot in combination {
                    
                    // check if there are two o's in any winning combination
                    if isPickingSpot && spots[spot] == computerPiece {
                        oCount += 1
                        // if there are, then
                        if oCount == 2 {
                            for spot in combination {
                                // put "O" in the remaining spot for the winning combination
                                if spots[spot] == "" {
                                    spots[spot] = computerPiece // win the game
                                    isPickingSpot = false // don't place O's in mulitple spots
                                }
                            }
                        }
                    }
                }
            }
            
            if isPickingSpot {
                
                // BLOCK PLAYER
                for combination in winningCombinations {
                    var xCount = 0
                    for spot in combination {
                        
                        // check if there are two x's in any winning combination
                        if isPickingSpot && spots[spot] == playerPiece {
                            xCount += 1
                            // if there are, then
                            if xCount == 2 {
                                for spot in combination {
                                    // put "O" in the remaining spot for the winning combination
                                    if spots[spot] == "" {
                                        spots[spot] = computerPiece // prevent player from winning easily
                                        isPickingSpot = false // don't place O's in mulitple spots
                                    }
                                }
                            }
                        }
                    }
                }
                // check to see if middle spot is open before picking a random spot
                if isPickingSpot {
                    if spots[4] == "" {
                        spots[4] = computerPiece
                        isPickingSpot = false
                    }
                    
                    // if there are no winning spots for player or computer,
                    // then pick a random spot
                    if isPickingSpot {
                        spots[availableSpots.randomElement()!] = computerPiece
                    }
                }
            }
        } else {
            title = "Cat's game."
            pointsScoredText = "(+0)"
            gameOver = true
        }
        checkGameOver()
    }
    
    func checkGameOver() {
        for combination in winningCombinations {
            var playerWins = true
            var computerWins = true
            // check to see if there are X/O's in all spots of each combination
            for index in combination {
                if playerWins == true && spots[index] == playerPiece {
                    playerWins = true
                } else {
                    // if one spot doesn't have an X, it is not a winning set
                    playerWins = false
                }
                if computerWins == true && spots[index] == computerPiece {
                    computerWins = true
                } else {
                    // if one spot doesn't have an O, it is not a winning set
                    computerWins = false
                }
            }
            if playerWins {
                title = "You win!"
                pointsScoredText = "(+1)"
                score += 1
                gameOver = true
                break
            } else if computerWins {
                title = "You lose..."
                pointsScoredText = "(-1)"
                score -= 1
                gameOver = true
            } else if spots.allSatisfy({ $0 != ""}) {
                title = "Cat's game."
                pointsScoredText = "(+0)"
                gameOver = true
            }
        }
        if gameOver {
            gamesPlayed += 1
            if gamesPlayed >= 10 {
                showingGameOverAlert = true
            }
        }
    }
    
    func doNothing(){
        
    }
    
    func reset() {
        if gameOver == false {
            score -= 1
        }
        displayScore = score
        title = "Tic Tac Toe"
        pointsScoredText = ""
        spots = ["","","","","","","","",""]
        playerPiece = ["X","O"].randomElement()!
        if playerPiece == "X" {
            computerPiece = "O"
            pickComputerSpot()
        } else {
            computerPiece = "X"
        }
        gameOver = false
    }
    func restartGameCompletely() {
        gamesPlayed = 0
        score = 0
        reset()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
