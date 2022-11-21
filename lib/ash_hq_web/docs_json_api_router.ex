defmodule AshHqWeb.DocsJsonApiRouter do
  use AshJsonApi.Api.Router, api: AshHq.Docs, registry: AshHq.Docs.Registry

  get "/swaggerui",
    to: OpenApiSpex.Plug.SwaggerUI,
    init_opts: [
      path: "/json_api/openapi",
      title: "AshHQ JSON-API - Swagger UI",
      default_model_expand_depth: 4
    ]

  get "/redoc",
    to: Redoc.Plug.RedocUI,
    init_opts: [spec_url: "/json_api/openapi"]
end
