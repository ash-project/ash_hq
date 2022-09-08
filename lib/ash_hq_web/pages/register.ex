defmodule AshHqWeb.Pages.Register do
  @moduledoc "Log in page"
  use Surface.LiveComponent

  alias Surface.Components.{Form, LiveRedirect}

  alias Surface.Components.Form.{
    Checkbox,
    ErrorTag,
    Field,
    Label,
    PasswordInput,
    Submit,
    TextInput
  }

  alias AshHqWeb.Router.Helpers, as: Routes

  data register_form, :map

  def render(assigns) do
    ~F"""
    <div class="container flex flex-wrap mx-auto">
      <div class="w-full md:w-2/3 ml-2">
        <Form class="space-y-8" for={@register_form} change="validate_register" submit="register">
          <div class="space-y-8 sm:space-y-5">
            <div>
              <h3 class="text-lg leading-6 font-medium">Register</h3>
              {#if @register_form.submitted_once?}
                <div class="alert alert-danger">
                  <p>Oops, something went wrong! Please check the errors below.</p>
                </div>
              {/if}
            </div>

            <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                <Field name={:email}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Email</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <TextInput
                        class="flex-1 text-black block w-full focus:ring-primary-light-600 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-gray-300"
                        opts={autocomplete: "email"}
                      />
                    </div>
                    {#if @register_form.submitted_once?}
                      <ErrorTag />
                    {/if}
                  </div>
                </Field>
              </div>

              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                <Field name={:password}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Password</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <PasswordInput
                        value={AshPhoenix.Form.value(@register_form, :password)}
                        class="flex-1 text-black block w-full focus:ring--500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-gray-300"
                      />
                    </div>
                    {#if @register_form.submitted_once?}
                      <ErrorTag />
                    {/if}
                  </div>
                </Field>
              </div>
              <Field name={:remember_me}>
                <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Remember Me</Label>
                <div class="mt-1">
                  <div class="flex rounded-md shadow-sm">
                    <Checkbox class="text-black block focus:ring-primary-light-500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-gray-300" />
                  </div>
                  {#if @register_form.submitted_once?}
                    <ErrorTag />
                  {/if}
                </div>
              </Field>
            </div>
          </div>

          <div class="pt-5">
            <div class="flex justify-end">
              <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-primary-light-600 hover:bg-primary-light-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-light-600 text-white">Log In</Submit>
            </div>
          </div>
        </Form>
        <LiveRedirect to={Routes.app_view_path(AshHqWeb.Endpoint, :log_in)}>Already Have an account?</LiveRedirect>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_form()}
  end

  defp assign_form(socket) do
    assign(socket,
      register_form:
        AshPhoenix.Form.for_create(
          AshHq.Accounts.User,
          :register,
          as: "register",
          api: AshHq.Accounts
        )
    )
  end

  @impl true
  def handle_event("validate_register", %{"register" => params}, socket) do
    {:noreply,
     assign(socket,
       register_form: AshPhoenix.Form.validate(socket.assigns.register_form, params)
     )}
  end

  @impl true
  def handle_event("register", %{"register" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.register_form, params: params) do
      {:ok, user} ->
        token = AshHqWeb.UserAuth.create_token_for_user(user)

        {:noreply,
         redirect(socket,
           to:
             Routes.user_session_path(AshHqWeb.Endpoint, :log_in, %{
               "log_in" => %{
                 "token" => Base.url_encode64(token, padding: false),
                 "remember_me" => params["remember_me"] || "false"
               }
             })
         )}

      {:error, form} ->
        {:noreply, assign(socket, log_in_form: form)}
    end
  end
end
