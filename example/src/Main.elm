port module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation exposing (Key)
import Cmd.Extra exposing (addCmd, withCmd, withCmds, withNoCmd)
import Html exposing (Html)
import Html.Events
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import Task
import Time
import Url exposing (Url)
import WebXR
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


logValue : String -> Value -> Value
logValue label value =
    let
        json =
            Debug.log label (JE.encode 0 value)
    in
    value


isAvailableReturnFunction : WrappedModel -> Value -> ( WrappedModel, Cmd Msg )
isAvailableReturnFunction wm v =
    let
        vv =
            logValue "isAvailableReturnFunction" v
    in
    case wm of
        WrappedModel model ->
            case WebXR.decodeReturnValue vv of
                Err { error } ->
                    let
                        error2 =
                            Debug.log "  Error" error
                    in
                    wm |> withNoCmd

                Ok { value } ->
                    let
                        bool =
                            case JD.decodeValue JD.bool value of
                                Err _ ->
                                    False

                                Ok b ->
                                    b
                    in
                    WrappedModel { model | webxrIsAvailable = bool }
                        -- TODO
                        |> withNoCmd


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
    { model | returnFunction = isAvailableReturnFunction }
        |> withCmd (WebXR.isWebXRAvailable model.config)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InPort value ->
            let
                ( WrappedModel mdl, cmd ) =
                    model.returnFunction (WrappedModel model) value
            in
            mdl |> withCmd cmd

        Nop ->
            model |> withNoCmd

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
    { title = "WebXR Example"
    , body =
        [ Html.text <|
            if model.webxrIsAvailable then
                "WebXR IS available."

            else
                "WebXR is NOT available."
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
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
