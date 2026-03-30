# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :minha_api,
  ecto_repos: [MinhaApi.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :minha_api, MinhaApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MinhaApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MinhaApi.PubSub,
  live_view: [signing_salt: "TxzIH53F"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian JWT config
config :minha_api, MinhaApi.Auth.Guardian,
  issuer: "minha_api",
  secret_key: "troque_por_uma_chave_secreta_longa_aqui_32chars"

config :phoenix_swagger, json_library: Jason

config :minha_api, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: MinhaApiWeb.Router]
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"