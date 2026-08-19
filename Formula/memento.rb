class Memento < Formula
  desc "CPU-first local memory engine for humans and AI agents"
  homepage "https://github.com/ArvorCo/memento"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on "python@3.12"
  depends_on "pandoc" => :recommended
  depends_on "poppler" => :recommended

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.0/memento-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "aa9ec531f43755c208efd75fe2cd538f50b4445ad9f3978ee4ab6a6bd10726e0"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.0/memento-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "f09dbdafad98e9371c18eba2de11ad16fdb83e89b6b844e77d7065f085c30237"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.0/memento-v0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "4cb18b6a7f9a671910ba7ec6600db4d6cac199be97c6f2c04c4ad63e23bb5a3c"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.0/memento-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1a5760ff6f6df248f43f1974b51e9ff1f228f5aff1fd404832cda1132628d64a"
    end
  end

  def install
    bin.install "memento", "mementod", "memento-mcp"
    libexec.install "tools"
    (libexec/"memento").install "scripts/install.sh"
    (pkgshare/"skills").install ".agents/skills/memento-runtime"
    (bin/"memento-vault-sync").write <<~SH
      #!/bin/bash
      export PYTHONPATH="#{libexec}${PYTHONPATH:+:$PYTHONPATH}"
      exec "#{formula_opt_bin("python@3.12")}/python3.12" -m tools.vault_sync.cli "$@"
    SH
    (bin/"memento-agent-install").write <<~SH
      #!/bin/bash
      export MEMENTO_SKILL_SOURCE="#{pkgshare}/skills/memento-runtime"
      exec "#{libexec}/memento/install.sh" --program skip "$@"
    SH
  end

  service do
    run [opt_bin/"mementod", "--foreground"]
    keep_alive true
    process_type :background
    log_path var/"log/mementod.log"
    error_log_path var/"log/mementod.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/memento --version")
    assert_match version.to_s, shell_output("#{bin}/mementod --version")
    assert_match version.to_s, shell_output("#{bin}/memento-mcp --version")
    assert_match "Generic vault sync toolkit", shell_output("#{bin}/memento-vault-sync --help")
    assert_match "Install Memento", shell_output("#{bin}/memento-agent-install --help")
  end
end
