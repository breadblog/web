module View.Page exposing (Msg, PageModel, TransformModel, TransformMsg, ViewResult, fromGeneral, init, toGeneral, update, view)

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


type PageModel modModel
    = PageModel (Internals modModel)


type alias Internals modModel =
    { header : Header.Model
    , footer : Footer.Model
    , cache : Cache
    , session : Session
    , mod : modModel
    }


type alias TransformModel modModel model_ =
    PageModel modModel -> model_


type alias TransformMsg modMsg msg =
    Msg modMsg -> msg


init : modModel -> Cmd modMsg -> Route -> General -> TransformModel modModel model_ -> TransformMsg modMsg msg -> ( model_, Cmd msg )
init modModel modCmd route general transformModel transformMsg =
    let
        header =
            Header.init route

        footer =
            Footer.init

        pageCmd =
            Cmd.map
                PageMsg
                modCmd

        pageModel =
            PageModel
                { header = header
                , footer = footer
                , mod = modModel
                , cache = General.cache general
                , session = General.session general
                }

        model_ =
            transformModel pageModel

        cmd =
            Cmd.map transformMsg pageCmd
    in
    ( model_, cmd )


toGeneral : PageModel modModel -> General
toGeneral (PageModel pageModel) =
    General.init pageModel.session pageModel.cache


fromGeneral : General -> PageModel modModel -> PageModel modModel
fromGeneral general (PageModel pageModel) =
    let
        session_ =
            General.session general

        cache_ =
            General.cache general
    in
    PageModel { pageModel | session = session_, cache = cache_ }



-- Message --


type Msg modMsg
    = HeaderMsg Header.Msg
    | FooterMsg Footer.Msg
    | PageMsg modMsg



-- Update --


type alias ModUpdate modModel modMsg =
    modMsg -> Session -> Cache -> modModel -> ( modModel, Cmd modMsg )


update : ModUpdate modModel modMsg -> Msg modMsg -> PageModel modModel -> ( PageModel modModel, Cmd (Msg modMsg) )
update modUpdate msg (PageModel pageModel) =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.update headerMsg pageModel.header

                cmd =
                    Cmd.map HeaderMsg headerCmd
            in
            ( PageModel { pageModel | header = headerModel }, cmd )

        FooterMsg footerMsg ->
            let
                ( footerModel, footerCmd ) =
                    Footer.update footerMsg pageModel.footer

                cmd =
                    Cmd.map FooterMsg footerCmd
            in
            ( PageModel { pageModel | footer = footerModel }, cmd )

        PageMsg modMsg ->
            let
                session =
                    pageModel.session

                cache =
                    pageModel.cache

                ( modModel, pageCmd ) =
                    modUpdate modMsg session cache pageModel.mod

                cmd =
                    Cmd.map PageMsg pageCmd
            in
            ( PageModel { pageModel | mod = modModel }, cmd )



-- View --


type alias ViewPage modModel modMsg =
    Session -> Cache -> modModel -> List (Html (Compound modMsg))


type alias ViewResult modMsg =
    List (Html (Compound (Msg modMsg)))


view : PageModel modModel -> ViewPage modModel modMsg -> ViewResult modMsg
view (PageModel pageModel) viewPage =
    let
        tags =
            Cache.tags pageModel.cache

        authors =
            Cache.authors pageModel.cache

        version =
            Cache.version pageModel.cache

        theme_ =
            Cache.theme pageModel.cache

        header =
            Header.view (Message.map HeaderMsg) theme_ authors tags pageModel.header

        footer =
            Footer.view (Message.map FooterMsg) theme_ version

        mod =
            List.map
                (Html.Styled.map (Message.map PageMsg))
                (viewPage pageModel.session pageModel.cache pageModel.mod)
    in
    List.concat
        [ header
        , mod
        , footer
        ]
