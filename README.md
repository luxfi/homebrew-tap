# homebrew-luxfi

Canonical Homebrew tap for Lux native libraries — the C/C++/CUDA/Metal
components consumed by lux Go modules via cgo. Installing through this
tap (instead of pointing cgo at `~/work/luxcpp/install/lib`) keeps every
developer's link paths identical and gives the linker exactly one
`libluxlattice.dylib` on `LIBRARY_PATH`, eliminating the stale-binary
class of "undefined symbol" failures.

## Install

```bash
brew tap luxfi/tap
brew install lux-lattice    # GPU-accelerated lattice cryptography
brew install lux-crypto     # secp256k1, blake3, poseidon2, ...
brew install lux-fhe        # FHE backends (CRDT, CKKS, BFV)
```

Apple-Silicon paths: `/opt/homebrew/{lib,include,lib/pkgconfig}`.
Intel paths: `/usr/local/{lib,include,lib/pkgconfig}`.

## Build from source

Each formula builds from a tagged source tarball published at
`github.com/luxfi/luxcpp/releases`. To consume an in-tree dev build,
use `brew install --HEAD`.

## Available formulas

| formula | go consumer | notes |
|---|---|---|
| lux-lattice | github.com/luxfi/lattice/v7 | NTT + ring-LWE primitives |
| lux-crypto  | github.com/luxfi/crypto    | secp256k1, blake3, poseidon2 |
| lux-fhe     | github.com/luxfi/fhe       | CRDT/CKKS/BFV backends |
