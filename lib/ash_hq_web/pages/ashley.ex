defmodule AshHqWeb.Pages.Ashley do
  @moduledoc "Ashley page"
  use Surface.LiveComponent
  import AshHqWeb.Tails

  alias Surface.Components.Form

  alias Surface.Components.Form.{
    Field,
    TextArea,
    TextInput
  }

  prop(current_user, :any)
  prop(params, :map)

  data(messages, :list)
  data(message_form, :any)
  data(new_message_form, :any)
  data(conversation, :any)
  data(conversations, :list)
  data(editing_conversation, :boolean)
  data(conversation_form, :any)

  def render(assigns) do
    ~F"""
    <div class="grid grid-cols-6 w-2/3 mx-auto">
      {#if is_nil(@current_user) || !@current_user.ashley_access}
        You do not have access to this page.
      {#else}
        <div class="grid-cols-1 flex-col w-full">
          <a
            href="/ashley"
            class="p-2 rounded-md bg-gray-300 dark:bg-gray-800 w-full flex flex-row items-center"
          >
            <Heroicons.Solid.PlusIcon class="h-4 w-4" /> New
          </a>
          {#for conversation <- @conversations}
            <div class={classes([
              "p-2",
              ["text-gray-500": conversation.question_count >= AshHq.Ashley.Conversation.conversation_limit()]
            ])}>
              <a href={"/ashley/#{conversation.id}"}>
                {conversation.name} - {conversation.question_count}</a>
            </div>
          {/for}
        </div>
        <div
          id="chat-window"
          class="col-span-5 flex-col prose prose-xl dark:prose-invert h-screen w-full"
        >
          {#if @conversation}
            {#if @editing_conversation}
              <Form for={@conversation_form} submit="save_conversation" class="flex flex-row justify-between">
                <Field name={:name} class="w-full">
                  <TextInput class="flex-grow text-black block focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300 w-full" />
                </Field>
                <button type="submit">
                  <Heroicons.Outline.SaveIcon class="h-5 w-5" />
                </button>
              </Form>
            {#else}
              <div class="flex flex-row w-full justify-between">
                <div>
                  {@conversation.name}
                </div>
                <div class="flex flex-row">
                  <button :on-click="toggle-editing-conversation" class="mr-4">
                    <Heroicons.Outline.PencilIcon class="h-5 w-5" />
                  </button>

                  <button
                    :on-click="destroy-conversation"
                    phx-value-conversation-id={@conversation.id}
                    data-confirm="Are you sure?"
                  >
                    <Heroicons.Outline.XIcon class="h-5 w-5" />
                  </button>
                </div>
              </div>
            {/if}
            <div class="overflow-y-scroll h-2/3">
              <div style="scroll-snap-type: y; scroll-snap-align: end;">
                <div>
                  <div>
                    Hello! My name is Ashley. I've been instructed to answer your questions as factually as possible, but I am *far* from perfect.
                    My code snippets especially are not likely to be accurate. However, I cite my sources below each answer to show you what content
                    I thought was relevant, so please use that for official clarification.
                  </div>
                </div>
                <hr>
                {#for question <- @conversation.questions}
                  <div>
                    <div class="font-light mt-12">
                      {question.question}
                    </div>
                    <hr>
                    <div>
                      {raw(question.answer_html)}
                    </div>
                    {#if question.sources != []}
                      <h3>Sources</h3>
                      <ul>
                        {#for source <- question.sources}
                          <li><a href={"https://ash-hq.org/#{source.link}"}>{source.name}</a></li>
                        {/for}
                      </ul>
                    {/if}
                  </div>
                {/for}
              </div>
            </div>
            <div class="mt-12 w-full">
              <Form for={@message_form} submit="save_message">
                <div class="flex flex-row w-full">
                  <div class="w-full">
                    <Field name={:question} class="w-full">
                      <TextArea class="flex-grow text-black block focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300 w-full" />
                    </Field>
                  </div>

                  <button
                    type="submit"
                    class="p-4 rounded-xl bg-gray-200 dark:bg-gray-600 flex flex-row items-center ml-12 h-12"
                  >
                    <Heroicons.Outline.PaperAirplaneIcon class="h-4 w-4" /><div>Submit</div>
                  </button>
                </div>
              </Form>
            </div>
          {#else}
            <Form for={@new_message_form} submit="save_new_message">
              <div class="flex flex-row w-full">
                <div class="w-full">
                  <Field name={:conversation_name} class="mb-4">
                    <TextInput
                      class="flex-grow text-black block focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300 w-full"
                      opts={placeholder: "New Conversation"}
                    />
                  </Field>
                  <div>
                    <div>
                      Hello! My name is Ashley. I've been instructed to answer your questions as factually as possible, but I am *far* from perfect.
                      My code snippets especially are not likely to be accurate. However, I cite my sources below each answer to show you what content
                      I thought was relevant, so please use that for official clarification.
                    </div>
                  </div>
                  <hr>
                  <Field name={:question} class="w-full">
                    <TextArea class="flex-grow text-black block focus:ring-primary-light-600 focus:primary-light-primary-light-600 min-w-0 rounded-md sm:text-sm border-base-light-300 w-full" />
                  </Field>
                </div>

                <button
                  type="submit_new_message"
                  class="p-4 rounded-xl bg-gray-200 dark:bg-gray-600 flex flex-row items-center ml-12 h-12"
                >
                  <Heroicons.Outline.PaperAirplaneIcon class="h-4 w-4" /><div>Submit</div>
                </button>
              </div>
            </Form>
          {/if}
        </div>
      {/if}
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(editing_conversation: false)
     |> assign_conversations()
     |> assign_conversation()
     |> assign_message_form()
     |> assign_change_name_form()
     |> assign_new_message_form}
  end

  defp assign_change_name_form(socket) do
    if socket.assigns[:conversation] do
      assign(
        socket,
        :conversation_form,
        AshPhoenix.Form.for_update(socket.assigns.conversation, :update,
          actor: socket.assigns.current_user,
          api: AshHq.Ashley,
          as: "conversation"
        )
      )
    else
      assign(socket, conversation_form: nil)
    end
  end

  defp assign_conversations(socket) do
    if socket.assigns[:current_user] do
      assign(socket,
        conversations:
          AshHq.Ashley.Conversation.read!(
            actor: socket.assigns.current_user,
            load: :question_count
          )
      )
    else
      assign(socket, conversations: [])
    end
  end

  defp assign_conversation(socket) do
    if socket.assigns[:current_user] && socket.assigns[:params]["conversation_id"] do
      assign(socket,
        conversation:
          Enum.find(
            socket.assigns.conversations,
            &(&1.id == socket.assigns[:params]["conversation_id"])
          )
          |> AshHq.Ashley.load!(:questions, actor: socket.assigns.current_user)
      )
    else
      assign(socket, :conversation, nil)
    end
  end

  defp assign_message_form(socket) do
    if socket.assigns[:current_user] && socket.assigns[:conversation] do
      assign(
        socket,
        :message_form,
        AshPhoenix.Form.for_create(AshHq.Ashley.Question, :ask,
          actor: socket.assigns[:current_user],
          api: AshHq.Ashley,
          as: "message",
          prepare_source: fn changeset ->
            Ash.Changeset.force_change_attribute(
              changeset,
              :conversation_id,
              socket.assigns.conversation.id
            )
          end
        )
      )
    else
      assign(socket, :message_form, nil)
    end
  end

  defp assign_new_message_form(socket) do
    if socket.assigns[:current_user] do
      assign(
        socket,
        :new_message_form,
        AshPhoenix.Form.for_create(AshHq.Ashley.Question, :ask,
          actor: socket.assigns[:current_user],
          api: AshHq.Ashley,
          as: "new_message"
        )
      )
    else
      assign(socket, :new_message_form, nil)
    end
  end

  def handle_event("save_conversation", %{"conversation" => conversation_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.conversation_form, params: conversation_params) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> assign_conversations()
         |> assign_conversation()
         |> assign(editing_conversation: false)
         |> assign_message_form()}

      {:error, form} ->
        {:noreply, assign(socket, conversation_form: form)}
    end
  end

  def handle_event("save_message", %{"message" => message_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.message_form, params: message_params) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> assign_conversations()
         |> assign_conversation()
         |> assign_message_form()}

      {:error, form} ->
        {:noreply, assign(socket, message_form: form)}
    end
  end

  def handle_event("save_new_message", %{"new_message" => message_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.new_message_form, params: message_params) do
      {:ok, message} ->
        {:noreply,
         socket
         |> push_patch(to: "/ashley/#{message.conversation_id}")}

      {:error, form} ->
        {:noreply, assign(socket, message_form: form)}
    end
  end

  def handle_event("toggle-editing-conversation", _, socket) do
    {:noreply, assign(socket, editing_conversation: true)}
  end

  def handle_event("destroy-conversation", %{"conversation-id" => conversation_id}, socket) do
    case Enum.split_with(socket.assigns.conversations, &(&1.id == conversation_id)) do
      {[conversation], rest} ->
        AshHq.Ashley.Conversation.destroy!(conversation, actor: socket.assigns.current_user)
        {:noreply, assign(socket, conversations: rest, conversation: nil)}

      _ ->
        {:noreply, socket}
    end
  end
end
