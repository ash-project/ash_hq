# defmodule AshHq.Docs.Search.Steps.RunSearch do
#   use Ash.Flow.Step
#   import Ecto.Query, only: [from: 2]
#   require Ecto.Query
#   require Ash.Query

#   @resources AshHq.Docs.Registry
#              |> Ash.Registry.entries()
#              |> Enum.filter(&(AshHq.Docs.Extensions.Search in Ash.Resource.Info.extensions(&1)))

#   def run(input, _opts, _context) do
#     @resources
#     |> Enum.reduce(nil, fn resource, query ->
#       {:ok, next_query} =
#         resource
#         |> Ash.Query.for_read(:search, %{
#           library_versions: input[:library_versions],
#           query: input[:query]
#         })
#         |> Ash.Query.select([:id])
#         |> Ash.Query.data_layer_query()

#       next_query =
#         from row in next_query,
#           select_merge: %{__metadata__: %{resource: ^to_string(resource)}}

#       if query do
#         Ecto.Query.union_all(query, ^next_query)
#       else
#         next_query
#       end
#     end)
#     |> then(fn query ->
#       query =
#         from row in query,
#           order_by: [
#             fragment(
#               "ts_rank(setweight(to_tsvector(?), 'A') || setweight(to_tsvector(?), 'D'), plainto_tsquery(?))",
#               field(row, ^name_attribute),
#               field(row, ^doc_attribute),
#               ^input[:query]
#             )
#           ],
#           limit: 20

#       ids = AshHq.Repo.all(query)

#       data =
#         ids
#         |> Enum.group_by(& &1.__metadata__.resource, & &1)
#         |> Enum.reduce(%{}, fn {resource, id_data}, results ->
#           resource = Module.concat([resource])
#           primary_read = Ash.Resource.Info.primary_action!(resource, :read).name
#           to_load = AshHq.Docs.Extensions.Search.load_for_search(resource)
#           ids = Enum.map(id_data, & &1.id)

#           resource
#           |> Ash.Query.filter(id in ^ids)
#           |> Ash.Query.load(
#             search_headline: %{query: input[:query]},
#             name_matches: %{query: input[:query], similarity: 0.7},
#             match_rank: %{query: input[:query]}
#           )
#           |> Ash.Query.load(to_load)
#           |> Ash.Query.for_read(primary_read)
#           |> AshHq.Docs.read!()
#           |> Enum.reduce(results, fn item, results ->
#             Map.put(results, item.id, item)
#           end)
#         end)

#       {:ok,
#        Enum.map(ids, fn %{id: id} ->
#          Map.fetch!(data, id)
#        end)}
#     end)
#   end

#   # read :options, AshHq.Docs.Option, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :dsls, AshHq.Docs.Dsl, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :guides, AshHq.Docs.Guide, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :library_versions, AshHq.Docs.LibraryVersion, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :extensions, AshHq.Docs.Extension, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :functions, AshHq.Docs.Function, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end

#   # read :modules, AshHq.Docs.Module, :search do
#   #   input %{
#   #     library_versions: arg(:library_versions),
#   #     query: arg(:query)
#   #   }
#   # end
# end
