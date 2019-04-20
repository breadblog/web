module View.Page exposing (Model, Msg, cache, init, mod, session, theme, toGeneral, update, view)

import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.Theme as Theme exposing (Theme)
import Html.Styled exposing (Html, main_)
import Message exposing (Compound(..))
import View.Footer as Footer
import View.Header as Header



{--
    Utility for creating a main page

    Will automatically generate a header and footer for
    the page

    Do not use for pages you don't want to have a
    header/footer
--}
-- Model --


type Model modModel
    = Model (Internals modModel)


type alias Internals modModel =
    { header : Header.Model
    , footer : Footer.Model
    , cache : Cache
    , session : Session
    , page : modModel
    }


init : modModel -> Cmd modMsg -> Route -> General -> ( Model modModel, Cmd (Msg modMsg) )
init modModel pageCmd route general =
    let
        header =
            Header.init route

        footer =
            Footer.init

        cmd =
            Cmd.map
                PageMsg
                pageCmd

        model =
            Model
                { header = header
                , footer = footer
                , page = modModel
                , cache = General.cache general
                , session = General.session general
                }
    in
    ( model, cmd )


toGeneral : Model modModel -> General
toGeneral (Model model) =
    General.init model.session model.cache (Cache.theme model.cache)



-- Accessors --


theme : Model p -> Theme
theme (Model model) =
    Cache.theme model.cache


session : Model p -> Session
session (Model model) =
    model.session


cache : Model p -> Cache
cache (Model model) =
    model.cache


mod : Model p -> p
mod (Model model) =
    model.page



-- Message --


type Msg modMsg
    = HeaderMsg Header.Msg
    | FooterMsg Footer.Msg
    | PageMsg modMsg



-- Update --


update : (modMsg -> Model modModel -> ( modModel, Cmd modMsg )) -> Msg modMsg -> Model modModel -> ( Model modModel, Cmd (Msg modMsg) )
update pageUpdate msg (Model model) =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.update headerMsg model.header

                cmd =
                    Cmd.map HeaderMsg headerCmd
            in
            ( Model { model | header = headerModel }, cmd )

        FooterMsg footerMsg ->
            let
                ( footerModel, footerCmd ) =
                    Footer.update footerMsg model.footer

                cmd =
                    Cmd.map FooterMsg footerCmd
            in
            ( Model { model | footer = footerModel }, cmd )

        PageMsg modMsg ->
            let
                ( modModel, pageCmd ) =
                    pageUpdate modMsg (Model model)

                cmd =
                    Cmd.map PageMsg pageCmd
            in
            ( Model { model | page = modModel }, cmd )



-- View --


type alias ViewPage modModel modMsg =
    Theme -> Cache -> modModel -> List (Html (Compound modMsg))


type alias ViewResult modMsg =
    List (Html (Compound (Msg modMsg)))


view : Model modModel -> ViewPage modModel modMsg -> ViewResult modMsg
view (Model model) viewPage =
    let
        tags =
            Cache.tags model.cache

        authors =
            Cache.authors model.cache

        version =
            Cache.version model.cache

        theme_ =
            Cache.theme model.cache

        header =
            Header.view (Message.map HeaderMsg) theme_ authors tags model.header

        footer =
            Footer.view (Message.map FooterMsg) theme_ version

        page =
            List.map
                (Html.Styled.map (Message.map PageMsg))
                (viewPage theme_ model.cache model.page)
    in
    List.concat
        [ header
        , page
        , footer
        ]
