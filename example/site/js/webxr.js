//////////////////////////////////////////////////////////////////////
//
// webxr.js
// JavaScript code for billstclair/elm-webxr
// Copyright (c) 2026 Bill St. Clair (billstclair@gmail.com)
// Some rights reserved.
// Distributed under the MIT License
// See LICENSE
//
//////////////////////////////////////////////////////////////////////

(function(scope) {

  WebXR = {};
  scope.WebXR = WebXR;

  WebXR.subscribe = subscribe;  // called by HTML file
  WebXR.sub = null;             // see below (in subscribe)

  function subscribe(app, args) {
    if (!args) args = {};
    portNames = args.portNames;
    if (!portNames) {
      portNames = ['webXROut', 'webXRIn']
    }
    var ports = app.ports;
    if (ports) {
      var sub = ports[portNames[1]];
      WebXR.sub = sub;

      var cmd = ports[portNames[0]];
      if (cmd) {
        cmd.subscribe(function(command) {
          var returnValue = commandDispatch(command);
          if (returnValue != undefined) {
            sub.send(returnValue);
          }
        });
      }
    }
  }

  function err(str) {
    return { "error": str };
  }

  // command = { "command": <string>,
  //             "value": <value>
  //           }
  function commandDispatch(cmd) {
    if (typeof(cmd) != 'object') {
      return err('cmd not an object');
    }
    var command = cmd.command;
    if (command == "IsWebXRAvailable") {
      if (navigator.xr) {
        return true;
      } else {
        return false;
      }
    } else {
      var xr = navigator.xr;
      var res;
      if (!xr) {
        console.log('Browser does not support WebXR');
        return err('Browser does not support WebXR')
      } else if (command == 'IsSessionSupported') {
        console.log('IsSessionSuported(', cmd.value, ')');
        return xr.isSessionSupported(cmd.value);
      } else if (command == 'RequestSession') {
        console.log('RequestSession(', cmd.value, ')');
        return xr.requestSession(cmd.value);
      }
    }
  }
})(this);


