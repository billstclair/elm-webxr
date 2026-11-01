----------------------------------------------------------------------
--
-- Types.elm
--
-- Copyright (c) 2026 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------


module WebXR.Types exposing
    ( Command(..), Config, SessionType(..)
    , ReturnValue, ReturnValueCommand
    , decodeReturnValue
    )

{-| Shared types for WebXR.

@docs Command, Config, SessionType

The `Value` sent from the JS to `Config.inPort`.

@docs ReturnValue, ReturnValueCommand
@docs decodeReturnValue

-}

import Dict exposing (Dict)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as DP exposing (custom, hardcoded, optional, required)
import Json.Encode as JE exposing (Value)


{-| WebXR Command
-}
type Command
    = IsWebXRAvailable --value: ignored
    | IsSessionSupported --value: SessionType string
    | RequestSession --value: SessionType string
    | NoWebXRCommand --Not send over the wire, for decodeReturnValue below



{- Strings here must match `PortDispatch.commandToValue`. -}


commandDict : Dict String Command
commandDict =
    Dict.fromList
        [ ( "IsWebXRAvailable", IsWebXRAvailable )
        , ( "IsSessionSupported", IsSessionSupported )
        , ( "RequestSession", RequestSession )
        ]


{-| WebXR configuration
-}
type alias Config msg =
    { outPort : Value -> Cmd msg
    , inPort : (Value -> msg) -> Sub msg
    }


{-| WebXR Session Type
-}
type SessionType
    = Inline
    | ImmersiveVR
    | ImmersiveAR


{-| Sent back from the JS code to the `Config.inPort`.
-}
type alias ReturnValue =
    { command : ReturnValueCommand
    , value : Value
    }


{-| Error sent from the JS code to the `Config.inport`.
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


{-| Decode the `Value` sent from `Config.inport`.
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
