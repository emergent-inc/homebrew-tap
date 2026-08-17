class Mosaic < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.23"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.23/ocean-darwin-arm64.tar.gz"
      sha256 "92798df12b428992417cfb4c715131ff12604f865b704b5c2705dce93a2a8f41"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.23/ocean-darwin-x64.tar.gz"
      sha256 "24cb9042bfac205294b1547d7959d348b9e8a65bc500d31ac962fd2de47075dd"
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
