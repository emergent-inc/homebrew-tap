class Mosaic < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.24"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-arm64.tar.gz"
      sha256 "be8a7b3e5371dee03a5a1b09b1c260d0a47dd2b0b1d22586476fce5ab7df7dc0"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-x64.tar.gz"
      sha256 "93b5a1fb321592c4d4dff5a7cc25071b2b91ca302fbb1e3719621b8031e40998"
    end
  end

  def install
    libexec.install "ocean", "orgtrace", "rclone", "Ocean.app"
    libexec.install "node", "ocean.mjs" if File.exist?("node")
    libexec.install_symlink "ocean" => "mosaic"
    bin.install_symlink libexec/"mosaic"
    bin.install_symlink libexec/"ocean"
    bin.install_symlink libexec/"orgtrace"
  end

  test do
    assert_match "Mosaic", shell_output("#{bin}/mosaic --help")
    assert_match "Ocean", shell_output("#{bin}/ocean --version")
    assert_predicate libexec/"Ocean.app/Contents/MacOS/OceanBackground", :executable?
    assert_match "com.ocean.app", (libexec/"Ocean.app/Contents/Info.plist").read
  end
end
