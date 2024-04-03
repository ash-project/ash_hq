defmodule AshHq.Accounts.User.Policies do
  @moduledoc "Policies for the user resource"
  use Spark.Dsl.Fragment, of: Ash.Resource, authorizers: [Ash.Policy.Authorizer]

  policies do
    policy action(:read) do
      authorize_if(expr(id == ^actor(:id)))
    end
  end
end
