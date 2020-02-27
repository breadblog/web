module Page.Donate exposing (Model, Msg, fromContext, init, toContext, update, view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Style.Card as Card
import Style.Color as Color
import Style.Post
import Style.Screen as Screen exposing (Screen(..))
import Svg.Styled.Attributes as SvgAttr
import View.Svg as Svg
import Page



-- Model --


type alias Model =
    { context : Context }


init : Context -> Model
init context =
    { context = context }



toContext : Model -> Context
toContext =
    Page.toContext


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext



-- Message --


type Msg
    = NoOp



-- Update --


update : msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )



-- View --


view : Model -> List (Html Msg)
view { context } =
    let
        theme =
            Context.getTheme context
    in
    [ div
        [ id "donate-page"
        , css
            [ flex3 (int 1) (int 0) (int 0)
            , displayFlex
            , alignItems center
            , flexDirection column
            , overflowY auto
            , position relative
            , overflowX Css.hidden
            ]
        ]
        [ div
            [ class "summary"
            , css
                [ Css.width (pct 80)
                , displayFlex
                , flexDirection column
                , alignItems center
                , marginTop (px 100)
                , Card.style theme
                , marginBottom (px 200)
                , lineHeight (pct 180)
                , Screen.style Screen.mobile
                    [ marginBottom (px 120) ]
                ]
            ]
            [ div
                [ css
                    [ Card.headingStyle theme ]
                ]
                [ h1
                    [ css
                        [ fontSize (rem 1.4)
                        , margin4 (px 0) (px 0) (px 0) (px 15)
                        ]
                    ]
                    [ text "Considering Donating?" ]
                ]
            , p
                [ css
                    [ fontSize (rem 1.2)
                    , padding2 (px 0) (px 15)
                    , letterSpacing (px 0.3)
                    ]
                ]
                [ text "Before you do, we just wanted to clarify that our content does not depend on donations from our readers. We are fortunate enough to use some great services that support open source, which allows our hosting fees to be negligible. If you still want to donate and support us, know that we greatly appreciate it!"
                ]
            ]
        , div
            [ class "brave"
            , id "donate-brave-section"
            , css
                [ sectionStyle ]
            ]
            [ sectionImg "/brave_lion.svg" Left
            , sectionDescription
                theme
                (Just braveUrl)
                "Brave Browser"
                (Markdown.create "Brave is an open source browser aiming to give users back their privacy online. It has built in ad & tracker blocking, so you can browse safely. And if you choose to, you can get paid to view ads integrated into the browser, allowing you to get paid for your attention in a private and secure way. And if you want to give back to content creators like us, Brave makes it easy to do so. You can check it out [here](https://brave.com/par269). For full transparency, please be aware this is an affiliate link")
                Right
            ]
        , div
            [ class "patreon"
            , id "donate-patreon-section"
            , css
                [ sectionStyle
                , flexDirection rowReverse
                ]
            ]
            [ sectionImg "/patreon.png" Right
            , sectionDescription
                theme
                (Just "https://www.patreon.com/parasrah")
                "Patreon"
                (Markdown.create "If you want to contribute in a more traditional fashion, we have a patreon account setup [here](https://www.patreon.com/parasrah). Patreon is a platform designed to make it easy to give back to content creators.")
                Left
            ]
        , div
            [ class "crypto"
            , id "donate-crypto-section"
            , css
                [ sectionStyle ]
            ]
            [ sectionImg "/ethereum.svg" Left
            , sectionDescription
                theme
                Nothing
                "Cryptocurrency"
                (Markdown.create
                    """
If you want a more untraceable way to make donations, cryptocurrency is always welcome!

### Bitcoin
```
3KuP9Jim8yinsG6RdAADZFFC95Hj6Jd1zX
```

### Ethereum
```
0xaB0Ea5a4505d85773CE143aEa45fe482ee079955
```

### Basic Attention Token
```
0xDA9c1fdE56c3D8b71aB65Cd75380BF17fFD81B17
```
                    """
                )
                Right
            ]
        ]
    , div
        [ class "overlay"
        , css
            [ position absolute
            , Css.height (pct 30)
            ]
        ]
        []
    ]


