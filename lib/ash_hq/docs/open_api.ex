defmodule AshHq.Docs.OpenApi do
  alias OpenApiSpex.{Info, OpenApi, Server, SecurityScheme}

  def spec do
    %OpenApi{
      info: %Info{
        title: "AshHQ Docs API",
        version: "1.1"
      },
      servers: [
        Server.from_endpoint(AshHqWeb.Endpoint)
      ],
      paths: AshJsonApi.OpenApi.paths(AshHq.Docs),
      tags: AshJsonApi.OpenApi.tags(AshHq.Docs),
      components: %{
        responses: AshJsonApi.OpenApi.responses(),
        schemas: AshJsonApi.OpenApi.schemas(AshHq.Docs),
        securitySchemes: %{
          "api_key" => %SecurityScheme{
            type: "apiKey",
            description: "API Key provided in the Authorization header",
            name: "api_key",
            in: "header"
          }
        }
      },
      security: [
        %{
          # API Key security applies to all operations
          "api_key" => []
        }
      ]
    }
  end
end
