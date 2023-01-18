# defmodule AshHq.Docs.SimplePostgresCache do
#   @moduledoc """
#   Simple experimental key/value based cache on top of the postgres data layer.

#   Will be problematic if used with queries that reference things like
#   the current time.
#   """
#   @behaviour Ash.DataLayer

#   Code.ensure_compiled!(AshPostgres.DataLayer)

#   for {function, arity} <- Ash.DataLayer.behaviour_info(:callbacks) do
#     arguments = Macro.generate_unique_arguments(arity, __MODULE__)

#     case {function, arity} do
#       {:run_query, 2} ->
#         def run_query(query, _resource) do
#           if query.__ash_bindings__.context[:data_layer][:cache?] do
#             case AshHq.Docs.Cache.get(query) do
#               nil ->

#             end
#           else

#           end
#         end

#       _ ->
#         if function_exported?(AshPostgres.DataLayer, function, arity) do
#           defdelegate unquote(function)(unquote_splicing(arguments)), to: AshPostgres.DataLayer
#         end
#     end
#   end
# end
