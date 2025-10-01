# -----------------------------------
# Walker entry: GuessGame.start
# -----------------------------------
impl GuessGame.start {
    # Check if root already has an outgoing edge to a 'turn' node
    if not [root --> (`?turn)] {
        # If no 'turn' node exists yet, create one with a random number
        next = root ++> turn(random.randint(1, 10));
    } else {
        # If a 'turn' node already exists, reuse it
        next = [root --> (`?turn)];
    }

    # Move the walker to that 'turn' node
    visit next;
}


# -----------------------------------
# Walker action: GuessGame.process_guess
# -----------------------------------
impl GuessGame.process_guess {
    # If there's already a next node along [-->], move there
    if [-->] {
        visit [-->];

    } else {
        # Compare the walker's guess against the current node's number
        if self.guess < here.correct_number {
            print("Too high!");
            # Add a new turn node with the same correct_number
            # (lets the walker continue trying)
            here ++> turn(here.correct_number);

        } elif self.guess > here.correct_number {
            print("Too low!");
            # Same as above, attach another turn node for another chance
            here ++> turn(here.correct_number);

        } else {
            # If guess matches the correct_number
            print("Congratulations! You guessed correctly.");
            # Stop the walker — game ends
            disengage;
        }
    }
}
