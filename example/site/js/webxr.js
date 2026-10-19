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
          if (returnValue) {
            sub.send(returnValue);
          }
        });
      }
    }

    function err(str) {
      return { "error": str };
    }

    // command = { "command": <string>,
    //             "value": <value>
    //           }
    function commandDispatch(command) {
      if (typeof(command) != 'object') {
        return err('command not an object');
      }
    }
  }

})(this);


