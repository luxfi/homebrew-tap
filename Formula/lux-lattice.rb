class LuxLattice < Formula
  desc "GPU-accelerated lattice cryptography for the Lux platform"
  homepage "https://github.com/luxfi/luxcpp"
  license "Apache-2.0"
  # luxfi/luxcpp doesn't ship release tarballs yet — install with --HEAD
  # to build from main. Stable URL wiring lands when the C++ tree gets
  # its first release tag (will be `lattice-vX.Y.Z` per per-component
  # versioning).
  head "https://github.com/luxfi/luxcpp.git", branch: "main"

  depends_on "cmake" => :build

  on_macos do
    depends_on macos: :ventura
  end

  def install
    cd "lattice" do
      args = std_cmake_args + %W[
        -DCMAKE_INSTALL_RPATH=#{rpath}
        -DBUILD_SHARED_LIBS=ON
        -DLUXLATTICE_ENABLE_METAL=ON
        -DLUXLATTICE_ENABLE_CUDA=OFF
      ]
      system "cmake", "-S", ".", "-B", "build", *args
      system "cmake", "--build", "build", "--config", "Release"
      system "cmake", "--install", "build"
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
