# このリポジトリについて

このリポジトリは静的サイトジェネレータを利用してGCP上でサイトを公開したいという人（自分）のために作成したものです．
使っているツールやGCPの制約によって多少の手作業をともないますが，できる限り自動的・汎用的になるように作ってみたので公開してみます．

## 利用ツール

- git
- Terraform
- Hugo(静的サイトジェネレータの類であれば基本何でも代替できるはずです)

## 利用GCPサービス

- Google Cloud DNS
- Google Cloud Storage
- Google Source Repository
- Google Container Builder

## 事前に準備しておくもの

- 公開用ドメイン

GoDaddyでもGoogleDomainsでもお名前.comでも好きなところから好きなものを取って大丈夫です．

## getting started

### Terraformの初期化

状態のリモート管理を行うために以下のコマンドを実行します．
`{HOGEHOGE}` の箇所は適宜置換が必要です．
`{BACKET_NAME}`はこのあとTerraformで自動生成するので variables.tf ファイルの backend_backet_name と一致させておく必要がある．


```shell
terraform init \
    -backend-config="credentials={PATH}" \
    -backend-config="bucket={BACKET_NAME}" \
    -backend-config="path={PREFIX}"
```

### terraform apply (初回)

variablesの値を参考にterraform.tfvarsファイルを作成するなどしてパラメータを指定してください．
指定後に `terraform apply` を実行してください

## ドメインの認証

初回の `terraform apply` はgcsのバケットを作るところで認証に失敗すると思われます．
Webサイト用に用意したドメインの所有権確認ができていないのが原因です．

[こちらのページ](https://console.cloud.google.com/gcr/triggers)から所有者確認を行ってください．
DNSのテキストレコードの書き換えによる認証ができます。

(注意)
Terraformをサービスアカウントの権限で実行している場合はjsonの中に書かれているclient_emailもドメイン所有者にしておかないとだめなよう．

### terraform apply (最後)

無事に所有権確認ができれば terraform aplly で停止していたところが通過するようになっているはずですので，再度 `terraform apply` を実行してTerraform周りは完了です．


### リポジトリの登録 & ビルドトリガーの設定

ここはHugoを使っていることを前提に説明します．

まず，hugoのインストール後に `hugo new site` を実行し初期ディレクトリを作成してください．
続いてこのディレクトリ上で `git init` を実行し，新たに作成したリポジトリを先程Terraformで作成しておいたリポジトリにpushします．
このとき、以下のサンプルにあるcloudbuild.yamlをリポジトリのルートに配置しておいてください。

[Google Container Registory](https://console.cloud.google.com/gcr/triggers) のトリガー登録ページからトリガーの登録を行います．
先程の source repository の master ブランチが変更された際に，先程リポジトリに含めておいた `cloudbuild.yaml` を実行するようにトリガー登録をしてください．

https://cloud.google.com/container-builder/docs/how-to/build-triggers

トリガー登録ができれば作業完了です．

#### sample: cloudbuild.yaml

今回使っているcloudbuild.yamlはこんな感じです．
このファイルを参照してGoogle Container Builder がビルドとデプロイを行ってくれます．
1つ目のstepをよしなに切り替えることで、jekyllだろうがHexoだろうがこの仕組みに載せることができるのではないかと思います．


(注意)
- `{BLOG_DOAIM}` の箇所はあなたが公開したいドメインに適宜書き換えておいてください．
- `publysher/hugo` はDockerHubから適当に拾って来たものなのですが，そういうのがだめな場合は自分で作ったものを指定すればOKだと思います。

```yaml
steps:
- name: 'publysher/hugo'
  entrypoint: 'hugo'
  args: []
- name: 'gcr.io/cloud-builders/gsutil'
  args: ['rsync', '-R', '/workspace/public', 'gs://{BLOG_DOAIM}']
```


## サイトの更新

git push master すると勝手にビルドが走り出して更新してくれます．
