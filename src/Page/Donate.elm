module Page.Donate exposing (Model, Msg(..), init, view, fromGlobal, toGlobal)

import Css exposing (..)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Data.Cache as Cache exposing (Cache)
import Data.Session as Session exposing (Session)
import Message



-- Model


type alias Model =
    { cache : Cache
    , session : Session
    }


init : (Model -> e) -> (Session, Cache) -> ( e, Cmd msg )
init transform (session, cache) =
    ( transform <|
        { session = session
        , cache = cache
        }
    , Cmd.none
    )


fromGlobal : (Session, Cache) -> Model -> Model
fromGlobal (session, cache) model =
    { model | cache = cache, session = session }


toGlobal : Model -> (Session, Cache)
toGlobal model =
    (model.session, model.cache)



-- Message

type Msg
    = NoOp

-- View


view : Model -> Html Message.Msg
view model =
    let
        theme =
            Cache.theme model.cache
    in
    div
        [ class (Route.toClass Donate) ]
        [
        ]

