module InteropDefinitions exposing (Flags, FromElm, ToElm, interop)

import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder, optional, required)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }


type FromElm
    = Alert String


type alias ToElm =
    ()


type alias Flags =
    ()


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vAlert value ->
            case value of
                Alert string ->
                    vAlert string
        )
        |> TsEncode.variantTagged "alert"
            (TsEncode.object [ required "message" identity TsEncode.string ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.null ()


flags : Decoder Flags
flags =
    TsDecode.null ()
