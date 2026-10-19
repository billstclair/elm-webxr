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


module WebXR.Types exposing (Command(..), Config, SessionType(..))

{-| Shared types for WebXR.

@docs Command, Config, SessionType

-}

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| WebXR Command
-}
type Command
    = IsWebXRAvailable --value: ignored
    | IsSessionSupported --value: SessionType string
    | RequestSession --value: SessionType string


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
