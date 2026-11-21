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

    // From https://www.google.com/search?q=js+sleep
    const sleepPromise = ms => new Promise(resolve => setTimeout(resolve, ms));
    async function sleep(ms) {
      await sleepPromise(ms);
    }
    WebXR.sleep = sleep;

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
            commandDispatch(sub, command);
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

  // As expected by Elm code
  function packageReturn(cmd, value) {
    const res = { "command": cmd,
                  "value": value
                };
    return res;
  }

  // command = { "command": <string>,
  //             "value": <value>
  //           }
  function commandDispatch(sub, cmd) {
    if (typeof(cmd) != 'object') {
      sub.send(err(cmd, 'cmd not an object'));
    }
    var command = cmd.command;
    if (command == "IsWebXRAvailable") {
      sub.send(packageReturn(cmd, navigator.xr ? true : false));
    } else {
      var xr = navigator.xr;
      if (!xr) {
        sub.send(err(cmd, 'Browser does not support WebXR'));
      } else if (command == 'IsSessionSupported') {
        isSessionSupported(sub, cmd, cmd.value);
      } else if (command == 'RequestSession') {
        return err(cmd, 'RequestSession not yet implemented');
        //return xr.requestSession(cmd.value);
      }

      function isSessionSupported(sub, cmd, sessionType) {
        var val = false;
        try {
          xr.isSessionSupported(sessionType).then(
            function(res) {
              sub.send(packageReturn(cmd, res));
            },
            function(error) {
              sub.send(err(cmd, 'xr.isSessionSupported() failed:' + error));
            });
        } catch (error) {
          sub.send(err(cmd, 'xr.isSessionSupported error: ' + error));
        }
      }
    }
  }
})(this);


