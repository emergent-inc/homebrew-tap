class Ocean < Formula
  desc "Shared, continuously synced coding-agent session drive"
  homepage "https://github.com/emergent-inc/ocean"
  version "0.2.22"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.22/ocean-darwin-arm64.tar.gz"
      sha256 "d1c7112294ed894ce855dd61e5e899715a6e4b3f26412aad25b3b7c7deda1372"
    else
      url "https://github.com/emergent-inc/homebrew-tap/releases/download/v0.2.22/ocean-darwin-x64.tar.gz"
      sha256 "849d608b6d711847a20b7f773d7bf2e7e7370c3c611a8743ff8b70395086b77a"
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
