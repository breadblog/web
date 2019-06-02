module Page.Problem exposing (view)


import View.Page as Page


{- Model -}


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


{- Constructors -}


init : General -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init {} Cmd.none Problem
