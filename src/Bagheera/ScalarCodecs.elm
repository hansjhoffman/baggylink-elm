-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Bagheera.ScalarCodecs exposing (..)

import Bagheera.Scalar exposing (defaultCodecs)
import Json.Decode as Decode exposing (Decoder)


type alias Id =
    Bagheera.Scalar.Id


codecs : Bagheera.Scalar.Codecs Id
codecs =
    Bagheera.Scalar.defineCodecs
        { codecId = defaultCodecs.codecId
        }
