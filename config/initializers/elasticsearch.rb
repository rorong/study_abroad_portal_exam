# Elasticsearch::Model.client = Elasticsearch::Client.new(
#   host: "http://localhost:9200",
#   user: 'elastic',
#   password: '12345678',
#   transport_options: { ssl: { verify: false } },
#   log: true
# )


Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: 'https://my-deployment-6ed54b.es.asia-south1.gcp.elastic-cloud.com',
  user: 'elastic',
  password: 'RWP86UZLe9UhqQigdZjUODb9',  # 🔐 Copy from Elastic Cloud deployment page
  transport_options: {
    request: { timeout: 120 },
    ssl: { verify: true }
  },
  log: true
)


