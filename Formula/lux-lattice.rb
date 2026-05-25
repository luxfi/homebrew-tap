class LuxLattice < Formula
  desc "GPU-accelerated lattice cryptography for the Lux platform"
  homepage "https://github.com/luxcpp/lattice"
  # v1.0.0 is the last self-contained lattice tarball. v1.1.0+ uses
  # `../crypto/math/ntt/cpu/lattice_ring.cpp` (a sibling-repo path)
  # which doesn't extract from the GitHub archive. Pinned at v1.0.0
  # until lattice vendors the substrate into its own src/ tree.
  url "https://github.com/luxcpp/lattice/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "92a0be5a7aa0c8dc9df0ba0ca6c64926f4ad7025d10820c2be37e1a95f39dad3"
  license "Apache-2.0"
  head "https://github.com/luxcpp/lattice.git", branch: "main"

  depends_on "cmake" => :build

  on_macos do
    depends_on macos: :ventura
  end

  def install
    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DBUILD_SHARED_LIBS=ON
      -DLUXLATTICE_ENABLE_METAL=ON
      -DLUXLATTICE_ENABLE_CUDA=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--config", "Release"
    system "cmake", "--install", "build"

    # v1.0.0 of the upstream lattice repo installs `liblattice.dylib`
    # (no `lux` prefix). Go cgo bindings on the consumer side use
    # `#cgo pkg-config: lux-lattice` + `-lluxlattice` per the post-v1.0.0
    # naming convention. Add a `libluxlattice.dylib` alias so the
    # linker resolves either name to the same Mach-O.
    if File.exist?("#{lib}/liblattice.dylib") && !File.exist?("#{lib}/libluxlattice.dylib")
      ln_sf "liblattice.dylib", "#{lib}/libluxlattice.dylib"
    end
  end

  test do
    (testpath/"smoke.c").write <<~EOS
      #include <stdint.h>
      typedef struct LatticeNTTContext LatticeNTTContext;
      extern LatticeNTTContext* lattice_ntt_create_montgomery(
        uint32_t, uint64_t, uint64_t, uint64_t,
        const uint64_t*, const uint64_t*);
      int main(void) {
        // link-only smoke: the linker must resolve the symbol against
        // libluxlattice. Don't invoke at runtime — N=0 would assert.
        (void)lattice_ntt_create_montgomery;
        return 0;
      }
    EOS
    system ENV.cc, "smoke.c", "-L#{lib}", "-lluxlattice", "-o", "smoke"
  end
end
