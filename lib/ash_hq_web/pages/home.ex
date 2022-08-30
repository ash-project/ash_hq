defmodule AshHqWeb.Pages.Home do
  @moduledoc "The home page"

  use Surface.LiveComponent

  alias AshHqWeb.Components.{CalloutText, CodeExample, SearchBar}
  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, ErrorTag, TextInput, Submit}
  import AshHqWeb.Components.CodeExample, only: [to_code: 1]

  data signed_up, :boolean, default: false
  data email_form, :any

  def render(assigns) do
    ~F"""
    <div>
      <div class="w-full bg-orange-600 text-center py-2 text-lg font-semibold">
        This site is still under construction and is live for preview purposes only.
      </div>
      <div class="my-2 dark:bg-primary-black dark:bg-dark-grid bg-light-grid flex flex-col items-center pt-36">
        <div class="text-5xl px-12 font-bold max-w-5xl mx-auto mt-2 text-center">
          Build <CalloutText>powerful</CalloutText> and <CalloutText>composable</CalloutText> applications with a <CalloutText>flexible</CalloutText> tool-chain.
        </div>
        <div class="text-xl font-light text-gray-700 dark:text-gray-400 max-w-4xl mx-auto mt-4 text-center">
          A declarative foundation for ambitious applications. Model your domain, derive the rest.
        </div>
        <div class="flex flex-row items-center mt-16 space-x-4">
          <div class="flex items-center h-12 px-4 rounded-lg bg-orange-500 dark:text-white dark:hover:text-gray-200 hover:text-white">
              <a
              href="/docs/guides/ash/latest/tutorials/get-started.md"
              target="_blank">Get Started</a>
         </div>
          <SearchBar />
        </div>

        <div class="flex flex-row items-center mt-16 space-x-4">
          {#if @signed_up}
            Thank you for joining our mailing list!
          {#else}
            <Form for={@email_form} change="validate_email_form" submit="submit_email_form">
              <Field name={:email}>
                <TextInput class="text-black" opts={placeholder: "Join our mailing list for (tastefully paced) updates!"} />
              </Field>
              <Submit>Join</Submit>
            </Form>
          {/if}
        </div>

      <div id="testimonials" class="flex flex-col space-y-4">
        <div class="min-w-fit max-w-min bg-gray-100 rounded-xl p-8 md:p-0 dark:bg-gray-800 bg-white drop-shadow-md">
          <div class="pt-6 md:p-8 text-center md:text-left space-y-4">

              <p class="text-lg font-light text-gray-700 dark:text-gray-100">
                "Through its declarative extensibility, Ash delivers more than you'd expect: Powerful APIs with filtering/sorting/pagination/calculations/aggregations, pub/sub, authorization, rich introspection, GraphQL... It's what empowers this solo developer to build an ambitious ERP!"
              </p>

            <p class="font-bold">
              <div class="text-orange-500 dark:text-orange-400">
                Frank Dugan III
              </div>
              <div class="text-gray-700 dark:text-gray-300">
                System Specialist, SunnyCor Inc.
              </div>
            </p>
          </div>
        </div>

        <div class="min-w-fit max-w-min bg-gray-100 rounded-xl p-8 md:p-0 dark:bg-gray-800 bg-white drop-shadow-md">
          <div class="pt-6 md:p-8 text-center md:text-left space-y-4">

              <p class="text-lg font-light text-gray-700 dark:text-gray-100">
                "What stood out to me was how incredibly easy Ash made it for me to go from a proof of concept, to a working prototype using ETS, to a live app using Postgres."
              </p>

            <p class="font-bold">
              <div class="text-orange-500 dark:text-orange-400">
                Brett Kolodny
              </div>
              <div class="text-gray-700 dark:text-gray-300">
                Full stack engineer, MEW
              </div>
            </p>
          </div>
        </div>

        <div class="min-w-fit max-w-min bg-gray-100 rounded-xl p-8 md:p-0 dark:bg-gray-800 bg-white drop-shadow-md">
          <div class="pt-6 md:p-8 text-center md:text-left space-y-4">

              <p class="text-lg font-light text-gray-700 dark:text-gray-100">
                "Ash is such powerful idea and it gives Alembic such a massive competitive advantage that I’d be really stupid to tell anyone about it."
              </p>

            <p class="font-bold">
              <div class="text-orange-500 dark:text-orange-400">
                Josh Price
              </div>
              <div class="text-gray-700 dark:text-gray-300">
                Technical Director, Alembic
              </div>
            </p>
          </div>
        </div>
        </div>


        <div class="flex flex-col items-center mt-16 space-y-4">
          {#if @signed_up}
            Thank you for joining our mailing list!
          {#else}
            <p class="text-2xl font-medium text-gray-700 dark:text-gray-200 max-w-4xl mx-auto mt-4 text-center">Join our mailing list for (tastefully paced) updates!</p>
            <Form for={@email_form} change="validate_email_form" submit="submit_email_form" class="flex flex-row space-x-4">
              <Field name={:email}>
                <TextInput class="w-96 button border border-gray-400 bg-gray-200 dark:border-gray-700 rounded-lg dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600" opts={placeholder: "user@email.com"} />
              </Field>
              <Submit class="flex items-center px-4 rounded-lg bg-orange-500 dark:text-white dark:hover:text-gray-200 hover:text-white">Join</Submit>
            </Form>
          {/if}
        </div>

        <div class="pt-6 pb-6 w-full mt-36 bg-gray-800 bg-opacity-80">
          <div class="text-5xl px-12 font-bold max-w-5xl mx-auto mt-2 text-center">
            Why do we keep reinventing the wheel?
          </div>
        </div>

        <div class="pt-6 pb-6 w-full hidden sm:block mt-36">
          <h1>Stop painting yourself into corners</h1>
        </div>

        <div class="pt-6 pb-6 w-full hidden sm:block mt-36">
          <h1>No Lock In</h1>
        </div>

        <div class="pt-6 pb-6 w-full hidden sm:block mt-36">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">
            <CodeExample
              id="define-a-resource"
              class="grow min-w-fit max-w-[1000px]"
              code={post_example()}
              title="Define a resource"
            />
            <div class="flex flex-col space-y-8">
              <CodeExample
                class="w-auto"
                collapsible
                id="use-it-programmatically"
                code={changeset_example()}
                title="Use it programmatically"
              />
              <CodeExample
                class="w-auto"
                collapsible
                id="graphql-interface"
                code={graphql_example()}
                title="Add a GraphQL interface"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="authorization-policies"
                code={policies_example()}
                title="Add authorization policies"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="aggregates"
                code={aggregate_example()}
                title="Define aggregates and calculations"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="pubsub"
                code={notifier_example()}
                title="Broadcast changes over Phoenix PubSub"
              />
              <CodeExample
                class="w-auto"
                collapsible
                start_collapsed
                id="live-view"
                code={live_view_example()}
                title="Use it with Phoenix LiveView"
              />
            </div>
          </div>
        </div>

        <div class="flex flex-col items-center mt-16 space-y-4 mb-10">
          {#if @signed_up}
            Thank you for joining our mailing list!
          {#else}
            <p class="text-2xl font-medium text-gray-700 dark:text-gray-200 max-w-4xl mx-auto mt-4 text-center">Join our mailing list for (tastefully paced) updates!</p>
            <Form for={@email_form} change="validate_email_form" submit="submit_email_form" class="flex flex-row space-x-4">
              <Field name={:email}>
                <TextInput class="w-96 button border border-gray-400 bg-gray-200 dark:border-gray-700 rounded-lg dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600" opts={placeholder: "user@email.com"} />
              </Field>
              <Submit class="flex items-center px-4 rounded-lg bg-orange-500 dark:text-white dark:hover:text-gray-200 hover:text-white">Join</Submit>
            </Form>
          {/if}
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     assign(
       socket,
       signed_up: false,
       email_form:
         AshPhoenix.Form.for_create(AshHq.MailingList.Email, :create,
           api: AshHq.MailingList,
           upsert?: true,
           upsert_identity: :unique_email
         )
     )}
  end

  def handle_event("validate_email_form", %{"form" => form}, socket) do
    {:noreply,
     assign(socket, email_form: AshPhoenix.Form.validate(socket.assigns.email_form, form))}
  end

  def handle_event("submit_email_form", _, socket) do
    case AshPhoenix.Form.submit(socket.assigns.email_form) do
      {:ok, _} ->
        {:noreply, assign(socket, :signed_up, true)}

      {:error, form} ->
        {:noreply, assign(socket, email_form: form)}
    end
  end

  @changeset_example """
                     post = Example.Post.create!(%{
                       text: "Declarative programming is fun!"
                     })

                     Example.Post.react!(post, %{type: :like})

                     Example.Post
                     |> Ash.Query.filter(likes > 10)
                     |> Ash.Query.sort(likes: :desc)
                     |> Example.read!()
                     """
                     |> to_code()

  defp changeset_example do
    @changeset_example
  end

  @live_view_example """
                     def mount(_params, _session, socket) do
                       form = AshPhoenix.Form.for_create(Example.Post, :create)

                       {:ok, assign(socket, :form, form}}
                     end

                     def handle_event("validate", %{"form" => input}, socket) do
                       form = AshPhoenix.Form.validate(socket.assigns.form, input)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("submit", _, socket) do
                       case AshPhoenix.Form.submit(socket.assigns.form) do
                         {:ok, post} ->
                           {:ok, redirect_to_post(socket, post)}

                         {:error, form_with_errors} ->
                           {:noreply, assign(socket, :form, form_with_errors)}
                       end
                     end
                     """
                     |> to_code()
  defp live_view_example do
    @live_view_example
  end

  @graphql_example """
                   graphql do
                     type :post

                     queries do
                       get :get_post, :read
                       list :feed, :read
                     end

                     mutations do
                       create :create_post, :create
                       update :react_to_post, :react
                     end
                   end
                   """
                   |> to_code()
  defp graphql_example do
    @graphql_example
  end

  @policies_example """
                    policies do
                      policy action_type(:read) do
                        authorize_if expr(visibility == :everyone)
                        authorize_if relates_to_actor_via([:author, :friends])
                      end
                    end
                    """
                    |> to_code()
  defp policies_example do
    @policies_example
  end

  @notifier_example """
                    pub_sub do
                      module ExampleEndpoint
                      prefix "post"

                      publish_all :create, ["created"]
                      publish :react, ["reaction", :id] event: "reaction"
                    end
                    """
                    |> to_code()
  defp notifier_example do
    @notifier_example
  end

  @aggregate_example """
                     aggregates do
                       count :likes, :reactions do
                         filter expr(type == :like)
                       end

                       count :dislikes, :reactions do
                         filter expr(type == :dislike)
                       end
                     end

                     calculations do
                       calculate :like_ratio, :float do
                         expr(likes / (likes + dislikes))
                       end
                     end
                     """
                     |> to_code()

  defp aggregate_example do
    @aggregate_example
  end

  @post_example """
                defmodule Example.Post do
                  use AshHq.Resource,
                    data_layer: AshPostgres.DataLayer

                  postgres do
                    table "posts"
                    repo Example.Repo
                  end

                  attributes do
                    attribute :text, :string do
                      allow_nil? false
                    end

                    attribute :visibility, :atom do
                      constraints [
                        one_of: [:friends, :everyone]
                      ]
                    end
                  end

                  actions do
                    update :react do
                      argument :type, Example.Types.ReactionType do
                        allow_nil? false
                      end

                      change manage_relationship(
                        :type,
                        :reactions,
                        type: :append
                      )
                    end
                  end

                  relationships do
                    belongs_to :author, Example.User do
                      required? true
                    end

                    has_many :reactions, Example.Reaction
                  end
                end
                """
                |> to_code()

  defp post_example do
    @post_example
  end
end
