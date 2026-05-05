import os
from datetime import datetime, timezone

import pandas as pd
import kagglehub
from google.cloud import bigquery


PROJECT_ID = "analytics-enginner"
DATASET_ID = "raw"
TABLE_ID = "hotel_bookings"

TABLE_FULL_ID = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"


def find_csv_file(folder_path: str) -> str:
    for file_name in os.listdir(folder_path):
        if file_name.endswith(".csv"):
            return os.path.join(folder_path, file_name)
    raise FileNotFoundError("Não foi encontrado nenhum ficheiro CSV na pasta do dataset.")


def main():
    print("A descarregar dataset do Kaggle...")
    path = kagglehub.dataset_download("jessemostipak/hotel-booking-demand")
    print(f"Dataset descarregado para: {path}")

    csv_path = find_csv_file(path)
    print(f"CSV encontrado: {csv_path}")

    print("A ler CSV com pandas...")
    df = pd.read_csv(csv_path)

    print(f"Shape original: {df.shape}")

    df.columns = [col.strip().lower() for col in df.columns]

    if "children" in df.columns:
        df["children"] = df["children"].fillna(0)

    df["ingestion_ts"] = datetime.now(timezone.utc)

    client = bigquery.Client(project=PROJECT_ID)

    dataset_ref = bigquery.Dataset(f"{PROJECT_ID}.{DATASET_ID}")
    dataset_ref.location = "EU"
    client.create_dataset(dataset_ref, exists_ok=True)

    job_config = bigquery.LoadJobConfig(
        write_disposition="WRITE_TRUNCATE",
        autodetect=True
    )

    print(f"A carregar dados para {TABLE_FULL_ID}...")
    job = client.load_table_from_dataframe(
        df,
        TABLE_FULL_ID,
        job_config=job_config
    )

    job.result()

    table = client.get_table(TABLE_FULL_ID)

    print("Carga concluída com sucesso.")
    print(f"Tabela: {TABLE_FULL_ID}")
    print(f"Número de linhas: {table.num_rows}")
    print(f"Número de colunas: {len(table.schema)}")


if __name__ == "__main__":
    main()