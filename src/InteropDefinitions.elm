module InteropDefinitions exposing (Flags, FromElm, ToElm, interop)

{-| This is the file home for all ports. Be sure to re-generate the TypeScript
declaration file `src/Main.elm.d.ts` and `src/InteropPorts.elm` for development
when changes are made to this file.
-}

import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder)


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
            (TsEncode.object [ TsEncode.required "url" identity TsEncode.string ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.null ()


flags : Decoder Flags
flags =
    TsDecode.null ()
