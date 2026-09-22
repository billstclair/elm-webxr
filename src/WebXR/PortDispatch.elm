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


module WebXR.PortDispatch exposing (dispatch)

{-| Dispatch to port JavaScript code.
-}

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import Task exposing (Task)


type Command
    = IsWebXRAvailable
    | IsSessionSupported
    | RequestSession


type alias Config msg =
    { outPort : Value -> Cmd msg
    , inPort : (Value -> msg) -> Sub msg
    }


dispatch : Config msg -> Command -> Value -> Task String ()
dispatch config command value =
    Task.fail "dispatch TODO."
