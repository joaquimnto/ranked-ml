# %%
import argparse

import pandas as pd
import sqlalchemy

parser = argparse.ArgumentParser()
parser.add_argument("--date", "-d", default="max")
args = parser.parse_args()

print("Importando modelo...")
model = pd.read_pickle("../../../models/modelo_subscription.pkl")
print("Ok!")

print("importanto query...")
with open("../etl/query.sql", "r") as open_file:
    query = open_file.read()
print("Ok!")
# %%
print("Obtendo data para escoragem...")
con = sqlalchemy.create_engine("sqlite:///../../../data/gc.db")

if args.date == "max":
    date = pd.read_sql("SELECT MAX(dtRef) AS date FROM tb_book_players", con)["date"][0]
else:
    date = args.date
print("Ok!")

print("Importanto dados...")
query = query.format(date=date)
df = pd.read_sql(query, con)
print("Ok!")


print("Realizando o score dos dados...")
df_score = df[["dtRef", "idPlayer"]].copy()
df_score["score"] = model["model"].predict_proba( df[model["features"]] )[:,1]
df_score["descModel"] = "Model Subscription"
df_score.head()
print("Ok!")

print("Enviando dados para o DB...")
con.execute(f"DELETE FROM tb_model_score WHERE dtRef='{date}'")
df_score.to_sql("tb_model_score", con, if_exists="append", index=False)
print("Ok!")