class Ocean < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.24"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-arm64.tar.gz"
      sha256 "50094b8822fda0ca390efe5da9a6dfdc3371c572ccc503eed3fe96885b147fe3"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-x64.tar.gz"
      sha256 "a9da10fb092bf5c5a1df06c1600d2f7548904a2ab0ea000215760e231a716508"
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
    assert_match "Ocean", shell_output("#{bin}/ocean --version")
    assert_match "Mosaic", shell_output("#{bin}/mosaic --help")
    assert_predicate libexec/"Ocean.app/Contents/MacOS/OceanBackground", :executable?
    assert_match "com.ocean.app", (libexec/"Ocean.app/Contents/Info.plist").read
  end
end
