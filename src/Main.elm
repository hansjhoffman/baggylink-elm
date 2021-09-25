module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)


endpoint : String
endpoint =
    "http://localhost:/4000/graphql"



-- MODEL


type alias Model =
    Int


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( 1, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )



-- VIEW


viewFilterInput : Html Msg
viewFilterInput =
    form [ class "tw-relative" ]
        [ input
            [ class "tw-w-full"
            , class "tw-text-sm tw-text-black"
            , class "tw-placeholder-gray-500"
            , class "tw-border tw-border-gray-200"
            , class "tw-rounded-md"
            , class "tw-py-2"
            , class "tw-pl-10"
            , onInput (\_ -> NoOp)
            , placeholder "Filter Links"
            , type_ "text"
            ]
            []
        ]


viewLinkCard : Html msg
viewLinkCard =
    li [] []


view : Model -> Browser.Document Msg
view _ =
    { title = "Baggylinks"
    , body =
        [ section [ class "tw-w-1/2", class "tw-mx-auto" ]
            [ header [ class "tw-flex", class "tw-justify-between", class "tw-align-center" ]
                [ h2 [ class "tw-prose-xl" ] [ text "Links" ]
                , button
                    [ class "tw-bg-blue-300 hover:tw-bg-blue-400"
                    , class "tw-rounded-md"
                    , class "tw-text-blue-600 hover:tw-text-blue-800"
                    , class "tw-text-sm tw-font-medium"
                    , class "tw-px-4 tw-py-2"
                    , onClick NoOp
                    ]
                    [ text "+ New" ]
                ]
            , viewFilterInput
            , ul [] []
            ]
        ]
    }



-- MAIN


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
