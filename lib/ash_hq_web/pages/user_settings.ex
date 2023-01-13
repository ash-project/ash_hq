defmodule AshHqWeb.Pages.UserSettings do
  @moduledoc "User settings page"
  use Surface.LiveComponent

  alias Surface.Components.Form

  alias Surface.Components.Form.{
    ErrorTag,
    Field,
    Label,
    PasswordInput,
    Submit,
    TextArea,
    TextInput
  }

  prop(current_user, :map, required: true)

  data(email_form, :map)
  data(password_form, :map)
  data(merch_form, :map)
  data(address, :string)
  data(name, :string)

  def render(assigns) do
    ~F"""
    <div class="container flex flex-wrap mx-auto overflow-auto">
      <div class="w-full md:w-2/3 ml-2">
        <Form
          opts={id: @email_form.id}
          class="space-y-8"
          for={@email_form}
          change="validate_update_email"
          submit="save_update_email"
        >
          <div class="space-y-8 sm:space-y-5">
            <div>
              <h3 class="text-lg leading-6 font-medium">Change Email</h3>
              {#if @email_form.submitted_once?}
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
                        class="flex-1 text-black block w-full focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300"
                        opts={autocomplete: "email"}
                      />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>

              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-base-light-200 dark:sm:border-base-dark-700 sm:pt-5">
                <Field name={:current_password}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Current Password</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <PasswordInput
                        value={AshPhoenix.Form.value(@email_form, :current_password)}
                        class="flex-1 text-black block w-full focus:ring--500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300"
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
              <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-primary-light-600 hover:bg-primary-light-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-light-600 text-white">Update Email</Submit>
            </div>
          </div>
        </Form>
        <Form
          opts={id: @password_form.id}
          class="space-y-8"
          for={@password_form}
          change="validate_password"
          submit="save_password"
        >
          <div class="space-y-8 sm:space-y-5">
            <div>
              <h3 class="text-lg leading-6 font-medium">Change Password</h3>
              {#if @password_form.submitted_once?}
                <div class="alert alert-danger">
                  <p>Oops, something went wrong! Please check the errors below.</p>
                </div>
              {/if}
            </div>

            <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-base-light-200 dark:sm:border-base-dark-700 sm:pt-5">
                <Field name={:password}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">New Password</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <PasswordInput
                        value={AshPhoenix.Form.value(@password_form, :password)}
                        class="flex-1 text-black block w-full focus:ring--500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300"
                      />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>
            </div>

            <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-base-light-200 dark:sm:border-base-dark-700 sm:pt-5">
                <Field name={:password_confirmation}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Confirm New Password</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <PasswordInput
                        value={AshPhoenix.Form.value(@password_form, :password_confirmation)}
                        class="flex-1 text-black block w-full focus:ring--500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300"
                      />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>
            </div>

            <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-base-light-200 dark:sm:border-base-dark-700 sm:pt-5">
                <Field name={:current_password}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Current Password</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <PasswordInput
                        value={AshPhoenix.Form.value(@password_form, :current_password)}
                        class="flex-1 text-black block w-full focus:ring--500 focus:border-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300"
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
              <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-primary-light-600 hover:bg-primary-light-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-light-600 text-white">Change Password</Submit>
            </div>
          </div>
        </Form>
        <Form
          opts={id: @merch_form.id}
          class="space-y-8"
          for={@merch_form}
          change="validate_merch"
          submit="save_merch"
        >
          <div class="space-y-8 sm:space-y-5">
            <div>
              <h3 class="text-lg leading-6 font-medium">Merch Settings</h3>
              {#if @merch_form.submitted_once?}
                <div class="alert alert-danger">
                  <p>Oops, something went wrong! Please check the errors below.</p>
                </div>
              {/if}
            </div>

            <div class="mt-6 sm:mt-5 space-y-6 sm:space-y-5">
              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                <Field name={:name}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Name</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <TextInput class="flex-1 text-black block w-full focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300" />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>

              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5">
                <Field name={:shirt_size}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Shirt Size</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <TextInput class="flex-1 text-black block w-full focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300" />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>

              <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:border-t sm:border-base-light-200 dark:sm:border-base-dark-700 sm:pt-5">
                <Field name={:address}>
                  <Label class="block text-sm font-medium sm:mt-px sm:pt-2">Address</Label>
                  <div class="mt-1 sm:mt-0 sm:col-span-2">
                    <div class="max-w-lg flex rounded-md shadow-sm">
                      <TextArea class="flex-1 text-black block w-full focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300" />
                    </div>
                    <ErrorTag />
                  </div>
                </Field>
              </div>
            </div>
          </div>

          <div class="pt-5">
            <div class="flex justify-end">
              <Submit class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-primary-light-600 hover:bg-primary-light-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-light-600 text-white">Save</Submit>
            </div>
          </div>
        </Form>

        {#if !@current_user.confirmed_at}
          <div class="mt-5 pt-5 border-t">
            <button
              type="button"
              class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md  bg-primary-light-600 hover:bg-primary-light-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-light-600 text-white"
              :on-click="resend_confirmation_instructions"
            >Resend Email Confirmation Instructions</button>
          </div>
        {/if}
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_forms()}
  end

  defp assign_forms(socket) do
    user =
      AshHq.Accounts.load!(socket.assigns.current_user, [:address, :name],
        actor: socket.assigns.current_user
      )

    merch_form_params = %{"address" => user.address, "name" => user.name}

    assign(socket,
      email_form:
        AshPhoenix.Form.for_update(
          socket.assigns.current_user,
          :update_email,
          as: "update_email",
          api: AshHq.Accounts,
          actor: socket.assigns.current_user
        ),
      password_form:
        AshPhoenix.Form.for_update(socket.assigns.current_user, :change_password,
          as: "change_password",
          api: AshHq.Accounts,
          actor: socket.assigns.current_user
        ),
      merch_form:
        AshPhoenix.Form.for_update(socket.assigns.current_user, :update_merch_settings,
          as: "update_merch",
          api: AshHq.Accounts,
          actor: socket.assigns.current_user
        )
        |> AshPhoenix.Form.validate(merch_form_params, errors: false)
    )
  end

  @impl true
  def handle_event("validate_update_email", %{"update_email" => params}, socket) do
    {:noreply,
     assign(socket,
       email_form:
         AshPhoenix.Form.validate(socket.assigns.email_form, params,
           errors: socket.assigns.email_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("save_update_email", %{"update_email" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.email_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Check your email to confirm your new address.")
         |> push_redirect(to: "/users/settings")}

      {:error, email_form} ->
        {:noreply, assign(socket, email_form: email_form)}
    end
  end

  @impl true
  def handle_event("save_merch", %{"update_merch" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.merch_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merch settings updated")
         |> push_redirect(to: "/users/settings")}

      {:error, merch_form} ->
        {:noreply, assign(socket, merch_form: merch_form)}
    end
  end

  def handle_event("validate_merch", %{"update_merch" => params}, socket) do
    {:noreply,
     assign(socket,
       merch_form:
         AshPhoenix.Form.validate(socket.assigns.merch_form, params,
           errors: socket.assigns.merch_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("validate_password", %{"change_password" => params}, socket) do
    {:noreply,
     assign(socket,
       password_form:
         AshPhoenix.Form.validate(socket.assigns.password_form, params,
           errors: socket.assigns.email_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("save_password", %{"change_password" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.password_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password has been successfully changed.")
         |> push_redirect(to: "/")}

      {:error, password_form} ->
        {:noreply, assign(socket, password_form: password_form)}
    end
  end

  @impl true
  def handle_event("resend_confirmation_instructions", _, socket) do
    AshHq.Accounts.User.resend_confirmation_instructions!(socket.assigns.current_user,
      actor: socket.assigns.current_user
    )

    {:noreply, socket}
  end
end
