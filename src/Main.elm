module Main exposing (..)

import Bagheera.Object exposing (Link, LinkConnection, PageInfo)
import Bagheera.Object.Link as Link
import Bagheera.Object.LinkConnection as LinkConnection
import Bagheera.Object.LinkEdge as LinkEdge
import Bagheera.Object.PageInfo as PageInfo
import Bagheera.Query as Query
import Bagheera.ScalarCodecs exposing (LinkId)
import Browser
import Gql exposing (..)
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import RemoteData
import Svg exposing (path, svg)
import Svg.Attributes as Svg
import Task


linksQuery : Cursor -> SelectionSet (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData)))))) RootQuery
linksQuery cursor =
    Query.links
        (\optionals ->
            { optionals
                | first = Present 10
                , after = OptionalArgument.fromMaybe cursor
            }
        )
        linksSelection


linksSelection : SelectionSet (Paginated (Maybe (List (Maybe (Maybe LinkData))))) LinkConnection
linksSelection =
    SelectionSet.succeed Paginated
        |> with linksEdgesSelection
        |> with (LinkConnection.pageInfo linksPageInfoSelection)


linksEdgesSelection : SelectionSet (Maybe (List (Maybe (Maybe LinkData)))) LinkConnection
linksEdgesSelection =
    LinkConnection.edges (LinkEdge.node linksNodeSelection)


linksNodeSelection : SelectionSet LinkData Link
linksNodeSelection =
    SelectionSet.map4 LinkData
        Link.hash
        Link.id
        Link.url
        Link.visits


linksPageInfoSelection : SelectionSet CurrentPageInfo PageInfo
linksPageInfoSelection =
    SelectionSet.succeed CurrentPageInfo
        |> with PageInfo.endCursor
        |> with PageInfo.hasNextPage
        |> with PageInfo.hasPreviousPage
        |> with PageInfo.startCursor


makeRequest : GqlTask (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData))))))
makeRequest =
    linksQuery Nothing
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withHeader "Authorization" "Bearer abcdefgh12345678"
        |> Graphql.Http.toTask
        |> Task.mapError (Graphql.Http.mapError <| always ())



-- MODEL


type alias Model =
    { links : GqlResponse (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData)))))) }


type alias LinkData =
    { hash : String
    , id : LinkId
    , url : String
    , visits : Maybe Int
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { links = RemoteData.Loading }
    , makeRequest |> Task.attempt (RemoteData.fromResult >> GotLinksResponse)
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = NoOp
    | GotLinksResponse (GqlResponse (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData)))))))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotLinksResponse response ->
            ( { model | links = response }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


mkTestAttribute : String -> Attribute msg
mkTestAttribute key =
    attribute "data-testid" (String.toLower key)


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
            , mkTestAttribute "filter-link-input"
            , class "tw-w-full tw-text-sm tw-text-black tw-placeholder-gray-500 tw-border tw-border-gray-200 tw-rounded-md focus:tw-ring-1 focus:tw-border-blue-500 focus:tw-ring-blue-500 tw-py-2 tw-px-10"
            , onInput (\_ -> NoOp)
            , placeholder "Filter Links"
            , type_ "text"
            ]
            []
        ]


viewLinkCard : LinkData -> Html msg
viewLinkCard link =
    li [] [ text link.hash ]


viewLinks : Model -> Html msg
viewLinks model =
    case model.links of
        RemoteData.NotAsked ->
            div [] [ text "not asked" ]

        RemoteData.Loading ->
            div [] [ text "loading" ]

        RemoteData.Success _ ->
            ul [] [ text "yay!" ]

        RemoteData.Failure _ ->
            div [] [ text "failure :(" ]


view : Model -> Browser.Document Msg
view model =
    { title = "Baggylinks"
    , body =
        [ section [ class "tw-w-1/2 tw-mx-auto" ]
            [ header [ class "tw-flex tw-items-center tw-justify-between tw-mb-6" ]
                [ h2 [ class "tw-prose-xl" ] [ text "Links" ]
                , button
                    [ mkTestAttribute "new-link-btn"
                    , class "tw-group tw-flex tw-items-center tw-bg-blue-300 hover:tw-bg-blue-400 tw-rounded-md tw-text-blue-600 hover:tw-text-blue-800 tw-text-sm tw-font-medium tw-px-4 tw-py-2"
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
            , viewLinks model
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
