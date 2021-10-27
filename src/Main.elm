module Main exposing (..)

import Bagheera.Object exposing (Link, LinkConnection, PageInfo)
import Bagheera.Object.Link as Link
import Bagheera.Object.LinkConnection as LinkConnection
import Bagheera.Object.LinkEdge as LinkEdge
import Bagheera.Object.PageInfo as PageInfo
import Bagheera.Query as Query
import Bagheera.Scalar exposing (LinkId(..))
import Browser
import Gql
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import InteropDefinitions
import InteropPorts
import Json.Decode as Decode
import Reader exposing (Reader)
import RemoteData as RD exposing (RemoteData(..))
import Svg
import Svg.Attributes as SvgAttr
import Task


linksQuery : Gql.Cursor -> SelectionSet (Maybe (Gql.Paginated (Maybe (List (Maybe (Maybe LinkData)))))) RootQuery
linksQuery cursor =
    Query.links
        (\optionals ->
            { optionals
                | first = Present 10
                , after = OptionalArgument.fromMaybe cursor
            }
        )
        linksSelection


linksSelection : SelectionSet (Gql.Paginated (Maybe (List (Maybe (Maybe LinkData))))) LinkConnection
linksSelection =
    SelectionSet.succeed Gql.Paginated
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


linksPageInfoSelection : SelectionSet Gql.CurrentPageInfo PageInfo
linksPageInfoSelection =
    SelectionSet.succeed Gql.CurrentPageInfo
        |> SelectionSet.with PageInfo.endCursor
        |> SelectionSet.with PageInfo.hasNextPage
        |> SelectionSet.with PageInfo.hasPreviousPage
        |> SelectionSet.with PageInfo.startCursor


makeRequest : Reader Gql.Env (Gql.Task (Maybe (Gql.Paginated (Maybe (List (Maybe (Maybe LinkData)))))))
makeRequest =
    Reader.Reader
        (\env ->
            linksQuery Nothing
                |> Graphql.Http.queryRequest env.endpoint
                |> Graphql.Http.withHeader "Authorization" "Bearer abcdefgh12345678"
                |> Graphql.Http.toTask
                |> Task.mapError (Graphql.Http.mapError <| always ())
        )



-- MODEL


type alias Model =
    { links : Gql.Response (Maybe (Gql.Paginated (Maybe (List (Maybe (Maybe LinkData))))))
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


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        env : Gql.Env
        env =
            { endpoint = "http://localhost:4000/graphql"
            }
    in
    case InteropPorts.decodeFlags flags of
        Err flagsError ->
            Debug.todo <| Debug.toString flagsError

        Ok _ ->
            ( { links = Loading
              , sortOption = ByCreatedAt
              }
            , Reader.run makeRequest env
                |> Task.attempt (RD.fromResult >> GotLinksResponse)
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    InteropPorts.toElm
        |> Sub.map
            (\toElm ->
                case toElm of
                    _ ->
                        NoOp
            )



-- UPDATE


type Msg
    = NoOp
      -- HTTP responses
    | GotLinksResponse (Gql.Response (Maybe (Gql.Paginated (Maybe (List (Maybe (Maybe LinkData)))))))
      -- User actions
    | SortLinks SortOptions
    | OpenExternalLink String


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
                    ( { model | sortOption = ByCreatedAt }, Cmd.none )

                ByVisits ->
                    ( { model | sortOption = ByVisits }, Cmd.none )

        OpenExternalLink externalLink ->
            ( model
            , externalLink
                |> InteropDefinitions.OpenExternalLink
                |> InteropPorts.fromElm
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


mkTestAttribute : String -> Attribute msg
mkTestAttribute key =
    Attr.attribute "data-testid" (String.toLower key)


viewLinkCard : LinkData -> Html Msg
viewLinkCard link =
    div [ Attr.class "tw-bg-skin-african-violet tw-rounded-md tw-p-4 tw-grid tw-grid-cols-3 tw-text-skin-base" ]
        [ div [ Attr.class "tw-flex tw-flex-col" ]
            [ span [] [ text ("https://localhost:4000/" ++ link.hash) ]
            , span [ Attr.class "tw-text-xs" ] [ text link.url ]
            ]
        , div [ Attr.class "tw-flex tw-justify-center tw-items-center" ]
            [ span [ Attr.class "tw-text-sm" ]
                [ text ("hits: " ++ (String.fromInt <| Maybe.withDefault 0 link.visits))
                ]
            ]
        , div [ Attr.class "tw-flex tw-space-x-3 tw-justify-end" ]
            [ button
                [ Attr.class "tw-border-none focus:tw-outline-none focus:tw-border-skin-mustard focus:tw-ring-mustard focus:tw-ring-2"
                , Events.onClick NoOp
                ]
                [ text "Edit" ]
            , button
                [ Attr.class "tw-border-none focus:tw-outline-none focus:tw-border-skin-mustard focus:tw-ring-mustard focus:tw-ring-2"
                , Events.onClick (OpenExternalLink link.url)
                ]
                [ text "View" ]
            , button
                [ Attr.class "tw-border-none focus:tw-outline-none focus:tw-border-skin-mustard focus:tw-ring-mustard focus:tw-ring-2"
                , Events.onClick NoOp
                ]
                [ text "Delete" ]
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
                [ div [ Attr.class "tw-flex tw-items-center" ]
                    [ h2 [ Attr.class "tw-font-serif tw-text-skin-base tw-prose-2xl" ]
                        [ text "My Links" ]
                    , button
                        [ mkTestAttribute "new-link-btn"
                        , Attr.class "tw-ml-8 tw-flex tw-items-center tw-bg-skin-hot-pink tw-px-3 tw-text-sm tw-text-skin-base tw-rounded-md tw-border-none focus:tw-outline-none focus:tw-border-skin-mustard focus:tw-ring-mustard focus:tw-ring-2 tw-h-9 focus:tw-drop-shadow-hot-pink hover:tw-drop-shadow-hot-pink hover:tw-transition"
                        , Events.onClick NoOp
                        ]
                        [ Svg.svg
                            [ SvgAttr.class "tw-mr-2 tw-text-skin-base"
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
                , label [ Attr.class "tw-hidden", Attr.for "sort-by-select" ] []
                , select
                    [ mkTestAttribute "sort-by-select"
                    , Attr.autocomplete False
                    , Attr.class "tw-text-skin-base tw-text-sm tw-bg-skin-maximum-blue tw-rounded-md tw-border-none focus:tw-border-skin-mustard focus:tw-ring-mustard focus:tw-ring-2 tw-cursor-pointer"
                    , Attr.id "sort-by-select"
                    , Attr.name "link-sort-options"
                    ]
                    [ option
                        [ Attr.value "createdAt"
                        , Events.onClick (SortLinks ByCreatedAt)
                        ]
                        [ text "Created" ]
                    , option
                        [ Attr.value "visits"
                        , Events.onClick (SortLinks ByVisits)
                        ]
                        [ text "Visits" ]
                    ]
                ]
            , viewLinks model
            ]
        ]
    }



-- MAIN


main : Program Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
