import Foundation

class Player {
    var name: String = ""
    var brains: Int = 0
    var shotguns: Int = 0
    init(name: String){
        self.name = name
    }
    init(name: String, brains: Int, shotguns: Int){
        self.name = name
        self.brains = brains
        self.shotguns = shotguns
    }
}

protocol Dice {
    var sides: [Character] {get set}
    func roll() -> Character
}

class GreenDice: Dice {
    //3*🧠, 2*👣, 1*💥
    var sides: [Character] = ["🧠", "👣", "🧠", "🧠", "💥", "👣"]
    func roll() -> Character {
        let randomNumber = Int.random(in: 0 ... 5)
        return sides[randomNumber]
    }
}

class YellowDice: Dice {
    //2*🧠, 2*👣, 2*💥
    var sides: [Character] = ["💥", "👣", "💥", "🧠", "👣", "🧠"]
    func roll() -> Character {
        let randomNumber = Int.random(in: 0 ... 5)
        return sides[randomNumber]
    }
}

class RedDice: Dice {
    //1*🧠, 2*👣, 3*💥
    var sides: [Character] = ["💥", "👣", "🧠", "💥", "💥", "👣"]
    func roll() -> Character {
        let randomNumber = Int.random(in: 0 ... 5)
        return sides[randomNumber]
    }
}

class Game {
    var numberOfPlayers: Int = 0
    var players: [Player] = []
    var diceCup: [Dice] = [GreenDice(), GreenDice(), YellowDice(), RedDice(), GreenDice(), RedDice(), YellowDice(), GreenDice(), 
                           YellowDice(), RedDice(), GreenDice(), YellowDice(), GreenDice()]
    var dicesIndexesInPlay: [Int] = [0,1,2,3,4,5,6,7,8,9,10,11,12] // stores indexes of the dices in the dice cup that can be rolled
                                                                   // if a dice has already been rolled before in the current move 
                                                                   // we remove it from the index array
                                                                   // we also use this array to randomly pick a dice from the dice cup by using
                                                                   // the randomly picked index, we do not change anything in the diceCup array,
                                                                   // only in the index array

    func startNewGame() {
        numberOfPlayers = 0
        players = []
        print("")
        print("NEW GAME")
        print("============================")
        print("Welcome to Zombie Dice!")
        while numberOfPlayers < 2 || numberOfPlayers > 8 {
            print("Enter number of players: ", terminator: "")
            if let n = readLine() {
                if Int(n) != nil { // checks if the user has entered a number
                    if Int(n)! <= 8 && Int(n)! >= 2{ // checks for correct value
                        numberOfPlayers = Int(n)!
                    }
                    else {
                        print("Number of players should be between 2 and 8!")
                    }
                }
                else {
                    print("Enter a number!")
                }
            }      
        }
        print("Enter the player names, each name on a different line: ")
        for _ in 0 ... numberOfPlayers - 1 {
            print("> ", terminator:"")
            if let inputName = readLine() {
                players.append(Player(name: inputName))
            }
        }
        print("-----------------")
    }

    func printTable() { // prints the results of all players
        print("Results so far: ")
        let maxNameLength: Int = longestNameLength()
        var nameColumn: String = "Name".padding(toLength: maxNameLength + 2, withPad: " ", startingAt: 0)
        var brainColumn: String = "Brains"
        var line: String = nameColumn + brainColumn
        print(line)
        for i in 0 ... numberOfPlayers - 1 {
            nameColumn = players[i].name.padding(toLength: maxNameLength + 4, withPad: " ", startingAt: 0)
            brainColumn = String(players[i].brains)
            line = nameColumn + brainColumn
            print(line)
        }
    }

