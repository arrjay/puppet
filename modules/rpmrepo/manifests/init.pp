class rpmrepo {
  # initialize all rpm repositories before installing any packages.
  Yumrepo <| |> -> Package <| |>
}
