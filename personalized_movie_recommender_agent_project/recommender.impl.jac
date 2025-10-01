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


import json;
import os;

# tiny file loader used by Reco.start
def _read_json(path: str) -> dict {
    f = open(path, "r");
    try { return json.load(f); }
    finally { f.close(); }
}


impl Reco.start {
    cwd = os.getcwd();
    data_dir = os.path.join(cwd, "data");
    movies = _read_json(os.path.join(data_dir, "movies.json"));
    sims   = _read_json(os.path.join(data_dir, "sims.json"));

    gnodes = {};
    mnodes = {};
    gindex = {};   # NEW: genre -> [mid, ...]

    # Genres + Movies
    for m in movies {
        # genre nodes (optional, keep if you like)
        for g in m["genres"] {
            if g not in gnodes {
                gnodes[g] = Genre(name=g);
                root ++> gnodes[g];
            }
        }

        mv = Movie(mid=m["id"], title=m["title"], genres=m["genres"], sims={});
        mnodes[m["id"]] = mv;
        root ++> mv;

        # build genre index (no graph API needed)
        for g in m["genres"] {
            if g not in gindex { gindex[g] = []; }
            gindex[g].append(m["id"]);
            # optional plain edge (not used by the recommender logic)
            mv ++> gnodes[g];
        }
    }

    # Similarities (store in each movie’s sims dict)
    for m in movies {
        mid = m["id"];
        if (mid in mnodes) and (mid in sims) {
            src = mnodes[mid];
            lst = sims[mid];   # list of [other_id, score]
            for pair in lst {
                other_id = pair[0];
                score    = pair[1];
                if other_id in mnodes {
                    src.sims[other_id] = score;
                }
            }
        }
    }

    # Demo user + likes (the recommender will read from this map)
    u = User(user_id="u1", name="Kira");
    root ++> u;

    users = {};
    users[u.user_id] = u;

    likes = {};
    likes["u1"] = ["m2", "m3"];  # Interstellar, The Dark Knight (adjust to your data)

    # Stash maps on the walker
    self.mnodes = mnodes;
    self.users  = users;
    self.likes  = likes;
    self.gindex = gindex;

    # (optional) sanity print:
    # print("Movies=" + str(len(mnodes)) + ", Genres=" + str(len(gindex)) + ", Users=" + str(len(users)));

    self.recommend();
}



impl Reco.recommend {
    # Find user via map
    user = None;
    if self.users and (self.target_user in self.users) {
        user = self.users[self.target_user];
    }
    if user == None {
        print("User " + self.target_user + " not found.");
        disengage;
    }

    # Likes via map (movie IDs)
    if (self.likes == None) or (self.target_user not in self.likes) {
        print("User has no likes yet. Seed their profile first.");
        disengage;
    }
    liked_ids = self.likes[self.target_user];

    # Build liked movie nodes + seen set
    liked = [];
    seen  = {};
    for mid in liked_ids {
        if (self.mnodes != None) and (mid in self.mnodes) {
            liked.append(self.mnodes[mid]);
            seen[mid] = True;
        }
    }
    if len(liked) == 0 {
        print("No valid liked movies found for user " + self.target_user + ".");
        disengage;
    }

    # Score candidates
    scores = {};   # mid -> float
    reasons = {};  # mid -> str

    for lm in liked {
        # (1) Similar movies from precomputed sims
        for other_id in lm.sims {
            if (other_id in seen) or (other_id == lm.mid) { continue; }
            if (self.mnodes == None) or (other_id not in self.mnodes) { continue; }

            cand = self.mnodes[other_id];
            w = lm.sims[other_id];

            # small genre bonus if any overlap
            bonus = 0.0;
            for g in lm.genres {
                for cg in cand.genres {
                    if cg == g { bonus = 0.05; break; }
                }
            }

            new_score = w + bonus;
            if (other_id not in scores) or (new_score > scores[other_id]) {
                scores[other_id] = new_score;

                msg = "because you liked '" + lm.title + "' (sim=" + str(w) + ")";
                if bonus > 0.0 { msg = msg + ", +genre"; }
                reasons[other_id] = msg;
            }
        }

        # (2) Genre neighbors (weak signal) using the genre index
        for g in lm.genres {
            if (self.gindex != None) and (g in self.gindex) {
                cands = self.gindex[g];
                for c_mid in cands {
                    if (c_mid in seen) or (c_mid == lm.mid) { continue; }
                    if (self.mnodes == None) or (c_mid not in self.mnodes) { continue; }

                    s = 0.08;  # weak bonus
                    if (c_mid not in scores) or (s > scores[c_mid]) {
                        scores[c_mid] = s;
                        reasons[c_mid] = "shares genre '" + g + "' with '" + lm.title + "'";
                    }
                }
            }
        }
    }

    # Rank
    ranked = [];
    for mid in scores {
        sc = scores[mid];
        title = "";
        if (self.mnodes != None) and (mid in self.mnodes) { title = self.mnodes[mid].title; }
        ranked.append([mid, title, sc]);
    }

    # Selection sort (desc on score)
    n = len(ranked);
    i = 0;
    while i < n {
        max_idx = i;
        j = i + 1;
        while j < n {
            if ranked[j][2] > ranked[max_idx][2] { max_idx = j; }
            j = j + 1;
        }
        if max_idx != i {
            tmp = ranked[i];
            ranked[i] = ranked[max_idx];
            ranked[max_idx] = tmp;
        }
        i = i + 1;
    }

    # Top-K
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

