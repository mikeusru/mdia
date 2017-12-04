function r_batchAcquisition

state.shutter.open = 0;
executeGrabOneCallback(gh.mainControls.grabOneButton);