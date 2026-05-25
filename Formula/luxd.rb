class Luxd < Formula
  desc "Lux Network node daemon — the canonical L1 validator"
  homepage "https://github.com/luxfi/node"
  url "https://github.com/luxfi/node/archive/refs/tags/v1.27.20.tar.gz"
  sha256 "c1b2437cb81dcae1fb2157b71d4774e09e167fb251bb1c444bb80d63593f33a7"
  license "BSD-3-Clause"
  head "https://github.com/luxfi/node.git", branch: "main"

  depends_on "go" => :build
  depends_on "lux-lattice" # cgo binding to GPU NTT primitives

  def install
    ldflags = %W[
      -s -w
      -X github.com/luxfi/node/version.Version=#{version}
    ]
    system "go", "build", "-trimpath", "-ldflags=#{ldflags.join(" ")}",
           "-o", bin/"luxd", "./main"
  end

  test do
    output = shell_output("#{bin}/luxd --version 2>&1", 0)
    assert_match(/lux/i, output)
  end
end
