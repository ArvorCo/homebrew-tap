class Memento < Formula
  desc "CPU-first local memory engine for humans and AI agents"
  homepage "https://github.com/ArvorCo/memento"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on "python@3.12"
  depends_on "pandoc" => :recommended
  depends_on "poppler" => :recommended

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.1/memento-v0.2.1-aarch64-apple-darwin.tar.gz"
      sha256 "a545f6ede1de9699b5fdf43a03db6b2f73288af44b2c1c3ef12ed6d5246179c8"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.1/memento-v0.2.1-x86_64-apple-darwin.tar.gz"
      sha256 "8de627f1642a5801c8d735537c57e365b9110d62947ca3589f92fc40ede8f568"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.1/memento-v0.2.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "62e6e03af553579cb031068cac3a7b89ef92c93f2f5bb81428af638469e4ede4"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.2.1/memento-v0.2.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "dacc15346cef1b2d7ad944254b7c071c1ba210eb12351159ba36b0ba708a6b89"
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
