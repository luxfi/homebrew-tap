class Lux < Formula
  desc "Lux Network CLI — subnet, node, and validator operations"
  homepage "https://github.com/luxfi/cli"
  url "https://github.com/luxfi/cli/archive/refs/tags/v1.100.5.tar.gz"
  sha256 "98768020c708e8b208cd5ef6c98e9c69ea34dc7545ac16749249a5d168a4ade9"
  license "BSD-3-Clause"
  head "https://github.com/luxfi/cli.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
    ]
    system "go", "build", "-trimpath", "-ldflags=#{ldflags.join(" ")}",
           "-o", bin/"lux", "."
  end

  test do
    assert_match "lux", shell_output("#{bin}/lux --help 2>&1", 0)
  end
end
