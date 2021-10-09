module Main exposing (..)

import Bagheera.Object exposing (Link, LinkConnection, PageInfo)
import Bagheera.Object.Link as Link
import Bagheera.Object.LinkConnection as LinkConnection
import Bagheera.Object.LinkEdge as LinkEdge
import Bagheera.Object.PageInfo as PageInfo
import Bagheera.Query as Query
import Bagheera.Scalar exposing (LinkId(..))
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
        |> Task.mapError (Graphql.Http.mapError <| always ())



-- MODEL


type alias Model =
    { links : GqlResponse (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData))))))
    , sortOption : SortOptions
    }


type alias LinkData =
    { hash : String
    , id : LinkId
    , url : String
    , visits : Maybe Int
    }


type SortOptions
    = ByCreatedAt
    | ByVisits


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { links = Loading
      , sortOption = ByCreatedAt
      }
    , makeRequest |> Task.attempt (RD.fromResult >> GotLinksResponse)
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = NoOp
    | GotLinksResponse (GqlResponse (Maybe (Paginated (Maybe (List (Maybe (Maybe LinkData)))))))
    | SortLinks SortOptions


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotLinksResponse response ->
            ( { model | links = response }
            , Cmd.none
            )

        SortLinks sortOption ->
            case sortOption of
                ByCreatedAt ->
                    ( model, Cmd.none )

                ByVisits ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


mkTestAttribute : String -> Attribute msg
mkTestAttribute key =
    Attr.attribute "data-testid" (String.toLower key)


viewLinkCard : LinkData -> Html Msg
viewLinkCard link =
    div [ Attr.class "tw-bg-red-300 tw-rounded-md tw-p-4" ]
        [ text ("https://localhost:4000/" ++ link.hash)
        , span [] [ text "hits:" ]
        , span [] [ text (String.fromInt <| Maybe.withDefault 0 link.visits) ]
        , div [ Attr.class "tw-flex tw-space-x-3" ]
            [ button [ Events.onClick NoOp ] [ text "Edit" ]
            , button [ Events.onClick NoOp ] [ text "View" ]
            , button [ Events.onClick NoOp ] [ text "Delete" ]
            ]
        ]


viewLinks : Model -> Html Msg
viewLinks model =
    let
        mockLinks : List LinkData
        mockLinks =
            [ { hash = "abcd123"
              , id = LinkId "1234"
              , url = "http://www.youtube.com"
              , visits = Just 42
              }
            , { hash = "abcd456"
              , id = LinkId "1234"
              , url = "http://www.google.com"
              , visits = Nothing
              }
            , { hash = "abcd789"
              , id = LinkId "1234"
              , url = "http://www.amazon.com"
              , visits = Just 14
              }
            , { hash = "abcd001"
              , id = LinkId "1234"
              , url = "http://www.alibaba.com"
              , visits = Nothing
              }
            ]
    in
    case model.links of
        NotAsked ->
            div [] [ text "not asked" ]

        Loading ->
            div [] [ text "loading" ]

        Success _ ->
            div [ Attr.class "tw-space-y-8" ] (List.map viewLinkCard mockLinks)

        Failure _ ->
            div [] [ text "failure :(" ]


view : Model -> Browser.Document Msg
view model =
    { title = "Baggylinks"
    , body =
        [ section [ Attr.class "tw-w-1/2 tw-mx-auto tw-mt-20" ]
            [ header [ Attr.class "tw-flex tw-items-center tw-justify-between tw-mb-14" ]
                [ div [ Attr.class "tw-flex" ]
                    [ h2 [ Attr.class "tw-font-sans tw-font-semibold tw-prose tw-prose-2xl" ]
                        [ text "My Links" ]
                    , button
                        [ mkTestAttribute "new-link-btn"
                        , Attr.class "tw-group tw-flex tw-items-center tw-text-sm tw-font-medium tw-px-4 tw-py-2"
                        , Events.onClick NoOp
                        ]
                        [ Svg.svg
                            [ SvgAttr.class "tw-mr-2 tw-text-blue-500"
                            , SvgAttr.fill "currentColor"
                            , SvgAttr.height "20"
                            , SvgAttr.width "12"
                            , SvgAttr.version "1.1"
                            , SvgAttr.viewBox "0 0 12 22"
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
                , select
                    [ mkTestAttribute "sort-by-select"
                    , Attr.autocomplete False
                    , Attr.class "tw-border-none"
                    , Attr.name "link-sort-options"
                    ]
                    [ option [ Events.onClick (SortLinks ByCreatedAt) ] [ text "Created" ]
                    , option [ Events.onClick (SortLinks ByVisits) ] [ text "Visits" ]
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
