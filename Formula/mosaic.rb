class Mosaic < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.24"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-arm64.tar.gz"
      sha256 "8d10e02d77c777ff1b87ec3796405d9b2ad6a75ce4e251a279efb975d9e7cd38"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-x64.tar.gz"
      sha256 "ce54d44ab501a9aa510d4189f350577c123c467501959d52aea6dd9594a2602e"
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
