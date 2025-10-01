# -----------------------------------
# Walker entry: ensure a 'turn' exists, then go there
# -----------------------------------
impl GuessGame.start {
    # If root doesn't already point to a 'turn' node, create one
    if not [root --> (`?turn)] {
        next = root ++> turn(random.randint(1, 10));
    } else {
        # Otherwise reuse the existing 'turn' from root
        next = [root --> (`?turn)];
    }
    # Begin the walk on that turn node
    visit next;
}


# -----------------------------------
# Core logic: compare guess vs node's secret and react
# -----------------------------------
impl GuessGame.process_guess {
    # If there's already a forward edge, just walk along it first
    # (prevents piling multiple nodes in the same step)
    if [-->] {
        visit [-->];

    } else {
        # No forward edge yet: decide outcome on this node
        if self.guess < here.correct_number {
            # Tell the user WHAT happened + an LLM hint
            print("Too low!");
            print(give_hint(self.guess, here.correct_number));

            # Create the next attempt node (same secret)
            here ++> turn(here.correct_number);

            # ✨ Improvement: actually move forward to the new node
            visit [-->];

        } elif self.guess > here.correct_number {
            print("Too high!");
            print(give_hint(self.guess, here.correct_number));

            here ++> turn(here.correct_number);
            visit [-->];

        } else {
            # Nailed it
            print("Congratulations! You guessed correctly.");
            disengage;   # stop the walker (game over)
        }
    }
}
