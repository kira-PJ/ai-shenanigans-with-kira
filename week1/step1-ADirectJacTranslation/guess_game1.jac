"""A Number Guessing Game"""

import random;   # Import Jac's random library for generating random numbers


# ----------------------------
# Base Game class
# ----------------------------
class Game {
    # Constructor: initialize attempts and game state
    def init(self: Game, attempts: int = 10) {
        self.attempts = attempts;   # Number of attempts allowed
        self.won = False;           # Boolean flag to track if player has won
    }

    # Abstract method: must be implemented in subclasses
    def play(self: Game) {
        raise NotImplementedError("Subclasses must implement this method.") ;
    }
}


# ----------------------------
# GuessTheNumberGame class (inherits from Game)
# ----------------------------
class GuessTheNumberGame(Game) {
    # Constructor: call parent init and set a random number between 1–10
    def init(self: GuessTheNumberGame, attempts: int = 10) {
        super.init(attempts);                       # Call parent Game.init
        self.correct_number = random.randint(1, 10);  # Pick secret number
    }

    # Main game loop
    def play(self: GuessTheNumberGame) {
        while self.attempts > 0 {   # Keep looping while attempts remain
            guess = input("Guess a number between 1 and 10: ");  # Ask player for input
            if guess.isdigit() {   # Validate input is a number
                self.process_guess(int(guess));   # Process the guess
                if self.won {      # If the player guessed correctly, stop game
                    break;
                }
            } else {
                print("That's not a valid number! Try again.");  # Invalid input feedback
            }
        }
        # If all attempts are used and no win
        if not self.won {
            print("Sorry, you didn't guess the number. Better luck next time!");
        }
    }

    # Function to check if guess matches the secret number
    def process_guess(self: GuessTheNumberGame, guess: int) {
        if guess > self.correct_number {
            print("Too high!");   # Guess is above the secret number
        } elif guess < self.correct_number {
            print("Too low!");    # Guess is below the secret number
        } else {
            print("Congratulations! You guessed correctly.");  # Correct!
            self.won = True;      # Mark game as won
            return;
        }

        # Deduct one attempt for an incorrect guess
        self.attempts -= 1;
        print(f"You have {self.attempts} attempts left.");  # Show remaining attempts
    }
}


# ----------------------------
# Program entry point
# ----------------------------
with entry {
    game = GuessTheNumberGame();  # Create a new game object
    game.play();                  # Start the game
}
