# ----------------------------
# Implementation for Game.play
# ----------------------------
impl Game.play {
    # Base Game class doesn't know how to "play".
    # Force subclasses to implement their own version.
    raise NotImplementedError("Subclasses must implement this method.");
}


# ----------------------------
# Implementation for GuessTheNumberGame.init
# ----------------------------
impl GuessTheNumberGame.init {
    # Set default attempts to 10 at game start
    self.attempts = 10;

    # Pick a random secret number between 1 and 10
    self.correct_number = random.randint(1, 10);
}


# ----------------------------
# Implementation for GuessTheNumberGame.play
# ----------------------------
impl GuessTheNumberGame.play {
    # Game loop: keep asking for guesses while attempts remain
    while self.attempts > 0 {
        guess = input("Guess a number between 1 and 10: ");

        if guess.isdigit() {
            # Convert guess to int and check correctness
            self.process_guess(int(guess));
        } else {
            # If input isn't a number
            print("That's not a valid number! Try again.");
        }
    }

    # If loop ends and player hasn't won
    if not self.won {
        print("Sorry, you didn't guess the number. Better luck next time!");
    }
}


# ----------------------------
# Implementation for GuessTheNumberGame.process_guess
# ----------------------------
impl GuessTheNumberGame.process_guess(guess: int) {
    # Check if guess is higher than secret number
    if guess > self.correct_number {
        print("Too high!");
        self.attempts -= 1;   # Deduct attempt

    # Check if guess is lower than secret number
    } elif guess < self.correct_number {
        print("Too low!");
        self.attempts -= 1;   # Deduct attempt

    # Guess is correct!
    } else {
        print("Congratulations! You guessed correctly.");
        self.won = True;      # Mark game as won
        self.attempts = 0;    # End game immediately
        return;
    }

    # Show attempts left if incorrect guess
    print(f"You have {self.attempts} attempts left.");
}
