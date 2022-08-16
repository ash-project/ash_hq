defmodule AshHqWeb.Pages.ResetPassword do
  @moduledoc "Log in page"
  use Surface.LiveComponent

  alias Surface.Components.{Form, LiveRedirect}

  alias Surface.Components.Form.{
    ErrorTag,
    Field,
    Label,
    PasswordInput,
    Submit,
    TextInput
  }

  alias AshHqWeb.Router.Helpers, as: Routes

  prop params, :map

  data error, :boolean, default: false
  data password_reset_form, :any

  def render(assigns) do
    ~F"""
    <div class="container flex flex-wrap mx-auto">
      <div class="w-full md:w-2/3 ml-2">
        {#if @password_reset_form}
          <Form class="space-y-8" for={@password_reset_form} submit="reset_password">
            <div class="space-y-8 sm:space-y-5">
              <div>
                <h3 class="text-lg leading-6 font-medium">Reset Password</h3>
                {#if @password_reset_form.submitted_once?}
                  <div class="alert alert-danger">
                    <p>Oops, something went wrong! Please check the errors below.</p>
                  </div>
                {/if}
              </div>

              <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
                <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                  <Field name={:password}>
                    <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Password</Label>
                    <div class="mt-1 sm:mt-0 sm:col-span-2">
                      <div class="max-w-lg flex rounded-md shadow-sm">
                        <PasswordInput class="flex-1 text-black block w-full focus:ring-orange-600 focus:border-orange-600 min-w-0 rounded-md sm:text-sm border-gray-300" />
                      </div>
                      <ErrorTag />
                    </div>
                  </Field>
                </div>
              </div>

              <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
                <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                  <Field name={:password_confirmation}>
                    <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Password Confirmation</Label>
                    <div class="mt-1 sm:mt-0 sm:col-span-2">
                      <div class="max-w-lg flex rounded-md shadow-sm">
                        <PasswordInput class="flex-1 text-black block w-full focus:ring-orange-600 focus:border-orange-600 min-w-0 rounded-md sm:text-sm border-gray-300" />
                      </div>
                      <ErrorTag />
                    </div>
                  </Field>
                </div>
              </div>
            </div>

            <div class="pt-5">
              <div class="flex justify-end">
                <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-600 text-white">Reset Password</Submit>
              </div>
            </div>
          </Form>
        {#else}
          <Form class="space-y-8" for={:request_password_reset} submit="request_password_reset">
            <div class="space-y-8 sm:space-y-5">
              <div>
                <h3 class="text-lg leading-6 font-medium">Choose New Password</h3>
                {#if @error}
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
                          class="flex-1 text-black block w-full focus:ring-orange-600 focus:border-orange-600 min-w-0 rounded-md sm:text-sm border-gray-300"
                          opts={autocomplete: "email"}
                        />
                      </div>
                      <ErrorTag />
                    </div>
                  </Field>
                </div>
              </div>
            </div>

            <div class="pt-5">
              <div class="flex justify-end">
                <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-600 text-white">Send Password Reset Email</Submit>
              </div>
            </div>
          </Form>
          <LiveRedirect to={Routes.app_view_path(AshHqWeb.Endpoint, :log_in)}>Remember your password?</LiveRedirect>
        {/if}
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_reset_form()}
  end

  defp assign_reset_form(socket) do
    case socket.assigns[:params]["token"] do
      nil ->
        assign(socket, password_reset_form: nil)

      token ->
        user =
          AshHq.Accounts.User
          |> Ash.Query.for_read(
            :with_verified_email_token,
            %{token: token, context: "reset_password"},
            authorize?: false
          )
          |> AshHq.Accounts.read_one!()

        if user do
          assign(
            socket,
            :password_reset_form,
            AshPhoenix.Form.for_update(user, :reset_password,
              as: "reset_password",
              api: AshHq.Accounts
            )
          )
        else
          socket
          |> put_flash(:error, "Reset password link is invalid or it has expired.")
          |> assign(password_reset_form: nil)
        end
    end
  end

  @impl true
  def handle_event("reset_password", %{"reset_password" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.password_reset_form,
           params: params
         ) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully reset password.")
         |> push_redirect(to: Routes.app_view_path(AshHqWeb.Endpoint, :log_in))}

      {:error, form} ->
        {:noreply, assign(socket, password_reset_form: form)}
    end
  end

  @impl true
  def handle_event(
        "request_password_reset",
        %{"request_password_reset" => %{"email" => email}},
        socket
      ) do
    with {:ok, user} <-
           AshHq.Accounts.get(AshHq.Accounts.User, [email: String.trim(email)], authorize?: false) do
      user
      |> Ash.Changeset.for_update(
        :deliver_user_reset_password_instructions,
        %{reset_password_url_fun: &Routes.app_view_url(AshHqWeb.Endpoint, :reset_password, &1)},
        authorize?: false
      )
      |> AshHq.Accounts.update!()
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       "If your email is in our system, you will receive instructions to reset your password shortly."
     )
     |> push_redirect(to: Routes.app_view_path(AshHqWeb.Endpoint, :reset_password))}
  end
end
