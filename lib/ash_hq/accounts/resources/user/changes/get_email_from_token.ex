defmodule AshHq.Accounts.User.Changes.GetEmailFromToken do
  @moduledoc "A change that fetches the token for an email change"

  use Ash.Resource.Change

  def get_email_from_token do
    {__MODULE__, []}
  end

  def init(_), do: {:ok, []}

  def change(changeset, _opts, _) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      if changeset.valid? do
        token = Ash.Changeset.get_argument(changeset, :token)

        AshHq.Accounts.UserToken
        |> Ash.Query.for_read(:verify_email_token,
          token: token,
          context: "change:#{changeset.data.email}"
        )
        |> AshHq.Accounts.read_one(authorize?: false)
        |> case do
          {:ok, %{sent_to: new_email}} ->
            Ash.Changeset.change_attribute(changeset, :email, new_email)

          _ ->
            Ash.Changeset.add_error(changeset,
              field: :token,
              message: "Could not find corresponding token"
            )
        end
      else
        changeset
      end
    end)
  end
end
