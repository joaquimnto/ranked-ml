# %%

from concurrent.futures import process
import sqlalchemy
def import_query(path):
    with open(path, "r") as open_file:
        query = open_file.read()
    return query

def process_date(query, date, engine):
    delete = f"DELETE FROM tb_book_players WHERE dtRef = '{date}'"
    engine.execute(delete)
    query = query.format(date = date)
    engine.execute(query)
# %%

engine = sqlalchemy.create_engine("sqlite:///../data/gc.db")
query = import_query("query.etl")
date = "2022-01-01"
process_date(query, date, engine)