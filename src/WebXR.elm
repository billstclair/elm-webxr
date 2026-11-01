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


module WebXR exposing (isWebXRAvailable, isSessionSupported, requestSession)

{-| Elm interface to the WebXR JavaScript library.

@docs isWebXRAvailable, isSessionSupported, requestSession

-}

import Json.Decode as JD exposing (Decoder)
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
