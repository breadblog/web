module Page.CreatePost exposing (Model, Msg, update, view, init, fromGeneral, toGeneral)


{-

    We need to be able to
    
    1) create a post
    2) edit a post
    3) preview a post
    4) view a post

-}


import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (onClick)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Post, Full)
import View.Page as Page
import Api


{- Model -}


type alias Model =
    Page.PageModel Internals


type Internals
    = Create (Post Full)
    | Preview (Post Full)
    | Failed Failure


type Failure
    = NotLoggedIn


init : General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init general =
    Page.init
        (Create Post.empty)
        (Cmd.none)
        (general)


{- Msg -}


type ModMsg
    = NoOp


{- Update -}


{- View -}
