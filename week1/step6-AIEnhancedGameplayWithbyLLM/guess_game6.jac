"""A Number Guessing Game"""

import random;                       # random numbers for the secret
import from byllm.llm { Model } # bring in the Meaning-Typed LLM API

# ----------------------------------------
# Choose the LLM you want to use globally
# (pick ONE glob; the other can be kept as a comment)
# ----------------------------------------
# glob llm = Model(model_name="gpt-4o", verbose=False);
glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

# ----------------------------------------
# An LLM-backed helper: returns a fun hint string
# 'by llm()' wires this function to the global 'llm' above.
# ----------------------------------------
"""Provide a fun hint if guess is incorrect"""
def give_hint(guess: int, correct_number: int) -> str by llm();

# ----------------------------------------
# Walker: carries a single 'guess' value and
# auto-runs 'process_guess' whenever it enters a 'turn' node.
# ----------------------------------------
walker GuessGame {
    has guess: int;                        # this walker’s proposed guess

    can start with `root entry;            # where the walker begins
    can process_guess with turn entry;     # auto-run on entering 'turn'
}

# ----------------------------------------
# Node: each 'turn' holds its own secret number
# (Step 5 style: number lives on the node, not the walker)
# ----------------------------------------
node turn {
    has correct_number: int = random.randint(1, 10);
}

# ----------------------------------------
# CLI entry only (ignored when you 'jac serve' for cloud)
# Spawns multiple walkers (parallel guesses), no user input.
# ----------------------------------------
 with entry:__main__ {
    root spawn GuessGame(3);
    root spawn GuessGame(4);
    root spawn GuessGame(5);
    root spawn GuessGame(6);
}

