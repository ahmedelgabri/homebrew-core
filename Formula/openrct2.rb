class Openrct2 < Formula
  desc "Open source re-implementation of RollerCoaster Tycoon 2"
  homepage "https://openrct2.io/"
  url "https://github.com/OpenRCT2/OpenRCT2.git",
      :tag      => "v0.2.5",
      :revision => "4f6e77e30ac8e81fd873f1c4041105395fed1327"
  head "https://github.com/OpenRCT2/OpenRCT2.git", :branch => "develop"

  bottle do
    cellar :any
    sha256 "0a0541d674d5244bbaff7c2aeb4eaf936be8ddc138ce6129062d3018a55d12a1" => :catalina
    sha256 "f8d9bfa00c863e695388552a60099a248bb60d31413696c81f4ebd2ffaec24f9" => :mojave
    sha256 "8c12255546d873041c260554e8027c79dce76c2cb411d86bcf070091af3ff31a" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype" # for sdl2_ttf
  depends_on "icu4c"
  depends_on "jansson"
  depends_on "libpng"
  depends_on "libzip"
  depends_on :macos => :high_sierra # "missing: Threads_FOUND" on Sierra
  depends_on "openssl@1.1"
  depends_on "sdl2"
  depends_on "sdl2_ttf"
  depends_on "speexdsp"

  resource "title-sequences" do
    url "https://github.com/OpenRCT2/title-sequences/releases/download/v0.1.2c/title-sequences.zip"
    sha256 "5284333fa501270835b5f0cf420cb52155742335f5658d7889ea35d136b52517"
  end

  resource "objects" do
    url "https://github.com/OpenRCT2/objects/releases/download/v1.0.13/objects.zip"
    sha256 "0279874ad5a4c07f1fca5c62d2d5c3aa12bd849d7b643e3c7d93cfda88df7c6a"
  end

  def install
    # Avoid letting CMake download things during the build process.
    (buildpath/"data/title").install resource("title-sequences")
    (buildpath/"data/object").install resource("objects")

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    # By default macOS build only looks up data in app bundle Resources
    libexec.install bin/"openrct2"
    (bin/"openrct2").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/openrct2" "$@" "--openrct-data-path=#{pkgshare}"
    EOS
  end

  test do
    assert_match "OpenRCT2, v#{version}", shell_output("#{bin}/openrct2 -v")
  end
end
