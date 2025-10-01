
'''
Explainable Movie Recommender in Jac

This file defines the schema and entrypoint for a simple movie recommender system
built on Jac’s graph + walker architecture.

What it does:
- Declares the main graph objects:
  • User nodes (with user_id and name)
  • Movie nodes (with movie id and title)
  • Genre nodes (with genre name)
- Declares edges to connect them:
  • likes        → User → Movie (user likes a movie)
  • has_genre    → Movie → Genre (movie belongs to a genre)
  • similar_to   → Movie → Movie (precomputed similarity score)
- Declares a Reco walker that:
  • Targets a specific user
  • Traverses the graph to compute recommendations
  • Will later be implemented in `recommender.impl.jac`
- Entrypoint spawns the Reco walker with demo parameters
  (user “u1”, requesting top-5 recommendations).

In short:
This is the "blueprint" (types + interfaces) for an explainable movie
recommender agent in Jac. The logic that loads data, builds the graph,
and ranks recommendations lives in the `.impl.jac` file.
'''

import json;   # used to read precomputed data (movies, similarities)
import os;     # file path helpers



# ---------- Node types ----------
# Each of these is a "thing" in the graph.

node User {
    has user_id: str,           # unique id for the user
        name: str;              # display name   
}

node Movie {
    has mid: str,               # movie id (e.g., "m1")
        title: str,             # human-friendly title
        genres: list = [],      # <-- add this
        sims: dict = {};        # <-- and this (other_mid -> similarity score)
}


node Genre {
    has name: str;              # genre name (e.g., "Sci-Fi")
}

# ---------- Edges ----------
# Relationships between nodes (graph structure).

edge likes {}                   # User -> Movie : user likes this movie
edge has_genre {}               # Movie -> Genre : movie belongs to this genre
edge similar_to {               # Movie -> Movie : similarity link from ML (TF-IDF + cosine)
    has weight: float = 0.0;    # similarity score (0..1)
}

# ---------- Walker ----------
# Reco is our "agent" that traverses the graph and returns recommendations.


walker Reco {
    has target_user: str,
        topk: int = 5,
        mnodes: dict = {},   # movie_id -> Movie node
        users:  dict = {},   # user_id  -> User node
        likes:  dict = {},   # user_id  -> [movie_id, ...]
        gindex: dict = {};   # genre    -> [movie_id, ...]
    can start with `root entry;
    def recommend();
}



# ---------- Entrypoint ----------
# When you run `jac recommender.jac`, this fires.
# We spawn a Reco walker that will build the demo graph (in impl) and print recs.

with entry {
    # Build a tiny demo graph + run a recommendation
    # (The graph loading/build and actual recommend() body live in recommender.impl.jac)
    root spawn Reco("u1", 5);   # target_user="u1", topk=5
}