    func playOneMove(playerIndex i: Int) { // function that plays one move of a player, used later in function play()
        print("To roll the dices and then continue your move write 'roll', to stop your move - 'stop'") // helpful info for the player
        print("")
        print("Next player: \(players[i].name)")
        var userInput: String
        var brainsCollected: Int = 0
        var shotgunsReceived: Int = 0
        var dice1Index: Int = -1 // default value for a dice index, means that we should get a dice from the dice cup
        var dice2Index: Int = -1 // if it is not -1 it means that the dice the index represents was rolled as 👣 and we should roll it again 
        var dice3Index: Int = -1 // therefore we update the dice index only if it is != -1
        dicesIndexesInPlay = [0,1,2,3,4,5,6,7,8,9,10,11,12] // for every player the dice cup is refilled
        repeat {
            print("> ", terminator:"")
            if let input = readLine() {
                userInput = input
            }
            else {
                userInput = "" // use "" as a default value that will go through the cycle once again because userInput != "stop"
            }

            if userInput != "roll" && userInput != "stop" { // checks for invalid command and makes it possible to write again a command
                print("Command not recognised!")
                continue
            }
            if userInput == "stop" {
                break
            }
            else { // userInput = "roll"
                if dicesIndexesInPlay.count < 3 {
                    dicesIndexesInPlay = [0,1,2,3,4,5,6,7,8,9,10,11,12] // refilling the dice cup if there are less than 3 dices in the cup
                    print("-----------------")
                    print("Dice cup refilled.")
                    print("-----------------")
                }
                if dice1Index == -1 { // if the last roll of the dice was not 👣
                    dice1Index = dicesIndexesInPlay.randomElement()! // we pick a random index from the available ones
                    dicesIndexesInPlay.remove(at: dicesIndexesInPlay.firstIndex(of: dice1Index)!) // remove it from the available ones
                }
                if dice2Index == -1 {
                    dice2Index = dicesIndexesInPlay.randomElement()!
                    dicesIndexesInPlay.remove(at: dicesIndexesInPlay.firstIndex(of: dice2Index)!)
                }
                if dice3Index == -1 {
                    dice3Index = dicesIndexesInPlay.randomElement()!
                    dicesIndexesInPlay.remove(at: dicesIndexesInPlay.firstIndex(of: dice3Index)!)
                }

                rollAndUpdate(&dice1Index, &dice2Index, &dice3Index, &brainsCollected, &shotgunsReceived)
            }
        } while userInput != "stop" && shotgunsReceived < 3

        printMoveResult(brainsCollected, shotgunsReceived, userInput, i)
    }

    func rollAndUpdate(_ dice1Index: inout Int, _ dice2Index: inout Int, _ dice3Index: inout Int, _ brainsCollected: inout Int, _ shotgunsReceived: inout Int) {
        let dice1: Dice = diceCup[dice1Index] // gets the actual dice from the diceCup array by the index we randomly picked
        let dice2: Dice = diceCup[dice2Index]
        let dice3: Dice = diceCup[dice3Index]

        let dice1Result: Character = dice1.roll() // we roll the dice and store the result in these variables
        let dice2Result: Character = dice2.roll()
        let dice3Result: Character = dice3.roll()

        if dice1Result == "🧠" { // we check for every different possibility of the roll of each of the 3 dices
            brainsCollected += 1 // and we update the values for brains collected and shotguns received
            dice1Index = -1
        }
        else if dice1Result == "💥" {
            shotgunsReceived += 1
            dice1Index = -1
        }
        if dice2Result == "🧠" {
            brainsCollected += 1
            dice2Index = -1
        }
        else if dice2Result == "💥" {
            shotgunsReceived += 1
            dice2Index = -1
        }
        if dice3Result == "🧠" {
            brainsCollected += 1
            dice3Index = -1
        }
        else if dice3Result == "💥" {
            shotgunsReceived += 1
            dice3Index = -1
        }

        printRoll(dice1, dice2, dice3, dice1Result, dice2Result, dice3Result) // prints the result of the roll as well as the colour of the dice

        if shotgunsReceived < 3 { // updates the values so that the player knows how many brains and shotguns he/she has collected till this moment
                                  // helps him decide what to choose - to continue his/hers move by 'roll' or stop by writing command 'stop'
            print("-----------------")
            print("\(brainsCollected) x 🧠 collected till now")
            print("\(shotgunsReceived) x 💥 received till now")
            print("-----------------")
        } 
        else {
            print("-----------------")
        }
    }

