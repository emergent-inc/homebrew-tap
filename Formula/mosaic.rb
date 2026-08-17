class Mosaic < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.23"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.23/ocean-darwin-arm64.tar.gz"
      sha256 "30e940be4966e28d1e2230e8b01761523ea4af960cecae1ccfaaa00b74dcf53b"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.23/ocean-darwin-x64.tar.gz"
      sha256 "20861efe4a5957c5ebb47217718d4db9ca5926ee145a3820d4d7574732e4cdac"
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
