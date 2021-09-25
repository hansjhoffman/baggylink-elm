-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Bagheera.Interface.Node exposing (..)

import Bagheera.InputObject
import Bagheera.Interface
import Bagheera.Object
import Bagheera.Scalar
import Bagheera.ScalarCodecs
import Bagheera.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (FragmentSelectionSet(..), SelectionSet(..))
import Json.Decode as Decode


type alias Fragments decodesTo =
    { onLink : SelectionSet decodesTo Bagheera.Object.Link
    }


{-| Build an exhaustive selection of type-specific fragments.
-}
fragments :
    Fragments decodesTo
    -> SelectionSet decodesTo Bagheera.Interface.Node
fragments selections____ =
    Object.exhaustiveFragmentSelection
        [ Object.buildFragment "Link" selections____.onLink
        ]


{-| Can be used to create a non-exhaustive set of fragments by using the record
update syntax to add `SelectionSet`s for the types you want to handle.
-}
maybeFragments : Fragments (Maybe decodesTo)
maybeFragments =
    { onLink = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    }


{-| The ID of the object.
-}
id : SelectionSet Bagheera.ScalarCodecs.Id Bagheera.Interface.Node
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Bagheera.ScalarCodecs.codecs |> Bagheera.Scalar.unwrapCodecs |> .codecId |> .decoder)