    func printRoll(_ dice1: Dice, _ dice2: Dice, _ dice3: Dice, _ dice1Result: Character, _ dice2Result: Character, _ dice3Result: Character) {
        print("-----------------")
        print("Dice roll: ")

        if dice1 is GreenDice { // checks the type of each of the three dices
            print("\(dice1Result) <--- 🟩")
        } else if dice1 is YellowDice {
            print("\(dice1Result) <--- 🟨")
        }
        else {
            print("\(dice1Result) <--- 🟥")
        }

        if dice2 is GreenDice {
            print("\(dice2Result) <--- 🟩")
        } else if dice2 is YellowDice {
            print("\(dice2Result) <--- 🟨")
        }
        else {
            print("\(dice2Result) <--- 🟥")
        }

        if dice3 is GreenDice {
            print("\(dice3Result) <--- 🟩")
        } else if dice3 is YellowDice {
            print("\(dice3Result) <--- 🟨")
        }
        else {
            print("\(dice3Result) <--- 🟥")
        }
    }

    func printMoveResult(_ brainsCollected: Int, _ shotgunsReceived: Int, _ userInput: String, _ i: Int) {
        if shotgunsReceived >= 3 {
            print("💥💥💥 SHOT! No brains were eaten.")
            print("-----------------")
            printTable()
            print("-----------------")
        }
        else if userInput == "stop" {
            print("-----------------")
            print("\(brainsCollected) x 🧠 were eaten.")
            print("-----------------")
            players[i].brains += brainsCollected
            printTable()
            print("-----------------")
        }
    }

    func info() { // prints useful general info for the players at he beginning of tha game
        print("")
        print("Welcome to Zombie Dice!")
        print("Here are some important commands and notes before you play...")
        print("To set the game at the begining use the following commands:")
        print("To start a new game -> 'new'")
        print("To quit -> 'quit'")
        print("Then add the number of players and their names.")
        print("After setting the game, use the following commands:")
        print("To roll the dices and then continue your move write 'roll', to stop your move - 'stop'")
        print("")
        print("Note that if you have rolled 👣 on some dices they will be included in your next roll")
        print("if you decide to continue your move with the command 'roll'. The dices to roll will again be 3")
        print("as dices from the dice cup will be added if necessary.")
        print("If there are less than 3 dices in the dice cup, it will be refilled.")
        print("The player which has the most brains and those brains are >= 13 wins. If there are two or more players with the same ")
        print("result, the player who first reached the number of brains wins.")
        print("")
    }

    func play() { // the function that combines all other functions and plays the game for all players and all moves
        var userInput: String
        print("To start a new game -> 'new'")
        print("To quit -> 'quit'") 
        repeat {
            print("> ", terminator:"")
            if let input = readLine(){
                userInput = input
            }
            else {
                userInput = ""
            }
        } while userInput != "new" && userInput != "quit"
        if userInput == "quit" {
            return
        }
        startNewGame() 
        var hasWinner: Bool = false
        while !hasWinner {
            for i in 0 ... numberOfPlayers - 1 {
                playOneMove(playerIndex: i) // use the helpful function that plays one move of a player
            }
            let maxBrains: Int = maxPlayerBrains() // returns the maximum number brains a player has eaten till now
            if maxBrains >= 13 { // the game has a winner
                hasWinner = true
                let winnerName: String = findPlayerByBrains(brains: maxBrains)
                printWinner(winnerName)
                play() // recursively repeat the process thus giving the opportunity to play again or quit
            }
        }
    }

    func printWinner(_ winnerName: String) {
        print("")
        print("============================")
        print("WINNER:")
        print(winnerName)
        print("============================")
        print("")
    }

    func maxPlayerBrains() -> Int {
        var maxBrains: Int = 0
        for i in 0 ... numberOfPlayers - 1 {
            if players[i].brains > maxBrains {
                maxBrains = players[i].brains
            }
        }
        return maxBrains
    }

    func findPlayerByBrains(brains: Int) -> String {
        for i in 0 ... numberOfPlayers - 1 {
            if players[i].brains == brains {
                return players[i].name
            }
        }
        return ""
    }

    func longestNameLength() -> Int { // returns the maximum length of a name, used for padding in the printTable() function
        var maxLength: Int = 0
        for i in 0 ... numberOfPlayers - 1 {
            if players[i].name.count > maxLength {
                maxLength = players[i].name.count
            }
        }
        return maxLength
    }

}

var g = Game()
g.info()
g.play()

