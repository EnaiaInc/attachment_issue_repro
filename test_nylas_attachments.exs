#!/usr/bin/env elixir
Mix.install([
  {:ex_nylas, github: "nicholasbair/ex_nylas", ref: "07dc91f255777af335ea6599c871f630843d68df"},
  {:jason, "~> 1.4"},
  {:dotenv, "~> 3.1"}
])

Dotenv.load()

conn =
  ExNylas.Connection.__struct__(%{
    client_id: System.fetch_env!("NYLAS_CLIENT_ID"),
    api_key: System.fetch_env!("NYLAS_API_KEY"),
    grant_id: System.get_env("NYLAS_GRANT_ID"),
    options: [receive_timeout: 30_000]
  })

params = %{
  subject: "From ExNylas: inline and \"regular\" attachments",
  body: """
  <html>
    <body>
      Testing inline vs regular attachments<br>
      <img src="cid:hali.png"><br>
      And you should also see an attached PDF
    </body>
  </html>
  """,
  to: [%{email: System.fetch_env!("TO_EMAIL")}]
}

# One attachment is a tuple with content_id, the other is just a path
# Maybe a clue about what's going wrong in our app? Not sure.
attachments = [
  # {content_id, file_path} for inline
  {"hali.png", "hali.png"},
  # just file_path for regular attachment
  "toaster oven.pdf"
]

IO.puts("Creating draft...")
{:ok, draft} = ExNylas.Drafts.create(conn, params, attachments)
IO.puts("Created draft with ID: #{draft.data.id}")

IO.puts("\nGetting draft to show attachment status:")
{:ok, draft_details} = ExNylas.Drafts.find(conn, draft.data.id)
IO.inspect(draft_details)

IO.puts("\nSending draft...")
{:ok, sent} = ExNylas.Drafts.send(conn, draft.data.id)
IO.inspect(sent)
