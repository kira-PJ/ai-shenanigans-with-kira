"""A Number Guessing Game"""

import random;   # Import Jac's random library for random number generation


# ----------------------------
# Define the Game object (like a base class)
# ----------------------------
obj Game {
    # Fields: attempts (int), won (bool, default False)
    has attempts: int,
        won: bool = False;

    # Method signature only (no body here)
    def play;   # Abstract: must be implemented by subclasses
}


# ----------------------------
# Define GuessTheNumberGame (inherits from Game)
# ----------------------------
obj GuessTheNumberGame (Game) {
    # Field: correct_number, random integer between 1–10
    has correct_number: int = random.randint(1, 10);

    # Declare method signatures — no code here yet!
    def init;               # Constructor
    override def play;      # Override parent's play method
    def process_guess(guess: int);  # Helper method to check guesses
}


# ----------------------------
# Entry point (Jac's "main")
# ----------------------------
# This block tells Jac where program execution starts
with entry {
    game = GuessTheNumberGame();  # Create new game instance
    game.play();                  # Call the play method
}
