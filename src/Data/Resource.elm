module Data.Resource exposing (Resource, State(..), init, resource, update)


import Json.Decode exposing (Decoder)
import Http exposing (Error)
import Api
import Data.Mode exposing (Mode)
import Task
import Process


type Resource r =
    Resource (IResource r)


type alias IResource r =
    { resource : State r
    , attempts : Int
    , decoder : Decoder r
    , mode : Mode
    }


type State r
    = Pending
    | Loaded r
    | Failed Error


type Msg r
    = OnFetch (Result Error r)
    | Fetch 


update : Msg r -> Resource r -> ( Resource r, Cmd (Msg r) )
update msg (Resource ({ attempts } as internals)) =
    case msg of
        OnFetch result ->
            case result of
               Ok r ->
                   ( Resource { internals | resource = Loaded r }
                   , Cmd.none
                   )

               Err err ->
                   if attempts >= maxRetry then
                       ( Resource { internals | resource = Failed err }
                       , Cmd.none
                       )

                   else
                       let
                           updatedInternals =
                               { internals  | attempts = attempts + 1 }
                       in
                       ( Resource updatedInternals
                       , Task.perform (always Fetch) <| Process.sleep sleepTime
                       )


        Fetch ->
            ( Resource internals
            , fetch internals
            )



init : Mode -> Decoder r -> ( Resource r, Cmd (Msg r) )
init mode decoder =
    (
        { resource = Pending
        , attempts = 0
        , decoder = decoder
        , mode = mode
        } |> Resource
    , Cmd.none
    )


maxRetry : Int
maxRetry =
    3


sleepTime : Float
sleepTime =
    100


fetch : IResource r -> Cmd (Msg r)
fetch ({ mode, decoder }) =
    Api.get
        { expect = Http.expectJson OnFetch decoder
        , url = Api.url mode ""
        }

resource : Resource r -> State r
resource (Resource internals) =
    internals.resource
