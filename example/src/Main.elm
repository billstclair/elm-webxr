port module Main exposing (..)

import Browser
import Html exposing (Html)
import Html.Events
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import Task
import Time


type alias Model =
    { filler : Int }


type Msg
    = Nop


init : Value -> ( Model, Cmd Msg )
init _ =
    ( { filler = 0 }
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
