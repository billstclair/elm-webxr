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


module WebXR.Types exposing (Config, Command(..), SessionType(..))

{-| Shared types for WebXR.

@docs Config, Command, SessionType

-}

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| WebXR configuration
-}
type alias Config msg =
    { outPort : Value -> Cmd msg
    , inPort : (Value -> msg) -> Sub msg
    }


{-| WebXR Command
-}
type Command
    = IsWebXRAvailable --value: ignored
    | IsSessionSupported --value: SessionType string
    | RequestSession --value: SessionType string
    | NoWebXRCommand --Not sent over the wire, for decodeReturnValue below


{-| WebXR Session Type
-}
type SessionType
    = Inline
    | ImmersiveVR
    | ImmersiveAR
