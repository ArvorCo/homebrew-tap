class Memento < Formula
  desc "CPU-first local memory engine for humans and AI agents"
  homepage "https://github.com/ArvorCo/memento"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]

  depends_on "python@3.12"
  depends_on "pandoc" => :recommended
  depends_on "poppler" => :recommended

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.0/memento-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "0c1fabc405fab5949676e9e3871c19ff6aaad92765727b5b62e85697b92fc008"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.0/memento-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "b0279dc5a7089c12d4ad56f2fee7fe86e610f47e5c0071e3c96956bc5a11ac93"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.0/memento-v0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "3e3ff868b3e6c9ef45109880fae8ae0b7a5b9693076ca461a0a7ec1d3fd049be"
    else
      url "https://github.com/ArvorCo/memento/releases/download/v0.1.0/memento-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "70e079649a540bcc503147c3773b866561b61b34dd4dced19d246dc05d876633"
    end
  end

  def install
    bin.install "memento", "mementod", "memento-mcp"
    libexec.install "tools"
    (libexec/"memento").install "scripts/install.sh"
    (share/"memento/skills").install ".agents/skills/memento-runtime"
    (bin/"memento-vault-sync").write <<~SH
      #!/bin/bash
      export PYTHONPATH="#{libexec}${PYTHONPATH:+:$PYTHONPATH}"
      exec "#{formula_opt_bin("python@3.12")}/python3.12" -m tools.vault_sync.cli "$@"
    SH
    (bin/"memento-agent-install").write <<~SH
      #!/bin/bash
      export MEMENTO_SKILL_SOURCE="#{share}/memento/skills/memento-runtime"
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
