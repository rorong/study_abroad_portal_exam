Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: "http://localhost:9200",
  user: 'elastic',
  password: '12345678',
  transport_options: { ssl: { verify: false } },
  log: true
)