type Side
    = Left
    | Right


sectionImg : String -> Side -> Html msg
sectionImg imgSrc side =
    div
        [ class "animation-container"
        , css
            [ justifyContent center
            , flex3 (int 0) (int 0) (pct 33)
            , animationContainerStyle
            , Screen.style Screen.mobile
                [ marginBottom (px 30)
                , marginTop (px 0)
                , Css.property "flex" "0 0 auto"
                , Css.width (pct 100)
                ]
            ]
        ]
        [ img
            [ src imgSrc
            , classList
                [ ( "right", side == Right )
                , ( "left", side == Left )
                , ( "animated", True )
                , ( "hidden", True )
                , ( "animation-target", True )
                ]
            , css
                [ Css.height (px 150)
                , Screen.style Screen.mobile
                    [ Css.height auto
                    , Css.width (pct 40)
                    ]
                ]
            ]
            []
        ]


sectionDescription : Theme -> Maybe String -> String -> Markdown -> Side -> Html msg
sectionDescription theme maybeUrl title description side =
    div
        [ class "animation-container"
        , css
            [ flex3 (int 0) (int 0) (pct 66)
            , if side == Right then
                Css.batch [ justifyContent flexStart ]

              else
                Css.batch [ justifyContent flexEnd ]
            , animationContainerStyle
            , Screen.style Screen.mobile
                [ Css.property "flex" "0 0 auto"
                , marginBottom (px 120)
                , maxWidth (pct 90)
                ]
            ]
        ]
        [ div
            [ classList
                [ ( "right", side == Right )
                , ( "left", side == Left )
                , ( "animated", True )
                , ( "hidden", True )
                , ( "content", True )
                , ( "animation-target", True )
                ]
            , css
                [ displayFlex
                , flexDirection column
                , flex3 (int 0) (int 0) (pct 85)
                , Card.style theme
                , maxWidth (pct 100)
                ]
            ]
            [ div
                [ css
                    [ Card.headingStyle theme
                    , flexBasis auto
                    , justifyContent spaceBetween
                    ]
                ]
                [ h1
                    [ class "title"
                    , css
                        [ fontSize (rem 1.2)
                        , fontWeight (int 500)
                        , margin4 (px 5) (px 0) (px 5) (px 20)
                        ]
                    ]
                    [ text title ]
                , case maybeUrl of
                    Just url ->
                        a
                            [ href url
                            , css
                                [ color (Color.secondaryFont theme)
                                , marginRight (px 15)
                                , displayFlex
                                , alignItems center
                                , textDecoration none
                                ]
                            ]
                            [ Svg.link
                                [ SvgAttr.css
                                    [ Css.width (px 18)
                                    , Css.height (px 18)
                                    , marginLeft (px 5)
                                    , position relative
                                    ]
                                ]
                            ]

                    Nothing ->
                        text ""
                ]
            , div
                [ class "content"
                , css
                    [ fontSize (rem 1.0)
                    , padding2 (px 0) (px 20)
                    , letterSpacing (px 0.5)
                    , lineHeight (pct 150)
                    ]
                ]
                [ Markdown.toHtml
                    "donate-desc"
                    []
                    (Style.Post.style theme)
                    description
                ]
            ]
        ]


braveUrl : String
braveUrl =
    "https://brave.com/par269"



{- Styles -}


sectionStyle : Style
sectionStyle =
    Css.batch
        [ displayFlex
        , alignItems center
        , justifyContent spaceBetween
        , flexBasis auto
        , Css.property "flex" "1 0 auto"
        , marginBottom (px 200)
        , Css.width (pct 100)
        , Screen.style Screen.mobile
            [ flexDirection column
            , minHeight (px 0)
            , margin (px 0)
            ]
        ]


animationContainerStyle : Style
animationContainerStyle =
    Css.batch
        [ minHeight (pct 100)
        , alignItems center
        , displayFlex
        , Screen.style Screen.mobile
            [ justifyContent center
            , minHeight (px 0)
            , marginTop (px 0)
            ]
        ]
