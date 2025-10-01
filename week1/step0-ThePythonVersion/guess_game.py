"""A Number Guessing Game"""

import random  # Import Python's random module for generating random numbers


# ----------------------------
# Base Game class
# ----------------------------
class Game:
    def __init__(self, attempts):
        # Initialize the number of attempts a player gets
        self.attempts = attempts

    def play(self):
        # This method is meant to be overridden in subclasses
        raise NotImplementedError("Subclasses must implement this method.")


# ----------------------------
# GuessTheNumberGame class (inherits from Game)
# ----------------------------
class GuessTheNumberGame(Game):
    def __init__(self, attempts=10):
        # Call the parent constructor (Game) to set attempts
        super().__init__(attempts)
        # Randomly pick a number between 1 and 10 as the correct answer
        self.correct_number = random.randint(1, 10)

    def play(self):
        # Main loop of the game
        while self.attempts > 0:
            # Ask the user for a guess
            guess = input("Guess a number between 1 and 10: ")

            # Check if the input is a digit
            if guess.isdigit():
                # Convert guess to int and process it
                if self.process_guess(int(guess)):
                    print("Congratulations! You guessed correctly.")
                    return  # Exit the game immediately if guess is correct
            else:
                # If input is not a valid number
                print("That's not a valid number! Try again.")

            # Reduce attempts after each guess
            self.attempts -= 1

            # Give feedback on remaining attempts
            if self.attempts > 0:
                print(f"You have {self.attempts} attempts left.")

        # If loop ends, player ran out of attempts
        print("Sorry, you didn't guess the number. Better luck next time!")

    def process_guess(self, guess):
        # Compare the guess with the correct number
        if guess > self.correct_number:
            print("Too high!")  # Player guessed above the number
        elif guess < self.correct_number:
            print("Too low!")   # Player guessed below the number
        else:
            # Correct guess → return True
            return True

        # Incorrect guess → return False
        return False


# ----------------------------
# Run the Game
# ----------------------------
game = GuessTheNumberGame()  # Create a game instance with default 10 attempts
game.play()                  # Start the game
