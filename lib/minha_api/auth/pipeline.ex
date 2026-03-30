defmodule MinhaApi.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :minha_api,
    module: MinhaApi.Auth.Guardian,
    error_handler: MinhaApi.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end