class Memento < Formula
  desc "CPU-first local memory engine for humans and AI agents"
  homepage "https://github.com/ArvorCo/memento"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on "python@3.12"
  depends_on "pandoc" => :recommended
  depends_on "poppler" => :recommended

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.1/memento-v0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "1d251618b80f6affaac42ec06d08476efbb5123dca9091613cd9f5b8a214fcfd"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.1/memento-v0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "8e66b658274a1aa615263603747253370e2bc35af449e30b642bf353f6be9415"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.1/memento-v0.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "b0ff7800ffc5c37f0230022abbb8afd766928d26829a547721d8379cd5fa10d0"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.1/memento-v0.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "5ab1cbb47ed890994112aa1806bdb789cabaa488367afc3c9e3c72890be456d5"
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
