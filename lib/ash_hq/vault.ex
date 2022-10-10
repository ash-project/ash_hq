defmodule AshHq.Vault do
  use Cloak.Vault, otp_app: :ash_hq

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default: {
          Cloak.Ciphers.AES.GCM,
          tag: "AES.GCM.V1", key: decode_env!(:cloak_key, "CLOAK_KEY"), iv_length: 12
        }
      )

    {:ok, config}
  end

  defp decode_env!(app_env, var) do
    env =
      Application.get_env(:ash_hq, app_env) ||
        System.get_env(var)

    Base.decode64!(env)
  end
end
