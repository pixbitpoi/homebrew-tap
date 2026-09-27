class AwsLogin < Formula
  desc "Bash wrapper for AWS CLI login (IAM user + MFA and IAM Identity Center SSO)"
  homepage "https://github.com/pixbitpoi/aws-login"
  url "https://github.com/pixbitpoi/aws-login/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6b7f9f6f662ac1b47651255baac7715c1bf7ad755ebfa4d931486f29414c8cd3"
  head "https://github.com/pixbitpoi/aws-login.git", branch: "main"

  def install
    bin.install "bin/aws-login"
  end

  def caveats
    <<~EOS
      aws-login は AWS CLI v2 を必要としますが、依存には含めていません。
      未インストールなら `brew install awscli` か公式インストーラーで入れてください。
    EOS
  end

  test do
    assert_match "使用方法: aws-login", shell_output("#{bin}/aws-login --help")

    # AWS CLI v2 は depends_on にしていないので、無いときに案内して終了コード 2 で
    # 落ちることが唯一の防波堤になる。PATH を空にして aws を見つからなくする。
    assert_match "AWS CLI v2 をインストールしてください。",
                 shell_output("PATH=/var/empty /bin/bash #{bin}/aws-login 2>&1", 2)
  end
end
