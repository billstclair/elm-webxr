port module Main exposing (..)

import Browser
import Html exposing (Html)
import Html.Events
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import Task
import Time
import WebXR.PortDispatch exposing (Command(..), Config, SessionType(..))


type alias Model =
    { config : Config Msg }


type Msg
    = Nop


port outPort : Value -> Cmd msg


port inPort : (Value -> msg) -> Sub msg


init : Value -> ( Model, Cmd Msg )
init _ =
    ( { config =
            { outPort = outPort
            , inPort = inPort
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.text "Hello, World!"


subscriptions : Model -> Sub Msg
subscriptions model =
    -- TODO
    Sub.none


port webXRIn : Value -> Cmd msg


port webXROut : (Value -> msg) -> Sub msg


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
