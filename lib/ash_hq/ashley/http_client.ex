defmodule AshHq.Ashley.HttpClient do
  @moduledoc false

  alias OpenAI.Behaviours.HttpClientBehaviour
  alias OpenAI.Error

  @behaviour HttpClientBehaviour

  @impl HttpClientBehaviour

  def request(_, _, _, %{stream: true}, _) do
    {:error,
     %Error{
       message: "Streaming server-sent events is not currently supported by this client."
     }}
  end

  def request(method, url, headers, params, opts) do
    case do_request(method, url, headers, params, opts) do
      {:ok, %Finch.Response{body: body}} -> {:ok, body}
      {:error, error} -> {:error, error}
    end
  end

  @impl HttpClientBehaviour
  def multipart_request(:post, url, headers, multipart, opts) do
    body_stream = Multipart.body_stream(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")
    content_length = Multipart.content_length(multipart)

    headers = [
      {"Content-Type", content_type},
      {"Content-Length", to_string(content_length)} | headers
    ]

    request(:post, url, headers, {:stream, body_stream}, opts)
  end

  defp do_request(method, url, headers, nil, opts) do
    Finch.build(method, url, headers, nil, opts) |> Finch.request(OpenAI.Finch)
  end

  defp do_request(:post, url, headers, {:stream, _} = params, opts) do
    Finch.build(:post, url, headers, params, opts) |> Finch.request(OpenAI.Finch)
  end

  defp do_request(method, url, headers, params, opts) do
    Finch.build(method, url, headers, Jason.encode!(params), opts)
    |> Finch.request(OpenAI.Finch, receive_timeout: :infinity)
  end
end
