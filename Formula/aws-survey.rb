class AwsSurvey < Formula
  desc "Read-only AWS account survey in an isolated container for Claude Code/Codex"
  homepage "https://github.com/pixbitpoi/aws-survey"
  url "https://github.com/pixbitpoi/aws-survey/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "2940edd6a455166a15624833476802124c6e740688a5824eb385cc1a4c734a7e"
  head "https://github.com/pixbitpoi/aws-survey.git", branch: "main"

  depends_on "jq"
  # `init` writes an aws-login command as the default auth.refresh_command, and `credentials`
  # runs it when the source profile has expired.
  depends_on "pixbitpoi/tap/aws-login"

  def install
    # Only runtime material ships. docs/ is for maintainers and tests/ runs in the repository.
    # AGENTS.md, CLAUDE.md and .agents/ are the entry points for an agent developing this tool:
    # the host agent's job ends at `aws-survey run`, so nobody works inside the installed tree,
    # and development happens in a git checkout. Dir["*"] skips dot-prefixed entries, which is
    # what we want here - no dot glob. Keep in step with EXCLUDED, NOT_SHIPPED_FILES and
    # INCLUDED_HIDDEN in tests/test_distribution.py.
    # The repository is laid out bin/ + libexec/ + container/, so it maps onto the keg as is.
    # Only bin/, sbin/, etc/, include/, share/ and lib/ get linked into the prefix, so
    # container/, templates/ and Dockerfile stay private to the keg.
    # README.md is left out: the user-facing docs live on GitHub (`brew home`) and nothing in
    # the shipped tree points at them. Homebrew still drops it in the keg as a metafile.
    prefix.install(Dir["*"] - ["docs", "tests", "README.md", "AGENTS.md", "CLAUDE.md"])
    # aws-survey resolves AWS_SURVEY_HOME from its own realpath, and `pwd -P` resolves through
    # every symlink, so linking the real script would land on the versioned keg. That path is
    # shown by `aws-survey status` and can be set by hand as AWS_SURVEY_HOME, and a keg path
    # breaks on the next upgrade. Move the real script out of the linked bin/ and front it with
    # a wrapper pinning AWS_SURVEY_HOME to the version-independent opt path.
    libexec.install prefix/"bin/aws-survey"
    (bin/"aws-survey").write_env_script opt_libexec/"aws-survey",
                                        AWS_SURVEY_HOME: opt_prefix
  end

  def caveats
    <<~EOS
      aws-survey は AWS CLI v2 と Docker を必要としますが、依存には含めていません。
      AWS CLI は `brew install awscli` か公式インストーラー、Docker は Docker Desktop などで入れてください。
      元プロファイルのログインに使う aws-login は依存なので、一緒に入ります。
      揃っているかは `aws-survey doctor` で確認できます。

      Docker Desktop は Settings → Resources → File Sharing に登録した場所しかマウントできません。
      本体は /opt/homebrew の下に入るので、File Sharing に /opt/homebrew を追加して Apply & restart してください。
      足りない場所は `aws-survey doctor` と `aws-survey run` が案内します。

      使い方は対象ごとに空のフォルダを作り、そこで `aws-survey` を打つだけです。
        mkdir -p ~/surveys/example && cd ~/surveys/example && aws-survey

      調査結果（out/）と接続設定（environment.json）は対象フォルダに、
      一時キーは ~/.aws-survey/<name>/ に残ります。アンインストールしても消えません。
    EOS
  end

  test do
    assert_match "aws-survey status", shell_output("#{bin}/aws-survey --help")
    assert_path_exists prefix/"Dockerfile"
    assert_path_exists prefix/"container/instructions/survey-agents.md"
    assert_path_exists prefix/"templates/environment.json"
    assert_path_exists libexec/"aws-survey"
    # Development material must not reach the keg; nothing shipped points at it.
    refute_path_exists prefix/"AGENTS.md"
    refute_path_exists prefix/".agents"
    output = shell_output("#{bin}/aws-survey status")
    assert_match opt_prefix.to_s, output
  end
end
