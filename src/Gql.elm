module Gql exposing (..)

import Graphql.Http
import RemoteData exposing (RemoteData)
import Task exposing (Task)


endpoint : String
endpoint =
    "http://localhost:4000/graphql"


type alias Paginated a =
    { data : a
    , pageInfo : CurrentPageInfo
    }


type alias CurrentPageInfo =
    { endCursor : Cursor
    , hasNextPage : Bool
    , hasPreviousPage : Bool
    , startCursor : Cursor
    }


type alias Cursor =
    Maybe String


{-| elm-graphql allows also to get some "possibly recovered data",
but we don't care, that's why we have a Unit type as a parameter to Error.
-}
type alias GqlResponse a =
    RemoteData (Graphql.Http.Error ()) a


type alias GqlTask t =
    Task (Graphql.Http.Error ()) t
