defmodule AshHq.Repo.Migrations.MigrateResources36 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      modify(:hashed_password, :text, null: false)
    end

    execute("""
    DELETE FROM user_tokens
    """)

    alter table(:user_tokens) do
      remove(:sent_to)
      remove(:context)
      remove(:token)
      remove(:id)

      add(:updated_at, :utc_datetime_usec, null: false, default: fragment("now()"))
      add(:extra_data, :map)
      add(:purpose, :text, null: false)
      add(:expires_at, :utc_datetime, null: false)
      add(:jti, :text, null: false, primary_key: true)
    end

    drop_if_exists(
      unique_index(:user_tokens, [:context, :token], name: "user_tokens_token_context_index")
    )
  end

  def down do
    create unique_index(:user_tokens, [:context, :token], name: "user_tokens_token_context_index")

    alter table(:user_tokens) do
      remove(:jti)
      remove(:expires_at)
      remove(:purpose)
      remove(:extra_data)
      remove(:updated_at)
      add(:id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true)
      add(:context, :text)
      add(:sent_to, :text)
    end

    alter table(:users) do
      modify(:hashed_password, :text, null: true)
    end
  end
end