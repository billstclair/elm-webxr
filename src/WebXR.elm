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
import Task exposing (Task)
import WebXR.PortDispatch exposing (dispatch)
import WebXR.Types exposing (Command(..), Config, SessionType(..))


type XRError
    = IllegalSessionRequest String
    | XRErrorString String


type alias SessionTask a =
    Task XRError a


{-| True if the browser supports WebXR.
-}
isWebXRAvailable : SessionTask Bool
isWebXRAvailable =
    -- TODO
    Task.fail <| XRErrorString "isWebXRAvailable: TODO"


{-| True if the WebXR implementation currently supports the given SessionType.

If true, `requestSession` will succeed.

-}
isSessionSupported : SessionType -> SessionTask Bool
isSessionSupported sessionType =
    -- TODO
    Task.fail <| XRErrorString "isSessionSupported: TODO"


type alias XRSession =
    { json : Value }


{-| Create a session of the given type.
-}
requestSession : SessionType -> SessionTask XRSession
requestSession sessionType =
    Task.fail <| XRErrorString "requestSession: TODO"
