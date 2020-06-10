module Action exposing (Action, ActionSet, discover, perform, performGratis, performGratisWith, performWith, decoder)

{-| An Action is a **verb** that can be performed to change application state
and is driven by an outside force. Currently this driver is driven by a HATEOAS
API in the form of the **Blog Core** Api.

This means the client doesn't need to know what endpoints it is hitting, or
what actions are permitted when. It only needs to know how to discover the
**Root Actions** that are supported by the API.


# Example


## (Logged Out)

We want to build a Post page, to display and allow interaction with the "post"
resource. When the application starts, we send a request to discover the **Root
Actions** that are supported, and find one of them is for "posts".

We find that we only have access to the `index` action, which allows us to request
a list of posts from the backend.

We perform the `index` action and get back a list of posts, each with a list of actions
associated with them. We look at the first one and see it has a `show` action, which allows
us to view the entire post (as opposed to just the preview).

We perform the `show` action, and get back the full post (with a body), and another list of
actions. It includes an `index` option for the tags, and a `show` action for the author.


## (Logged In)

When the application starts, we again send a request to discover the **Root Actions**. We
discover this time we have some additional actions, a `post#create` and a `logout` action.
We are also missing actions from before, the `login` action is missing.

We again `index` the posts, and receive a list of previews. This time the list is longer,
as it includes some of our unpublished posts. We look at one of these unpublished posts,
and see that it includes several actions the posts not authored by us are missing. For
instance, it has a `delete` action, along with the `author#show` and `tags#index` actions
we had before.


## UI

Whether or not the UI chooses to display certain elements is dictated by what actions exist
on a resource. For example, when on the home page, posts with the `post#delete` action
show a trash can on the post preview, allowing the user to delete it. We might assume this
would only be available to the author, but this way we don't have to make assumptions. If
the action exists, show it. If not, don't show it. In this way, instead of this logic
being duplicated across our backend and frontend, we let this be driven entirely by the
backend.

Other examples are when the login/logout buttons are shown. If the root actions include
`login`, show the login button. Else if the root actions include `logout`, show the logout
button.


## Edge Cases

There are times when what actions are available will change throughout the life of the
application. For example when we login, this changes the actions that are available for
posts, and even changes the root actions (there is now a logout action). Because this is
a simple application, we can get away with pushing these kinds of actions to their own page
(i.e login/logout), and forcing the re-discovery of the root actions. I am unsure what the
correct (and easiest) solution would be for applications with more fine-grained permissions.

-}

import Data.Mode as Mode exposing (Env(..), Mode(..))
import Http exposing (Body, Error(..), Header, Resolver, Response)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode exposing (Value)
import Task exposing (Task)
import Url exposing (Url)


type Action
    = Action IAction


type alias IAction =
    { method : String
    , href : Url
    }


type alias RootActions =
    { posts : ActionSet
    , tags : ActionSet
    , authors : ActionSet
    , login : Maybe Action
    , logout : Maybe Action
    }


type alias ActionSet =
    { index : Action
    , create : Maybe Action
    }


perform : Mode -> Decoder a -> Action -> Task Http.Error a
perform mode aDecoder (Action { href, method }) =
    Http.riskyTask
        { method = method
        , body = Http.emptyBody
        , url = Url.toString href
        , headers = headers mode
        , timeout = Nothing
        , resolver = Http.stringResolver <| handleJsonResponse <| aDecoder
        }


performWith : Mode -> Value -> Decoder a -> Action -> Task Http.Error a
performWith mode body aDecoder (Action { href, method }) =
    Http.riskyTask
        { method = method
        , body = Http.jsonBody body
        , url = Url.toString href
        , headers = headers mode
        , timeout = Nothing
        , resolver = Http.stringResolver <| handleJsonResponse <| aDecoder
        }


performGratis : Mode -> Action -> Task Http.Error ()
performGratis mode (Action { href, method }) =
    Http.riskyTask
        { method = method
        , body = Http.emptyBody
        , url = Url.toString href
        , headers = headers mode
        , timeout = Nothing
        , resolver = resolveWhatever
        }


performGratisWith : Mode -> Value -> Action -> Task Http.Error ()
performGratisWith mode body (Action { href, method }) =
    Http.riskyTask
        { method = method
        , body = Http.jsonBody body
        , url = Url.toString href
        , headers = headers mode
        , timeout = Nothing
        , resolver = resolveWhatever
        }


discover : Mode -> Task Http.Error RootActions
discover mode =
    perform mode rootDecoder (discoverAction mode)



{- Json -}


rootDecoder : Decoder RootActions
rootDecoder =
    Decode.succeed RootActions
        |> required "posts" actionSetDecoder
        |> required "tags" actionSetDecoder
        |> required "authors" actionSetDecoder
        |> required "login" (Decode.maybe decoder)
        |> required "logout" (Decode.maybe decoder)


actionSetDecoder : Decoder ActionSet
actionSetDecoder =
    Decode.succeed ActionSet
        |> required "index" decoder
        |> required "create" (Decode.maybe decoder)


decoder : Decoder Action
decoder =
    Decode.succeed IAction
        |> required "method" Decode.string
        |> required "href" hrefDecoder
        |> Decode.map Action


hrefDecoder : Decoder Url
hrefDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case Url.fromString str of
                    Just url ->
                        Decode.succeed url

                    Nothing ->
                        Decode.fail <| "failed to decode url: " ++ str
            )



-- Helpers --


resolveWhatever : Resolver Http.Error ()
resolveWhatever =
    Http.bytesResolver <| resolve (\_ -> Ok ())


resolve : (body -> Result String a) -> Response body -> Result Http.Error a
resolve toResult response =
    case response of
        Http.BadUrl_ url ->
            Err (BadUrl url)

        Http.Timeout_ ->
            Err Timeout

        Http.NetworkError_ ->
            Err NetworkError

        Http.BadStatus_ metadata _ ->
            Err (BadStatus metadata.statusCode)

        Http.GoodStatus_ _ body ->
            Result.mapError BadBody (toResult body)


discoverAction : Mode -> Action
discoverAction mode =
    Action { method = "GET", href = Mode.toUrl mode }


headers : Mode -> List Header
headers mode =
    case Mode.toEnv mode of
        Dev ->
            []

        Prod ->
            []


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse aDecoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Decode.decodeString aDecoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result
