"""
Jac 1 (Step 1): Attributes are set inside init → feels like Python OOP.
Jac 2 (Step 2): Attributes are declared with has → feels like a schema definition (shorter, tidier, less typing).
"""
"""A Number Guessing Game"""

import random;   # Import Jac's random library to generate random numbers


# ----------------------------
# Base Game object
# ----------------------------
obj Game {
    # Define attributes (fields) directly in the class with `has`
    has attempts: int,           # number of guesses allowed
        won: bool = False;       # flag to track if the player won

    # Play method (must be overridden by child class)
    def play {
        raise NotImplementedError("Subclasses must implement this method.");
    }
}


# ----------------------------
# GuessTheNumberGame object (inherits from Game)
# ----------------------------
obj GuessTheNumberGame (Game) {
    # Define fields with default values
    has attempts: int = 10,                             # default 10 attempts
        correct_number: int = random.randint(1, 10);    # random number 1–10

    # Main game loop
    def play {
        while self.attempts > 0 {   # loop until no attempts left
            guess = input("Guess a number between 1 and 10: ");  # ask player
            if guess.isdigit() {    # check if input is numeric
                self.process_guess(int(guess));  # call helper function
                if self.won {       # if guessed right → stop loop
                    break;
                }
            } else {
                print("That's not a valid number! Try again.");  # invalid input
            }
        }

        # If player used all attempts and did not win
        if not self.won {
            print("Sorry, you didn't guess the number. Better luck next time!");
        }
    }

    # Helper function to check guess against the secret number
    def process_guess(guess: int) {
        if guess > self.correct_number {
            print("Too high!");     # guess is above the secret number
        } elif guess < self.correct_number {
            print("Too low!");      # guess is below the secret number
        } else {
            print("Congratulations! You guessed correctly.");  # correct guess
            self.won = True;        # update game state
            return;
        }

        # If wrong guess, reduce attempts
        self.attempts -= 1;
        print(f"You have {self.attempts} attempts left.");  # show attempts left
    }
}


# ----------------------------
# Entry point (Jac equivalent of Python's main)
# ----------------------------
# Run the game when program starts
with entry {
    game = GuessTheNumberGame();  # create a new game object
    game.play();                  # start playing the game
}
