"""A Number Guessing Game"""

import random;   # Import random library for generating a secret number


# ----------------------------
# Walker definition
# ----------------------------
walker GuessGame {
    # Each walker carries its own secret number to be guessed
    has correct_number: int = random.randint(1, 10);

    # Entry point for this walker
    # "can start_game" means: this walker can begin at the `root` node
    can start_game with `root entry;

    # Declare a function to check a player's guess
    def process_guess(guess: int);
}


# ----------------------------
# Node definition
# ----------------------------
node turn {
    # This node can be checked by the GuessGame walker
    # "entry" means this node has an accessible entrypoint for the walker
    can check with GuessGame entry;
}


# ----------------------------
# Program entry (Jac main block)
# ----------------------------
with entry {
    # Spawn a new GuessGame walker at the root node
    GuessGame() spawn root;
}
