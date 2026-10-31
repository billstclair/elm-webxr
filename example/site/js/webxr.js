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
      // send: { "command": { command: <string>,
      //                    value: <value>
      //                  },
      //         "return": <value>
      //         "error": <string>
      //       }
      // "return" or "error" is included, but not both.
      WebXR.sub = sub;

      if (sub) {
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
  }

  function err(cmd, str) {
    return { "command": cmd,
             "error": str
           };
  }

  // command = { "command": <string>,
  //             "value": <value>
  //           }
  function commandDispatch(cmd) {
    if (typeof(cmd) != 'object') {
      return err(cmd, 'cmd not an object');
    }
    var command = cmd.command;
    if (command == "IsWebXRAvailable") {
      return packageReturn(cmd, navigator.xr ? true : false);
    } else {
      var xr = navigator.xr;
      if (!xr) {
        console.log('Browser does not support WebXR');
        return err(cmd, 'Browser does not support WebXR')
      } else if (command == 'IsSessionSupported') {
        console.log('IsSessionSuported(', cmd.value, ')');
        return packageReturn(cmd, isSessionSupported(cmd.value));
      } else if (command == 'RequestSession') {
        console.log('RequestSession(', cmd.value, ')');
        // TODO
        return err(cmd, 'RequestSession not yet implemented');
        //return xr.requestSession(cmd.value);
      }

      function packageReturn(cmd, value) {
        return { "command": cmd,
                 "value": value
               };
      }

      function isSessionSupported(sessionType) {
        var val;
        xr.isSessionSupported(sessionType).then(
          function(res) {
            val = res;
          })
        return val;
      }
    }
  }
})(this);


