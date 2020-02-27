module Page exposing (toContext, fromContext)


toContext : { m | context : c } -> c
toContext =
    .context


fromContext : c -> { m | context : c } -> { m | context : c }
fromContext context model =
    { model | context = context }
