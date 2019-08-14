module Data.Personalize exposing (Row, Visit, encodeVisit, pushVisit, visit, visitDecoder)

import Data.Author as Author exposing (Author)
import Data.Post as Post exposing (Core, Full, Post, Preview)
import Data.Tag as Tag exposing (Tag)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import List.Extra



{- Model -}


type Visit
    = Visit VisitInternals


type alias VisitInternals =
    { author : UUID
    , tags : List UUID
    , uuid : UUID
    }


type Personalization
    = ByAuthor Author
    | ByTag Tag
    | ByRecent


type alias Result =
    { weight : Weight
    , personalization : Personalization
    }


type alias Row =
    {}



{- Constructors -}


visit : Post Core Full -> Visit
visit post =
    let
        internals =
            { author = Post.author post
            , tags = Post.tags post
            , uuid = Post.uuid post
            }
    in
    Visit internals



{- Public API -}


personalize : List Visit -> List Author -> List Tag -> List (Post Core Preview) -> List Row
personalize history validAuthors validTags posts =
    [ {} ]



{- Helpers -}


results : List Visit -> List Result
results history =



type alias Weight =
    Float


rankIndex : Int -> Int -> Weight
rankIndex index max =
    toFloat index / toFloat max * 100



{-
   1) weights for each tag
   2) weights for each author
   3) weight for "new" (how to normalize w/ tag/author)
-}


rankWeights : List Weight -> Weight
rankWeights weights =
    weights
        |> List.sum


pushVisit : Visit -> Int -> List Visit -> List Visit
pushVisit v max list =
    let
        (Visit internals) =
            v

        predicate (Visit el) =
            UUID.compare el.uuid internals.uuid

        maybeExisting =
            List.Extra.find predicate list

        updatedList =
            case maybeExisting of
                Just existing ->
                    v :: List.Extra.remove existing list

                Nothing ->
                    v :: list
    in
    List.take max updatedList



{- JSON -}


encodeVisit : Visit -> Value
encodeVisit (Visit internals) =
    Encode.object
        [ ( "author", UUID.encode internals.author )
        , ( "tags", Encode.list UUID.encode internals.tags )
        , ( "uuid", UUID.encode internals.uuid )
        ]


visitDecoder : Decoder Visit
visitDecoder =
    Decode.succeed VisitInternals
        |> required "author" UUID.decoder
        |> required "tags" (Decode.list UUID.decoder)
        |> required "uuid" UUID.decoder
        |> Decode.map Visit
