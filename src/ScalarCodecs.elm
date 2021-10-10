module ScalarCodecs exposing (..)

import Bagheera.Scalar exposing (defaultCodecs)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Id =
    Bagheera.Scalar.Id


type alias LinkId =
    Bagheera.Scalar.LinkId


codecs : Bagheera.Scalar.Codecs Id LinkId
codecs =
    Bagheera.Scalar.defineCodecs
        { codecId = defaultCodecs.codecId
        , codecLinkId =
            { encoder = \(Bagheera.Scalar.LinkId raw) -> Encode.string raw
            , decoder = Decode.string |> Decode.map Bagheera.Scalar.LinkId
            }
        }
