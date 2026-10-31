port module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation exposing (Key)
import Cmd.Extra exposing (addCmd, withCmd, withCmds, withNoCmd)
import Html exposing (Html)
import Html.Events
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import Task
import Time
import Url exposing (Url)
import WebXR
import WebXR.PortDispatch as PortDispatch
import WebXR.Types exposing (Command(..), Config, SessionType(..))


type alias ReturnFunction =
    WrappedModel -> Value -> ( WrappedModel, Cmd Msg )


type alias Model =
    { config : Config Msg
    , webxrIsAvailable : Bool
    , returnFunction : WrappedModel -> Value -> ( WrappedModel, Cmd Msg )
    , url : Url
    , key : Key
    }


type WrappedModel
    = WrappedModel Model


nullReturnFunction : WrappedModel -> Value -> ( WrappedModel, Cmd Msg )
nullReturnFunction wm v =
    ( wm, Cmd.none )


isAvailableReturnFunction : WrappedModel -> Value -> ( WrappedModel, Cmd Msg )
isAvailableReturnFunction wm v =
    let
        vv =
            Debug.log "  isAvailableReturnFunction" v
    in
    ( wm, Cmd.none )


type Msg
    = Nop
    | OnUrlRequest UrlRequest
    | OnUrlChange Url
    | InPort Value


port webXROut : Value -> Cmd msg


port webXRIn : (Value -> msg) -> Sub msg


port openWindow : Value -> Cmd msg


init : Value -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { config =
                { outPort = webXROut
                , inPort = webXRIn
                }
            , webxrIsAvailable = False
            , returnFunction = nullReturnFunction
            , url = url
            , key = key
            }
    in
    send model isAvailableReturnFunction IsWebXRAvailable JE.null


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InPort value ->
            let
                v =
                    Debug.log "InPort" value

                ( WrappedModel mdl, cmd ) =
                    model.returnFunction (WrappedModel model) value
            in
            ( mdl, cmd )

        Nop ->
            ( model, Cmd.none )

        OnUrlChange url ->
            model |> withNoCmd

        OnUrlRequest urlRequest ->
            case urlRequest of
                External url ->
                    model |> withCmd (openWindow <| JE.string url)

                Internal url ->
                    model |> withNoCmd


view : Model -> Document Msg
view model =
subscriptions : Model -> Sub Msg
subscriptions model =
    -- TODO
    Sub.batch
        [ model.config.inPort InPort ]


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }


send : Model -> ReturnFunction -> Command -> Value -> ( Model, Cmd Msg )
send model returnFunction command value =
    ( { model | returnFunction = returnFunction }
    , PortDispatch.dispatch model.config command value
    )
