--------------------------------------------------------------------
--
-- WebXR.elm
-- Elm interface the WebXR JavaScript library
-- (https://developer.mozilla.org/en-US/docs/Web/API/WebXR_Device_API).
-- Copyright (c) 2026 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------


module WebXR exposing
    ( isWebXRAvailable, isSessionSupported, requestSession
    , ReturnValue, ReturnValueCommand, ReturnError
    , decodeReturnValue
    )

{-| Elm interface to the WebXR JavaScript library.

@docs isWebXRAvailable, isSessionSupported, requestSession

The `Value` sent from the JS to `Config.inPort`.

@docs ReturnValue, ReturnValueCommand, ReturnError
@docs decodeReturnValue

-}

import Dict exposing (Dict)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as DP exposing (custom, hardcoded, optional, required)
import Json.Encode as JE exposing (Value)
import WebXR.PortDispatch as PortDispatch
import WebXR.Types exposing (Command(..), Config, SessionType(..))


type XRError
    = IllegalSessionRequest String
    | XRErrorString String


{-| True if the browser supports WebXR.
-}
isWebXRAvailable : Config msg -> Cmd msg
isWebXRAvailable config =
    PortDispatch.dispatch config IsWebXRAvailable JE.null


{-| True if the WebXR implementation currently supports the given SessionType.

If true, `requestSession` will succeed.

-}
isSessionSupported : Config msg -> SessionType -> Cmd msg
isSessionSupported config sessionType =
    let
        value =
            PortDispatch.sessionTypeToValue sessionType
    in
    PortDispatch.dispatch config IsSessionSupported value


{-| Create a session of the given type.
-}
requestSession : Config msg -> SessionType -> Cmd msg
requestSession config sessionType =
    let
        value =
            PortDispatch.sessionTypeToValue sessionType
    in
    PortDispatch.dispatch config RequestSession value


{-| Sent back from the JS code to the `Config.inPort`.
-}
type alias ReturnValue =
    { command : ReturnValueCommand
    , value : Value
    }


{-| Error sent from the JS code to the `Config.inPort`.
-}
type alias ReturnError =
    { command : ReturnValueCommand
    , error : String
    }


{-| The "command" part of `ReturnValue`
-}
type alias ReturnValueCommand =
    { command : Command
    , value : Value
    }



{- Strings here must match `PortDispatch.commandToValue`. -}


commandDict : Dict String Command
commandDict =
    Dict.fromList
        [ ( "IsWebXRAvailable", IsWebXRAvailable )
        , ( "IsSessionSupported", IsSessionSupported )
        , ( "RequestSession", RequestSession )
        ]


commandDecoder : Decoder Command
commandDecoder =
    JD.string
        |> JD.andThen
            (\string ->
                case Dict.get string commandDict of
                    Nothing ->
                        JD.fail <| "Unknown command: " ++ string

                    Just command ->
                        JD.succeed command
            )


returnValueCommandDecoder : Decoder ReturnValueCommand
returnValueCommandDecoder =
    JD.succeed ReturnValueCommand
        |> required "command" commandDecoder
        |> required "value" JD.value


returnValueDecoder : Decoder ReturnValue
returnValueDecoder =
    JD.succeed ReturnValue
        |> required "command" returnValueCommandDecoder
        |> required "value" JD.value


returnErrorDecoder : Decoder ReturnError
returnErrorDecoder =
    JD.succeed ReturnError
        |> required "command" returnValueCommandDecoder
        |> required "error" JD.string


{-| Decode the `Value` sent to `Config.inPort`.
-}
decodeReturnValue : Value -> Result ReturnError ReturnValue
decodeReturnValue value =
    case JD.decodeValue returnValueDecoder value of
        Ok returnValue ->
            Ok returnValue

        Err _ ->
            case JD.decodeValue returnErrorDecoder value of
                Ok returnError ->
                    Err returnError

                Err _ ->
                    Err
                        { command =
                            { command = NoWebXRCommand
                            , value = JE.null
                            }
                        , error = "Decode error. Shouldn't happen."
                        }
