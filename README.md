# Multiplayer Blob Game

Built with [react-flux-webpack-starter](https://github.com/pairshaped/react-flux-webpack-starter)

# TODO

 - [x] Network sync code
 - [ ] Nicer way to change username/start mass (right now, it's a refresh on the client side)
 - [ ] Integrate with SAT 2d Physics Collision Library (Was going to use Grid2, but it has no documentation or sensible examples)
 - [ ] Interpolate movement on the client to reduce jitter.  May just end up running the simulation at a higher tick-rate client-side to do physics only.
 - [ ] Consumption mechanics
   - [ ] 1st mode: Blobs can fight multiple blobs, challenging 1 mass unit per server tick.
   - [ ] 2nd mode: If blob is at most half your size, you can consume

# Install

```bash
npm install
```

# Running

Run the development server

```bash
npm start
```

Build production javascript bundle

```bash
npm run build
```

# Unit Testing

*These are probably broken, will be fixing them soon!*

```bash
npm test
```

