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
    = OpenExternalLink String


type alias ToElm =
    ()


type alias Flags =
    ()


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vExternalLink value ->
            case value of
                OpenExternalLink string ->
                    vExternalLink string
        )
        |> TsEncode.variantTagged "openExternalLink"
            (TsEncode.object [ required "url" identity TsEncode.string ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.null ()


flags : Decoder Flags
flags =
    TsDecode.null ()
