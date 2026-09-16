--------------------------------------------------------------------
--
-- WebXR.elm
-- Elm interface the WebXR JavaScript library
-- (https://developer.mozilla.org/en-US/docs/Web/API/WebXR_Device_API).
-- Copyright (c) 2026 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module WebXR exposing
    ( SessionType(..)
    , isSessionSupported
    )


type SessionType
    = ImmersiveVR
    | ImmersiveAR
    | Inline


sessionTypeName : SessionType -> String
sessionTypeName sessionType =
    case sessionType of
        ImmersiveVR ->
            "immersive-vr"

        ImmersiveAR ->
            "immersive-ar"

        Inline ->
            "inline"


isSessionSupported : SessionType -> SessionType
isSessionSupported sessionType =
    -- TODO
    sessionType
