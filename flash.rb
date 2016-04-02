
class Flash < Formula
  desc "Command line script to flash SD card images for the Raspberry Pi"
  homepage "http://blog.hypriot.com/"
  url "https://github.com/hypriot/flash/archive/0.2.0.tar.gz"
  sha256 "4a5af238c22f0792594b5f0e9520e9e62e18ab1d4be6f94e83b41128a417e770"
  depends_on "pv"
  depends_on "awscli"

   bottle :unneeded

  def install
      libexec.install Dir["Darwin/*"]
      bin.write_exec_script Dir["#{libexec}/*"]
  end
end
