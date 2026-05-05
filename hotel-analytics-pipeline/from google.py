from google.cloud import bigquery

PROJECT_ID = "analytics-enginner"

client = bigquery.Client(project=PROJECT_ID)

datasets = list(client.list_datasets())

print("Ligação com sucesso ao BigQuery.")
print("Datasets encontrados:")

for dataset in datasets:
    print("-", dataset.dataset_id)