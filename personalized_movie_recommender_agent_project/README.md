#  Explainable Movie Recommender (Jac + ML)

**TL;DR:** A tiny, teachable movie recommender you can read in one sitting.  
We use **Jac** (graph + walkers) + a **TF-IDF similarity precompute**.  
Then we recommend movies with explanations like: _“because you liked **Interstellar**.”_

---

## Why this project?

- **Explainable**: Every rec comes with a human reason.
- **Simple**: One Python precompute + one Jac agent.
- **Teachable**: Perfect for demos, classes, or your YouTube channel.
- **Portable**: Uses in-memory indexes instead of engine-specific graph APIs.

---

## Architecture at a glance

+-------------------+ +--------------------+
| movies.json | | sims.json |
| (id, title, ... )| | top-K similarities|
+---------+---------+ +----------+---------+
| |
| (TF-IDF + cosine, Python) |
+--------------+---------------+
|
+--------v--------+
| Reco Walker |
| (Jac) |
+---+---------+---+
| |
+---------v-+ +---v-----------+
| Movie nodes| | Index maps |
| Genre nodes| | mnodes/users |
| User nodes | | likes/gindex |
+------------+ +---------------+



---

##  What’s inside

- **Graph schema (Jac)**
  - `User` nodes (`user_id`, `name`)
  - `Movie` nodes (`mid`, `title`, `genres`, `sims`)
  - `Genre` nodes (`name`)
- **Precompute (Python)**
  - TF-IDF + cosine over titles/genres/plots → `sims.json` (top-K similar movies)
- **Walker (agent): `Reco`**
  - Loads JSON, builds nodes, stores handy **indexes**:
    - `mnodes: movie_id → Movie`
    - `users: user_id → User`
    - `likes: user_id → [movie_id,…]`
    - `gindex: genre → [movie_id,…]`
  - Scores candidates: **similarity + tiny genre bonus**
  - Prints **Top-K** with **reasons**

---

##  Project layout

personalized_movie_recommender_agent_project/
├─ recommender.jac # schema + walker declarations + entry
├─ recommender.impl.jac # implementation: start() + recommend()
├─ data/
│ ├─ movies.json # tiny dataset (id, title, genres, plot)
│ ├─ sims.json # precomputed similarities (built by script)
│ └─ likes.json # (optional) persisted user likes
├─ scripts/
│ └─ build_sims.py # TF-IDF + cosine → writes sims.json
└─ README.md




---

## Data formats

**`data/movies.json`**
```json
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
  ]
]
```

data/sims.json

```json
{
  "m2": [["m10", 0.74], ["m7", 0.63], ["m3", 0.22]],
  "m3": [["m8", 0.68], ["m2", 0.22]]
}
```

Each ["other_id", score] comes from TF-IDF + cosine on title + genres + plot.

---

## ⚙️ Setup

Create & activate your env (example):

```bash
python3 -m venv .envjac
source .envjac/bin/activate
pip install jaclang scikit-learn

```

Build similarities:

```bash
python scripts/build_sims.py
# writes: data/sims.json

```

Run the recommender:

```bash
jac recommender.jac

```

Example output:

```text
Top 5 recommendations for Kira:
1. Inception  (score=0.78) — because you liked 'Interstellar' (sim=0.73, +genre)
2. Tenet      (score=0.61) — shares genre 'Sci-Fi' with 'Interstellar'
...

```


---
## Usage cheatsheet

Change user
In with entry { root spawn Reco("u1", 5); }, swap "u1" with your user id.

Change K (how many recommendations)
Second arg to Reco(...).

Add movies
Append to data/movies.json, then re-run the precompute script.

Tune similarity
Edit scripts/build_sims.py (ngrams, min_df, K).

Adjust genre bias
Change the +0.05 bonus in recommender.impl.jac.
---

## Design notes

We intentionally use index maps (not neighbors() / .outgoing()) to keep the code portable across Jac builds.

The graph is still visible for teaching, while the logic stays simple and fast.

Explanations are generated at scoring time—no magic, no black box.

 Common pitfalls (and quick fixes)

None vs none → use None (capital N)

Missing helper → define _read_json() or inline json.load()

Movie.__init__() unexpected keyword 'genres' → ensure node Movie declares genres: list = [] and sims: dict = {}

F-strings with :.2f / lambda → prefer str() and manual sort (parser-friendly)

---

## Roadmap / Extensions

 add_like(uid, mid) walker ability + re-run recommend()

 Persist likes to data/likes.json

 Diversity cap (e.g., max 2 per genre in final list)

 Swap TF-IDF with embeddings (sentence-transformers) → smarter sims.json

 Serve via jac serve → HTTP endpoint

---
## License

ChatGPT & Kira.
