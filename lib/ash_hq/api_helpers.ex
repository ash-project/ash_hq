defmodule AshHq.ApiHelpers do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      def stream(query, opts \\ []) do
        api = __MODULE__
        query = Ash.Query.to_query(query)

        query =
          if query.action do
            query
          else
            Ash.Query.for_read(
              query,
              Ash.Resource.Info.primary_action!(query.resource, :read).name
            )
          end

        Stream.resource(
          fn -> nil end,
          fn
            false ->
              {:halt, nil}

            after_keyset ->
              if is_nil(query.action.pagination) || !query.action.pagination.keyset? do
                raise "Keyset pagination must be enabled"
              end

              keyset = if after_keyset != nil, do: [after: after_keyset], else: []
              page_opts = Keyword.merge([limit: 100], keyset)

              opts =
                [
                  page: page_opts
                ]
                |> Keyword.merge(opts)

              case api.read!(query, opts) do
                %{more?: true, results: results} ->
                  {results, List.last(results).__metadata__.keyset}

                %{results: results} ->
                  {results, false}
              end
          end,
          & &1
        )
      end
    end
  end
end
