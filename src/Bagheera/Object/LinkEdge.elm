-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Bagheera.Object.LinkEdge exposing (..)

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
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


cursor : SelectionSet (Maybe String) Bagheera.Object.LinkEdge
cursor =
    Object.selectionForField "(Maybe String)" "cursor" [] (Decode.string |> Decode.nullable)


node :
    SelectionSet decodesTo Bagheera.Object.Link
    -> SelectionSet (Maybe decodesTo) Bagheera.Object.LinkEdge
node object____ =
    Object.selectionForCompositeField "node" [] object____ (Basics.identity >> Decode.nullable)
