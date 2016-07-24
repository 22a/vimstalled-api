defmodule Vimstalled.ApiRouter do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug Corsica, origins: "*"
  plug :dispatch

  post "/plugins" do
    IO.puts inspect conn.params
    vimrc_url = conn.params["vimrc"]
    case HTTPoison.get(vimrc_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        matches = Regex.scan(~r/^Plug\s.*$/m, body)
        plugins = Enum.map(matches, fn(x) -> String.slice(List.first(Regex.run(~r/[",'](.*?)[",']/, List.first(x))),1..-2) end )
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{plugins: plugins}))

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
    conn
    |> send_resp(404, "I dunno what happened m8")
  end

  match _ do
    IO.puts inspect conn
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{garble: 3833828342}))
  end
end
