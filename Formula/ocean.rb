class Ocean < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.20"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.20/ocean-darwin-arm64.tar.gz"
      sha256 "af20c95615c2f3bc5aeda88ce21696ab7d1c65084fb0013107f9791840f6d9fa"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.20/ocean-darwin-x64.tar.gz"
      sha256 "b33d22d263ee5970bc8098eb7d36760f5d18922792bc9097d90ef1f31a35b351"
    end
  end

  def install
    libexec.install "ocean", "orgtrace", "rclone", "Ocean.app"
    libexec.install "node", "ocean.mjs" if File.exist?("node")
    bin.install_symlink libexec/"ocean"
    bin.install_symlink libexec/"orgtrace"
  end

  test do
    assert_match "Ocean", shell_output("#{bin}/ocean --help")
    assert_predicate libexec/"Ocean.app/Contents/MacOS/OceanBackground", :executable?
    assert_match "com.ocean.app", (libexec/"Ocean.app/Contents/Info.plist").read
  end
end
