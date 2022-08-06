defmodule AshHq.Accounts.User.Preparations.DecodeToken do
  use Ash.Resource.Preparation

  alias Ash.Error.Query.InvalidArgument

  def prepare(query, _opts, _) do
    case Ash.Query.get_argument(query, :token) do
      nil ->
        query

      token ->
        case Base.url_decode64(token, padding: false) do
          {:ok, decoded} ->
            Ash.Query.set_argument(
              query,
              :token,
              decoded
            )

          :error ->
            Ash.Query.add_error(
              query,
              InvalidArgument.exception(field: :token, message: "could not be decoded")
            )
        end
    end
  end
end
