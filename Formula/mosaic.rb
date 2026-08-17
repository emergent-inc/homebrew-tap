class Mosaic < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.24"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-arm64.tar.gz"
      sha256 "60ae20c3e8e8c7e52ebfe994f734d255390e9d358e6735406e7a1203b9166daa"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.24/ocean-darwin-x64.tar.gz"
      sha256 "d260d4e55874db41b4760200c2f4556f01bfcfd8fdefa863307f40ad37ad7441"
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
