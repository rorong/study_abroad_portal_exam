Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: "http://localhost:9200",
  user: 'elastic',
  password: '9zKxjPTvEqGlZb1n+h=E',
  transport_options: { ssl: { verify: false } },
  log: true
)