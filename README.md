## Terraformの初期化

状態のリモート管理を行うために以下の実行が必要．

```shell
terraform init \
    -backend-config="credentials={PATH}" \
    -backend-config="bucket={BACKET_NAME}" \
    -backend-config="path={PREFIX}"
```

バケットはこのあとTerraformで自動生成するので tfvars ファイルの backend_backet_name と一致させておく必要がある．


## ドメインの認証

初回の `Terraform apply` はgcsのバケットを作るところで認証に失敗するので以下のサイトから頑張る

https://console.cloud.google.com/apis/credentials/domainverification

Terraformをサービスアカウントの権限で実行する場合はjsonの中に書かれているclient_emailもドメイン所有者にしておかないとだめなよう．
