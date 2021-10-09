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
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import RemoteData as RD exposing (RemoteData(..))
import Svg
import Svg.Attributes as SvgAttr
import Task as T


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
        |> SelectionSet.with linksEdgesSelection
        |> SelectionSet.with (LinkConnection.pageInfo linksPageInfoSelection)


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
        |> SelectionSet.with PageInfo.endCursor
        |> SelectionSet.with PageInfo.hasNextPage
        |> SelectionSet.with PageInfo.hasPreviousPage
        |> SelectionSet.with PageInfo.startCursor


makeRequest : GqlTask (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData))))))
makeRequest =
    linksQuery Nothing
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withHeader "Authorization" "Bearer abcdefgh12345678"
        |> Graphql.Http.toTask
        |> T.mapError (Graphql.Http.mapError <| always ())



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
    ( { links = Loading }
    , makeRequest |> T.attempt (RD.fromResult >> GotLinksResponse)
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
    Attr.attribute "data-testid" (String.toLower key)


viewLinkCard : LinkData -> Html msg
viewLinkCard link =
    li [] [ text link.hash ]


viewLinks : Model -> Html msg
viewLinks model =
    case model.links of
        NotAsked ->
            div [] [ text "not asked" ]

        Loading ->
            div [] [ text "loading" ]

        Success _ ->
            ul [] [ text "yay!" ]

        Failure _ ->
            div [] [ text "failure :(" ]


view : Model -> Browser.Document Msg
view model =
    { title = "Baggylinks"
    , body =
        [ section [ Attr.class "tw-w-1/2 tw-mx-auto" ]
            [ header [ Attr.class "tw-flex tw-items-center tw-justify-between tw-mb-6" ]
                [ h2 [ Attr.class "tw-prose-xl" ] [ text "Links" ]
                , button
                    [ mkTestAttribute "new-link-btn"
                    , Attr.class "tw-group tw-flex tw-items-center tw-bg-blue-300 hover:tw-bg-blue-400 tw-rounded-md tw-text-blue-600 hover:tw-text-blue-800 tw-text-sm tw-font-medium tw-px-4 tw-py-2"
                    , Events.onClick NoOp
                    ]
                    [ Svg.svg
                        [ SvgAttr.class "tw-mr-2 tw-text-blue-500"
                        , SvgAttr.fill "currentColor"
                        , SvgAttr.height "20"
                        , SvgAttr.width "12"
                        , SvgAttr.version "1.1"
                        , SvgAttr.viewBox "0 0 12 20"
                        ]
                        [ Svg.path
                            [ SvgAttr.clipRule "evenodd"
                            , SvgAttr.fillRule "evenodd"
                            , SvgAttr.d "M6 5a1 1 0 011 1v3h3a1 1 0 110 2H7v3a1 1 0 11-2 0v-3H2a1 1 0 110-2h3V6a1 1 0 011-1z"
                            ]
                            []
                        ]
                    , text "New"
                    ]
                ]
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
