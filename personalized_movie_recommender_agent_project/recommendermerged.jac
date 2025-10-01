
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
        title: str;             # human-friendly title
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
    has target_user: str,       # which user to recommend for (e.g., "u1")
        topk: int = 5;          # how many recommendations to produce
    can start with `root entry;  # entrypoint: start walking from the graph root
    def recommend();            # main logic (implemented in .impl.jac)
}

# ---------- Entrypoint ----------
# When you run `jac recommender.jac`, this fires.
# We spawn a Reco walker that will build the demo graph (in impl) and print recs.

with entry {
    # Build a tiny demo graph + run a recommendation
    # (The graph loading/build and actual recommend() body live in recommender.impl.jac)
    root spawn Reco("u1", 5);   # target_user="u1", topk=5
}



"""
Recommender Implementation (.impl.jac)

What this file does:
- Loads data files (movies.json, sims.json) from ./data/.
- Builds the graph:
  • Genre nodes (deduplicated)
  • Movie nodes linked to their genres (has_genre edges)
  • Movie→Movie similarity edges (similar_to with weight)
  • A demo User node (u1) with a couple of liked movies
- Runs the Reco.recommend() method:
  • Walks the user’s likes
  • Gathers candidate movies via similar_to edges and shared-genre neighbors
  • Scores candidates: similarity weight (+ small genre bonus)
  • Ranks and prints Top-K with a human-readable explanation
This file is the “brains” to the schema in recommender.jac.

Recommender Implementation (.impl.jac) — fixed for Jac parser quirks.

Key changes:
- Use os.getcwd() to find ./data instead of here.file_path().
- Use plain 'root' (no backticks).
- Iterate dicts by key (avoid .items()).
- No Python-style tuple unpacking in for-loops.

Recommender Implementation — typed-edges avoided (version-agnostic).

- Uses only untyped edges (++)
- Stores genres on Movie.genres
- Stores similarity scores on Movie.sims (dict: other_mid -> weight)
"""

impl Reco.recommend {
    # --- Locate the target user node by id ---
    user = none;
    for e in root.outgoing() {
        if istype(e.to, User) and e.to.user_id == self.target_user {
            user = e.to; break;
        }
    }
    if user == none {
        print("User " + self.target_user + " not found.");
        disengage;
    }

    # --- Collect likes & seen set ---
    liked = [];
    seen  = {};
    for e in user.outgoing() {
        if istype(e.to, Movie) {
            liked.append(e.to);
            seen[e.to.mid] = True;
        }
    }
    if len(liked) == 0 {
        print("User has no likes yet. Seed their profile first.");
        disengage;
    }

    # --- Score candidates (similarity + small genre bonus) ---
    scores = {};   # mid -> float
    reasons = {};  # mid -> str

    for lm in liked {
        # (1) Similar movies via lm.sims dict
        for other_id in lm.sims {
            # find node for other_id
            cand = none;
            for e in root.outgoing() {
                if istype(e.to, Movie) and e.to.mid == other_id {
                    cand = e.to; break;
                }
            }
            if cand == none { continue; }
            if cand.mid in seen or cand.mid == lm.mid { continue; }

            w = lm.sims[other_id];

            # small genre bonus if overlap
            bonus = 0.0;
            for g in lm.genres {
                for cg in cand.genres {
                    if cg == g { bonus = 0.05; break; }
                }
            }

            new_score = w + bonus;

            if (cand.mid not in scores) or (new_score > scores[cand.mid]) {
                scores[cand.mid] = new_score;

                msg = "because you liked '" + lm.title + "' (sim=" + str(w) + ")";
                if bonus > 0.0 { msg = msg + ", +genre"; }
                reasons[cand.mid] = msg;
            }
        }

        # (2) Genre neighbors (weak signal)
        for e in lm.outgoing() {
            if istype(e.to, Genre) {
                gnode = e.to;
                for back in gnode.incoming() {
                    if istype(back.frm, Movie) {
                        cand2 = back.frm;
                        if cand2.mid in seen or cand2.mid == lm.mid { continue; }
                        s = 0.08;
                        if (cand2.mid not in scores) or (s > scores[cand2.mid]) {
                            scores[cand2.mid] = s;
                            reasons[cand2.mid] = "shares genre '" + gnode.name + "' with '" + lm.title + "'";
                        }
                    }
                }
            }
        }
    }

    # --- Build ranked list: [mid, title, score] ---
    ranked = [];
    for mid in scores {
        sc = scores[mid];
        title = "";
        for e in root.outgoing() {
            if istype(e.to, Movie) and e.to.mid == mid { title = e.to.title; break; }
        }
        # store as a 3-item tuple/array: [mid, title, sc]
        ranked.append([mid, title, sc]);
    }

    # --- Manual selection sort by score descending (ranked[*][2]) ---
    n = len(ranked);
    i = 0;
    while i < n {
        max_idx = i;
        j = i + 1;
        while j < n {
            if ranked[j][2] > ranked[max_idx][2] {
                max_idx = j;
            }
            j = j + 1;
        }
        if max_idx != i {
            tmp = ranked[i];
            ranked[i] = ranked[max_idx];
            ranked[max_idx] = tmp;
        }
        i = i + 1;
    }

    # --- Take Top-K ---
    k = self.topk;
    if k > n { k = n; }

    print("\nTop " + str(k) + " recommendations for " + user.name + ":");
    idx = 1;
    t = 0;
    while t < k {
        mid = ranked[t][0];
        title = ranked[t][1];
        sc = ranked[t][2];
        explain = "based on your profile";
        if mid in reasons { explain = reasons[mid]; }

        print(str(idx) + ". " + title + "  (score=" + str(sc) + ") — " + explain);
        idx = idx + 1;
        t = t + 1;
    }

    disengage;
}
