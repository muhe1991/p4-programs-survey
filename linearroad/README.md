# P4 Linear Road
The Linear Road benchmark running on a P4 switch.

## Try It Out
P4 Linear Road is packaged as a [p4app](https://github.com/p4lang/p4app). To start the test simulation, run:

    git clone https://github.com/usi-systems/p4linearroad
    cd p4linearroad
    p4app run linear_road.p4app

This will start the simulation and send a stream that exercises all of the Linear Road queries.

### Dependencies
You only need [p4app](https://github.com/p4lang/p4app) (which requires Docker to be installed and running). Make sure `p4app` is in your `$PATH`, or that you include its full path when calling it (e.g. `~/src/p4app/p4app run ...`).
