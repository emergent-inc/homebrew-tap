class Ocean < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.21"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.21/ocean-darwin-arm64.tar.gz"
      sha256 "01d08db07a1db9647fa58e30d49dde40c096f6e1112f22f0d0cd02d383a0c5a0"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.21/ocean-darwin-x64.tar.gz"
      sha256 "90e9c1047cfcdc2a98bffa77dbffff16cc3e577af8cd36a17aa9313b805c568d"
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
