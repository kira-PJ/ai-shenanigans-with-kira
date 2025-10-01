'''
This Python script:

Loads a dataset of movies (with title, genres, and plot text).

Uses TF-IDF (Term Frequency – Inverse Document Frequency) to turn those text descriptions into numeric vectors.

Computes cosine similarity between every pair of movies.

Keeps the top K most similar movies for each one.

Saves those similarities to a JSON file for later use (like in a Jac recommender agent).
'''

import json, os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# --- Step 1: file paths for input/output ---
# DATA = movies dataset (JSON with id, title, genres, plot)
# OUT  = where to save the similarity results
DATA = os.path.join(os.path.dirname(__file__), "..", "data", "movies.json")
OUT  = os.path.join(os.path.dirname(__file__), "..", "data", "sims.json")

# --- Step 2: load the movies ---
with open(DATA, "r") as f:
    movies = json.load(f)

# --- Step 3: build documents for TF-IDF ---
docs = []  # one text string per movie
ids  = []  # parallel list of movie ids

for m in movies:
    ids.append(m["id"])                     # store id (e.g. "m1")
    g = " ".join(m["genres"])               # flatten genres into text
    # combine title + genres + plot into a single description
    docs.append(f"{m['title']} {g} {m['plot']}")

# --- Step 4: convert text to TF-IDF vectors ---
# TF-IDF captures important words (weighted by how unique they are).
# ngram_range=(1,2) = use single words and 2-word phrases
tfidf = TfidfVectorizer(ngram_range=(1,2), min_df=1)
X = tfidf.fit_transform(docs)    # shape: [num_movies, num_terms]

# --- Step 5: compute cosine similarity matrix ---
# Cosine similarity = how close two movies are based on text
S = cosine_similarity(X)   # NxN matrix, each cell in [0,1]

# --- Step 6: pick top-K similar movies for each ---
K = 5
sims = {}  # dict: movie_id -> list of (other_id, similarity)
for i, mid in enumerate(ids):
    # (index, similarity) pairs for this row
    row = list(enumerate(S[i]))
    # map indices back to movie ids, skip self (j != i)
    row = [(ids[j], float(s)) for j, s in row if j != i]
    # sort descending by similarity
    row.sort(key=lambda t: t[1], reverse=True)
    # keep top K
    sims[mid] = row[:K]

# --- Step 7: save to JSON ---
with open(OUT, "w") as f:
    json.dump(sims, f, indent=2)

print(f"Wrote {OUT}")
