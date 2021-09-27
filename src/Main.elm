module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Svg exposing (path, svg)
import Svg.Attributes as Svg


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
    form [ class "tw-relative tw-mb-6" ]
        [ svg
            [ Svg.class "tw-absolute tw-left-3 tw-top-1/2 tw-transform tw--translate-y-1/2 tw-text-gray-400"
            , Svg.fill "currentColor"
            , Svg.height "20"
            , Svg.width "20"
            , Svg.version "1.1"
            , Svg.viewBox "0 0 20 20"
            ]
            [ path
                [ Svg.clipRule "evenodd"
                , Svg.fillRule "evenodd"
                , Svg.d "M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                ]
                []
            ]
        , input
            [ attribute "aria-label" "Filter Links"
            , class "tw-w-full tw-text-sm tw-text-black tw-placeholder-gray-500 tw-border tw-border-gray-200 tw-rounded-md focus:tw-ring-1 focus:tw-border-blue-500 focus:tw-ring-blue-500 tw-py-2 tw-px-10"
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
        [ section [ class "tw-w-1/2 tw-mx-auto" ]
            [ header [ class "tw-flex tw-items-center tw-justify-between tw-mb-6" ]
                [ h2 [ class "tw-prose-xl" ] [ text "Links" ]
                , button
                    [ class "tw-group tw-flex tw-items-center tw-bg-blue-300 hover:tw-bg-blue-400 tw-rounded-md tw-text-blue-600 hover:tw-text-blue-800 tw-text-sm tw-font-medium tw-px-4 tw-py-2"
                    , onClick NoOp
                    ]
                    [ svg
                        [ Svg.class "tw-mr-2 tw-text-blue-500"
                        , Svg.fill "currentColor"
                        , Svg.height "20"
                        , Svg.width "12"
                        , Svg.version "1.1"
                        , Svg.viewBox "0 0 12 20"
                        ]
                        [ path
                            [ Svg.clipRule "evenodd"
                            , Svg.fillRule "evenodd"
                            , Svg.d "M6 5a1 1 0 011 1v3h3a1 1 0 110 2H7v3a1 1 0 11-2 0v-3H2a1 1 0 110-2h3V6a1 1 0 011-1z"
                            ]
                            []
                        ]
                    , text "New"
                    ]
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
