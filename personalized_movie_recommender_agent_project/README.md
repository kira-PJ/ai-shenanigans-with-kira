Explainable Movie Recommender (Jac + ML)

TL;DR: A tiny, teachable movie recommender you can read in one sitting.
We use Jac (graph + walkers) + a TF-IDF similarity precompute.
Then we recommend movies with explanations like “because you liked Interstellar”.

What’s inside (plain English)

Graph schema (Jac):

User nodes (user_id, name)

Movie nodes (mid, title, genres, sims)

Genre nodes (name)

Edges are created, but the recommender logic relies on simple in-memory maps instead of graph traversal (because your Jac build doesn’t expose neighbors() or .outgoing()).

Precompute (Python): a quick TF-IDF + cosine similarity over movie plots/genres to build sims.json (top-K similar movies for each movie).

Walker (agent): Reco

Builds the graph once in start (loads JSON, creates nodes, stores handy maps).

Scores candidates via similarity + tiny genre bonus.

Prints Top-K with human-readable reasons.

Why we built it this way

Your Jac toolchain doesn’t provide helpers like root.outgoing()/neighbors().
So we designed around it: build the graph (for clarity), but use dict indexes on the walker:

mnodes: movie_id → Movie

users: user_id → User

likes: user_id → [movie_id,…]

gindex: genre → [movie_id,…]

That keeps things fast, readable, and version-proof. You can still show off graph structure, and your recommender logic stays simple.

Project layout
personalized_movie_recommender_agent_project/
├─ recommender.jac           # schema + walker declarations + entry
├─ recommender.impl.jac      # implementation: start() + recommend()
├─ data/
│  ├─ movies.json            # tiny movie dataset (id, title, genres, plot)
│  ├─ sims.json              # precomputed top-K similarities (from Python)
│  └─ likes.json             # (optional) persisted user likes
├─ scripts/
│  └─ build_sims.py          # TF-IDF + cosine → writes sims.json
└─ README.md                 # this file

Data formats

movies.json (minimal example)

[
  {
    "id": "m2",
    "title": "Interstellar",
    "genres": ["Sci-Fi", "Adventure"],
    "plot": "A team travels through a wormhole in search of a new home for humanity."
  },
  {
    "id": "m3",
    "title": "The Dark Knight",
    "genres": ["Action", "Crime"],
    "plot": "Batman faces the Joker in a high-stakes battle for Gotham."
  }
]


sims.json (top-K similar per movie)

{
  "m2": [["m10", 0.74], ["m7", 0.63], ["m3", 0.22]],
  "m3": [["m8", 0.68], ["m2", 0.22]]
}


Where each ["other_id", score] came from TF-IDF + cosine on title + genres + plot.

How it works (in 30 seconds)

Precompute similarities in Python (TF-IDF + cosine) → sims.json.

Jac Reco.start:

Loads movies.json and sims.json.

Creates Genre and Movie nodes.

Builds indexes: mnodes, users, likes, gindex.

Seeds a demo user “u1” with two liked movies.

Calls recommend().

Jac Reco.recommend:

Pulls the user’s liked movies from likes.

For each liked movie, collects candidates from sims and same-genre lists.

Scores candidates: similarity weight + 0.05 genre bonus.

Ranks and prints Top-K with an explanation string.

Setup

(Optional) Create and activate the Jac environment you already used:

# you already did something like:
python3 -m venv .envjac
source .envjac/bin/activate
pip install jaclang


Install Python libs for the precompute:

pip install scikit-learn


Build similarities:

python scripts/build_sims.py
# outputs: data/sims.json


Run the recommender:

jac recommender.jac


You should see Top-K recommendations + reasons.

Usage cheatsheet

Change user:

In with entry { root spawn Reco("u1", 5); } change "u1" to another id you’ve put in users & likes.

Change K (how many recs): second argument to Reco(...).

Add more movies: append to data/movies.json, re-run the precompute.

Tune similarity: edit scripts/build_sims.py (ngrams, min_df, K).

Genre bias: change the +0.05 bonus in recommender.impl.jac.

Teaching notes (useful for slides)

Jac mental model: “objects on a canvas + a little agent that walks around.”

We don’t rely on .outgoing() because your build doesn’t expose it. We do show the graph structure in code, and then use “indexes” like we would in a service.

Explainability: every recommendation carries a reason:

“because you liked ‘X’ (sim=0.73, +genre)”

or “shares genre ‘Sci-Fi’ with ‘Interstellar’”

Swap similarity: you can replace TF-IDF with embeddings later without touching Jac logic (only sims.json changes).

Common pitfalls (and fixes)

none vs None → use None (capital N).

neighbors(root) / node.outgoing() missing → we use maps (mnodes, users, likes, gindex) instead.

Movie.__init__() unexpected keyword 'genres' → make sure node Movie declares genres: list = [] and sims: dict = {}.

_read_json not defined → define the tiny helper or inline json.load.

F-strings with :.2f/lambda → keep it simple: use str() and manual sorting (Jac parser is picky).

Roadmap / Extensions (pick your adventure)

Interactive likes API: add def add_like(uid: str, mid: str) on the walker and re-run recommend().

Persist likes: save likes to data/likes.json.

Diversity control: limit max items per genre in the final list.

Embeddings: replace TF-IDF with sentence embeddings for better semantic matches.

Serve as API: once happy, explore jac serve style deployment to get an HTTP endpoint.

License

ChatGPT + KIRA 