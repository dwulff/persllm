from sentence_transformers import SentenceTransformer, InputExample, losses, evaluation
from torch.utils.data import DataLoader
import pandas as pd
import torch

# GET MODEL

model = SentenceTransformer("all-mpnet-base-v2")

# HANDLE dATA ---- 


corrs = pd.read_csv("1_data/correlations.csv")

data = corrs

texts_i = data["item_i"].values
texts_j = data["item_j"].values
cor = data["abs_cor"].values


train_examples = [InputExample(texts=[x, y], label=z) for x,y,z in zip(texts_i, texts_j, cor)]

train_dataloader = DataLoader(train_examples, shuffle=True, batch_size=len(train_examples))
train_loss = losses.CosineSimilarityLoss(model)

# Tune the model
model.fit(train_objectives=[(train_dataloader, train_loss)], epochs=3, warmup_steps=100)








sentences1 = [
    "This list contains the first column",
    "With your sentences",
    "You want your model to evaluate on",
]
sentences2 = [
    "Sentences contains the other column",
    "The evaluator matches sentences1[i] with sentences2[i]",
    "Compute the cosine similarity and compares it to scores[i]",
]
scores = [0.3, 0.6, 0.2]

evaluator = evaluation.EmbeddingSimilarityEvaluator(sentences1, sentences2, scores)



model.fit(
    train_objectives=[(train_dataloader, train_loss)],
    evaluator=evaluator,
    epochs=num_epochs,
    evaluation_steps=1000,
    warmup_steps=warmup_steps,
    output_path=model_save_path,
)


