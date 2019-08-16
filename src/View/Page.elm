module View.Page exposing (Msg, PageModel, PageUpdateOutput, TransformModel, TransformMsg, ViewResult, fromGeneral, init, toGeneral, update, view)

import Data.General as General exposing (General)
import Data.Problem as Problem exposing (Problem)
import Data.Route as Route exposing (Route)
import Data.Theme as Theme exposing (Theme)
import Html.Styled exposing (Html, main_)
import Message exposing (Compound(..))
import Update
import View.Footer as Footer
import View.Header as Header



{--
    Utility for creating a main page

    Will automatically generate a header and footer for
    the page

    Do not use for pages you don't want to have a
    header/footer

    Warning: logic in this module is more complex (to simplify page logic)
--}
-- Model --


type PageModel modModel
    = PageModel (Internals modModel)


type alias Internals modModel =
    { header : Header.Model
    , footer : Footer.Model
    , general : General
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
                ModMsg
                modCmd

        pageModel =
            PageModel
                { header = header
                , footer = footer
                , mod = modModel
                , general = general
                }

        model_ =
            transformModel pageModel

        cmd =
            Cmd.map transformMsg pageCmd
    in
    ( model_, cmd )


toGeneral : PageModel modModel -> General
toGeneral (PageModel pageModel) =
    pageModel.general


fromGeneral : General -> PageModel modModel -> PageModel modModel
fromGeneral general (PageModel pageModel) =
    PageModel { pageModel | general = general }



-- Message --


type Msg modMsg
    = HeaderMsg Header.Msg
    | FooterMsg Footer.Msg
    | ModMsg modMsg



-- Update --


type alias ModUpdate modMsg modModel =
    modMsg -> General -> modModel -> Update.Output modMsg modModel


type alias PageUpdateOutput modMsg modModel =
    Update.Output (Msg modMsg) (PageModel modModel)


update : ModUpdate modMsg modModel -> Msg modMsg -> PageModel modModel -> PageUpdateOutput modMsg modModel
update modUpdate pageMsg (PageModel pageModel) =
    case pageMsg of
        ModMsg modMsg ->
            let
                mod =
                    modUpdate modMsg pageModel.general pageModel.mod

                cmd =
                    toCompoundPageCmd ModMsg mod.cmd
            in
            { model = PageModel { pageModel | mod = mod.model }
            , cmd = cmd
            , general = mod.general
            }

        HeaderMsg headerMsg ->
            let
                header =
                    Header.update headerMsg pageModel.general pageModel.header

                cmd =
                    toCompoundPageCmd HeaderMsg header.cmd
            in
            { model = PageModel { pageModel | header = header.model }
            , cmd = cmd
            , general = header.general
            }

        FooterMsg footerMsg ->
            let
                footer =
                    Footer.update footerMsg pageModel.general pageModel.footer

                cmd =
                    toCompoundPageCmd FooterMsg footer.cmd
            in
            { model = PageModel { pageModel | footer = footer.model }
            , cmd = cmd
            , general = footer.general
            }


toCompoundPageCmd : (e -> Msg modMsg) -> Cmd (Compound e) -> Cmd (Compound (Msg modMsg))
toCompoundPageCmd transform cmd =
    Cmd.map
        (\m ->
            case m of
                Global msg ->
                    Global msg

                Mod msg ->
                    Mod <| transform msg
        )
        cmd



-- View --


type alias ViewPage modModel modMsg =
    General -> modModel -> List (Html (Compound modMsg))


type alias ViewResult modMsg =
    List (Html (Compound (Msg modMsg)))


view : PageModel modModel -> ViewPage modModel modMsg -> ViewResult modMsg
view (PageModel pageModel) viewPage =
    let
        version =
            General.version pageModel.general

        theme_ =
            General.theme pageModel.general

        header =
            Header.view (Message.map HeaderMsg) theme_ pageModel.header

        footer =
            Footer.view (Message.map FooterMsg) theme_ version

        mod =
            List.map
                (Html.Styled.map (Message.map ModMsg))
                (viewPage pageModel.general pageModel.mod)
    in
    List.concat
        [ header
        , mod
        , footer
        ]
