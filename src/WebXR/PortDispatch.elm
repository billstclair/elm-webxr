----------------------------------------------------------------------
--
-- PortDispatch.elm
--
-- Copyright (c) 2026 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE
--
----------------------------------------------------------------------


module WebXR.PortDispatch exposing (Command(..), SessionType(..), dispatch)

{-| Dispatch to port JavaScript code.
-}

import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as DP exposing (custom, hardcoded, optional, required)
import Json.Encode as JE exposing (Value)
import Task exposing (Task)


{-| WebXR Command
-}
type Command
    = IsWebXRAvailable
    | IsSessionSupported
    | RequestSession



{- WebXR Session Type -}


type SessionType
    = Inline
    | ImmersiveVR
    | ImmersiveAR


sessionTypeToValue : SessionType -> Value
sessionTypeToValue sessionType =
    case sessionType of
        Inline ->
            JE.string "inline"

        ImmersiveAR ->
            JE.string "immersive-vr"

        ImmersiveVR ->
            JE.string "immersive-ar"


valueToSessionType : Value -> Result String SessionType
valueToSessionType value =
    case JD.decodeValue JD.string value of
        Err err ->
            Err <| "not a string: " ++ JD.errorToString err

        Ok string ->
            case string of
                "inline" ->
                    Ok Inline

                "immersive-vr" ->
                    Ok ImmersiveVR

                "immersive-ar" ->
                    Ok ImmersiveAR

                _ ->
                    Err <| "Unknown session type: " ++ string


type alias PortValue =
    { command : Value
    , value : Value
    }


encodePortValue : PortValue -> Value
encodePortValue portValue =
    JE.object
        [ ( "command", portValue.command )
        , ( "value", portValue.value )
        ]


portValueDecoder : Decoder PortValue
portValueDecoder =
    JD.succeed PortValue
        |> required "command" JD.value
        |> required "value" JD.value



{--TODO
   commandToValue : Command -> Value -> Result String Value
   commandToValue command value =
           case command of
               ISWebXRAvailable ->
                   "IsWebXRAvailable"
               IsSessionSupported ->
                   case valueToSessionType value of
-}


type alias Config msg =
    { outPort : Value -> Cmd msg
    , inPort : (Value -> msg) -> Sub msg
    }


{-| Send a command to the backend.
-}
dispatch : Config msg -> Command -> Value -> Task String ()
dispatch config command value =
    Task.fail "dispatch TODO."
