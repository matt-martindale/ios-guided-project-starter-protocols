import Foundation
//: We're building a dice game called _Knock Out!_. It is played using the following rules:
//: 1. Each player chooses a “knock out number” – either 6, 7, 8, or 9. More than one player can choose the same number.
//: 2. Players take turns throwing both dice, once each turn. Add the number of both dice to the player's running score.
//: 3. If a player rolls their own knock out number, they are knocked out of the game.
//: 4. Play ends when either all players have been knocked out, or if a single player scores 100 points or higher.
//:
//: Let's reuse some of the work we defined from the previous page.

protocol GeneratesRandomNumbers {
    func random() -> Int
}

class OneThroughTen: GeneratesRandomNumbers {
    func random() -> Int {
        return Int.random(in: 1...10)
    }
}

class Dice {
    let sides: Int
    let generator: GeneratesRandomNumbers
    
    init(sides: Int, generator: GeneratesRandomNumbers) {
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int {
        return Int(generator.random() % sides) + 1
    }
}

//: Now, let's define a couple protocols for managing a dice-based game.

protocol DiceGame {
    var dice: Dice { get }
    func play()
}

protocol DiceGameDelegate {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame, player: Player, didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}

//: Lastly, we'll create a custom class for tracking a player in our dice game.

class Player {
    let id: Int
    let knockOutNumber: Int = Int.random(in: 6...9)
    var score: Int = 0
    var knockedOut: Bool = false
    
    init(id: Int) {
        self.id = id
    }
}

//: With all that configured, let's build our dice game class called _Knock Out!_

class KnockOut: DiceGame {
    var dice: Dice = Dice(sides: 6, generator: OneThroughTen())
    var players: [Player] = []
    var delegate: DiceGameDelegate?
    
    init(numberOfPlayers: Int) {
        for i in 1...numberOfPlayers {
            let aPlayer = Player(id: i)
            players.append(aPlayer)
        }
    }
    
    func play() {
        delegate?.gameDidStart(self)
        var reachedGameEnd = false
        
        //we are going to play until the game is over
        while !reachedGameEnd {
            //each player who has not been knocket out gets a turn
            for player in players where player.knockedOut == false {
                let diceRollSum = dice.roll() + dice.roll()
                delegate?.game(self, player: player, didStartNewTurnWithDiceRoll: diceRollSum)
                
                //did i roll my knockout number??
                if diceRollSum == player.knockOutNumber {
                    //darn i rolled my knock out number what happens now?
                    print("Player: \(player.id) is knocked out by rolling \(player.knockOutNumber)")
                    //shoot i've been knocked out
                    player.knockedOut = true
                    
                    //Is the game over? did we knock out everyone?
                    let activePlayers = players.filter( {$0.knockedOut == false} )
                    if activePlayers.count == 0 {
                        //no more players, sad day, game over!!
                        reachedGameEnd = true
                        delegate?.gameDidEnd(self)
                        print("All players have been knocked out!")
                    }
                } else {
                    //hurray, I didn't get knocked out
                    player.score += diceRollSum
                    //did I win??
                    if player.score >= 100 {
                        //yay I won and the game is over
                        reachedGameEnd = true
                        print("Player: \(player.id) has won with a final score of \(player.score)")
                    }
                }
            }
        }
    }
}


//: The following class is used to track the status of the above game, and will conform to the `DiceGameDelegate` protocol.

class DiceGameTracker: DiceGameDelegate {
    
    var numberOfTurns = 0
    
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is KnockOut {
            print("Started a new game of knockout")
        }
        print("The game is using a\(game.dice.sides) sided dice")
    }
    
    func game(_ game: DiceGame, player: Player, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Player #\(player.id) rolled a \(diceRoll)")
    }
    
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns")
    }
    
    
}

//: Finally, we need to test out our game. Let's create a game instance, add a tracker, and instruct the game to play.

let tracker = DiceGameTracker()
let game = KnockOut(numberOfPlayers: 5)
game.delegate = tracker
game.play()
