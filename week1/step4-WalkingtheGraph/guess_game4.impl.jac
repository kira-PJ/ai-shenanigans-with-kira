# -----------------------------------
# Node-side behavior: turn.check
# -----------------------------------
impl turn.check {
    # Prompt the user for a guess on this turn node
    guess = input("Guess a number between 1 and 10: ");

    if guess.isdigit() {
        # 'visitor' is the active walker currently on this node.
        # We call the walker's method to handle game logic.
        visitor.process_guess(int(guess));
    } else {
        print("That's not a valid number! Try again.");
    }

    # Move the walker forward along a single outgoing edge [-->]
    # to the next node in the chain (if one exists).
    visit [-->];
}


# -----------------------------------
# Walker entry: build the graph, start traversal
# -----------------------------------
impl GuessGame.start_game {
    # Create a local label 'end' for the current construction point.
    # `root refers to the root node of the graph.
    # 'end: `root' initializes 'end' to the root node.
    # 'turn = here;' makes the 'turn' node archetype available in this scope.
    end: `root | turn = here;

    # Build a linear chain of 10 'turn' nodes, starting from root.
    for i = 0 to i < 10 by i += 1 {
        # 'end ++> (end := turn());' means:
        # - Create a new 'turn' node: turn()
        # - Rebind 'end' to that new node: (end := turn())
        # - Add a forward edge from the previous 'end' to the new 'end' with '++>'
        end ++> (end := turn());
    }

    # Begin walking forward along the [-->] edges.
    # This hands control to the nodes' 'check' ability (turn.check) at each step.
    visit [-->];
}


# -----------------------------------
# Walker logic: compare guess and react
# -----------------------------------
impl GuessGame.process_guess(guess: int) {
    if guess > self.correct_number {
        print("Too high!");
    } elif guess < self.correct_number {
        print("Too low!");
    } else {
        print("Congratulations! You guessed correctly.");
        # 'disengage' stops the walker immediately (ends the game).
        disengage;
    }
}
