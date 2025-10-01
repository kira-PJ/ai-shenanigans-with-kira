"""A Number Guessing Game"""

import random;   # Import random for generating the secret number


# ----------------------------
# Walker definition
# ----------------------------
walker GuessGame {
    # Field: will hold the user's current guess
    has guess: int;

    # Entry point for starting the walker
    # `root is the root node in the graph
    can start with `root entry;

    # The walker can also interact with "turn" nodes via process_guess
    can process_guess with turn entry;
}


# ----------------------------
# Node definition
# ----------------------------
node turn {
    # Each turn node has its own random "correct number"
    # In this version, the number lives on the node rather than the walker.
    has correct_number: int = random.randint(1, 10);
}


# ----------------------------
# Program entry (only when running in CLI mode)
# ----------------------------
with entry:__main__ {
    # Spawn several GuessGame walkers at the root
    # Each gets a different "guess" value to try
    root spawn GuessGame(3);   # a walker with guess = 3
    root spawn GuessGame(4);   # a walker with guess = 4
    root spawn GuessGame(5);   # a walker with guess = 5
    root spawn GuessGame(6);   # a walker with guess = 6
}
