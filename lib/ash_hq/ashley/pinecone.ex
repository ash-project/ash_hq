defmodule AshHq.Ashley.Pinecone do
  @pinecone_opts [
    environment: "eu-west1-gcp",
    project: "ba28bca",
    index: "ash-hq-docs"
  ]

  def client() do
    Pinecone.Client.new(
      Keyword.put_new(@pinecone_opts, :api_key, System.get_env("PINECONE_API_KEY"))
    )
  end
end
