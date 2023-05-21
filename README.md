# Wordpress-userdata
## 使用について
* __AmazonLinux2023は非対応。AmazonLinux2での使用を推奨。__
    * AmazonLinux2023で使用できるスクリプトを作成中。
* __EC2のインスタンスプロファイルにIAMロールを設定。__
    * ` ssm:GetParameter `ポリシーが必要。
## スクリプトについて
以下の流れでインストールを実施し。
* __SystemsManager ParameterStoreからパラメータを取得、環境変数に設定__
* __必要なパッケージのインストール__
* __MySQLユーザーの作成__
* __Wordpressのダウンロード__
* __wp-config.phpの修正__

## コマンドについて
### SystemsManager ParameterStoreのパラメータ取得
```
variable=$(aws ssm get-parameter --name "parameter_name" --with-decryption --region current_region  --output text --query Parameter.Value)
```
variableに` ssm get-parameter `コマンドで取得した値が入るので、スクリプトでパラメータを参照する箇所に` $variable `の形式で記述。
### MySQLログイン
MySQLコマンドを、` <<EOF `から` EOF `で指定。