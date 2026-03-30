defmodule MinhaApiWeb.Router do
  use MinhaApiWeb, :router
  use PhoenixSwagger

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug MinhaApi.Auth.Pipeline
  end

  # Rotas públicas
  scope "/api", MinhaApiWeb do
    pipe_through :api

    post "/login", AuthController, :login
    post "/users", UserController, :create

    get "/obras", ObraController, :index
    get "/obras/:id", ObraController, :show
    get "/etapas", EtapaController, :index
    get "/etapas/:id", EtapaController, :show
    get "/materiais", MaterialController, :index
    get "/materiais/:id", MaterialController, :show
  end

  # Rotas protegidas (exigem JWT)
  scope "/api", MinhaApiWeb do
    pipe_through [:api, :auth]

    resources "/obras", ObraController, only: [:create, :update, :delete]
    resources "/etapas", EtapaController, only: [:create, :update, :delete]
    resources "/materiais", MaterialController, only: [:create, :update, :delete]
  end

  # Swagger UI
  scope "/api/api-docs" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :minha_api,
      swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "API de Gestão de Obras"
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          in: "header"
        }
      }
    }
  end
end