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
import WebXR.PortDispatch
import WebXR.Types exposing (Command(..), Config, SessionType(..))


type alias Model =
    { config : Config Msg
    , url : Url
    , key : Key
    }


type Msg
    = Nop
    | OnUrlRequest UrlRequest
    | OnUrlChange Url


port webXROut : Value -> Cmd msg


port webXRIn : (Value -> msg) -> Sub msg


port openWindow : Value -> Cmd msg


init : Value -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    { config =
        { outPort = webXROut
        , inPort = webXRIn
        }
    , url = url
    , key = key
    }
        |> withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnUrlChange url ->
            model |> withNoCmd

        OnUrlRequest urlRequest ->
            case urlRequest of
                External url ->
                    model |> withCmd (openWindow <| JE.string url)

                Internal url ->
                    model |> withNoCmd

        Nop ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "WebXR Example"
    , body =
        [ Html.text "Hello, World!"
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    -- TODO
    Sub.none


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }
