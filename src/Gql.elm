module Gql exposing (..)

import Graphql.Http
import RemoteData exposing (RemoteData)


endpoint : String
endpoint =
    "http://localhost:4000/graphql"


type alias Paginated a =
    { data : a
    , pageInfo : PageInfo
    }


type alias PageInfo =
    { endCursor : Cursor
    , hasNextPage : Bool
    , hasPreviousPage : Bool
    , startCursor : Cursor
    }


type alias Cursor =
    Maybe String


type alias GqlResponse a =
    RemoteData (Graphql.Http.Error a) a
