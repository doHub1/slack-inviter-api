 # slack-inviter-api

任意のslackユーザのinviter(対象ユーザをinviteしたユーザ)をAPI経由で取得可能にする

## 仕組み

現状、slackユーザのinviterをAPIで取得する方法はありません。

inviterを確認するには、管理者アカウントでslackのwebサイトにログインして、[承認済みinvite一覧ページ](https://my.slack.com/admin/invites#accepted)から確認する必要があります。

このプログラムはslackの承認済みinvite一覧ページをスクレイプすることで、指定したユーザのinviterをAPIとして取得可能にします。

## 注意

利用には管理者権限を持ったslackアカウントが必要になります。

ユーザ情報の漏洩を防ぐためAPIサーバへの接続はHTTPS化することを強く推奨します。

## デプロイ手順

### リポジトリのクローン

```
$ git clone https://github.com/knjcode/slack-inviter-api
```

### セットアップ

Ruby 2.2.2 以上が必要です。

```
$ cd slack-inviter-api
$ sudo gem install bundler
$ bundle install --path vendor/bundle
```

### 環境変数を設定

APIアクセス時にtoken認証を行うため、適当なtoken文字列を環境変数 `SECRET_TOKEN` に設定します。

さらに、slackチームのチーム名(サブドメイン)を `TEAM_SUBDOMAIN` に、管理者権限のあるslackアカウント情報を `EMAIL` と `PASSWORD` に設定します。

注：現状、slackの2要素認証を有効化したアカウントは利用できません。

```
$ export SECRET_TOKEN="xxxxxxxxxx"
$ export TEAM_SUBDOMAIN="xxxxxx"
$ export EMAIL="xxxx@xxx.xxx"
$ export PASSWORD="xxxxxxxxxx"
## アプリケーション(Rails)をProductionで動かす場合には SECRET_KEY_BASE も設定します
$ export SECRET_KEY_BASE="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

適当なtoken文字列を生成したい場合は以下のコマンドで作成できます。

```
$ bin/rake secret
```

コマンド実行後に出力された値を環境変数に設定します。

### 起動
※デフォルトだとポート3000番で起動します。
```
$ bin/rails server -b 0.0.0.0

=> Booting Puma
=> Rails 5.0.6 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.11.3 (ruby 2.2.6-p396), codename: Love Song
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

## 使い方

自身で設定したトークンをAuthorizationヘッダに付加し、inviterを確認したいユーザのユーザIDをエンドポイントに含めてGETでAPIエンドポイントにアクセスします。

対象のユーザIDが `U030GEHFM` の場合 `/users/U030GEHFM/inviter` がエンドポイントになり、以下のように利用します。<br>
(サーバが http://0.0.0.0:3000 で起動している場合)
```
$ curl -H "Authorization: Bearer $SECRET_TOKEN" http://0.0.0.0:3000/users/U030GEHFM/inviter

=> {"status":200,"message":"success","inviter_id":"U030HHHBG"}
```
※10秒程度かかるので気長に待つ。<br>
レスポンス本文の `inviter_id` から、ユーザID `U030GEHFM` のinviterであるユーザのID `U030HHHBG` が取得できます。


## 詳細

### エンドポイント

**GET /users/:user_id/inviter**

### リクエスト方法

|リクエストメソッド/ヘッダ|値|
|:---------------------|:-|
|Method                |GET|
|Authorization         |Bearer <SECRET_TOKEN>|

### レスポンス

|レスポンスヘッダ|値|
|:-------------|:-|
|status        |200: 成功<br>400: リクエストが不正<br>401: トークンが無効<br>404: ユーザが見つからない<br>500: サーバ内エラー|
|Content-Type  |application/json|

### レスポンス本文

jsonでレスポンス本文が返却されます

|name      |type  |value description|
|:---------|:---  |:----------------|
|status    |number|HTTP ステータスコードに準拠した値<br>200: 成功<br>400: リクエストが不正<br>401: トークンが無効<br>404: ユーザが見つからない<br>500: サーバ内エラー|
|message   |string|レスポンス内容を表すメッセージ|
|inviter_id|string|inviterのID(取得できなかった場合は要素無し)|


### サンプル

https://example.com/ にAPIサーバが起動しており、対象の `user_id` が `U030GEHFM` の場合

#### 正常処理

```
$ curl -H "Authorization: Bearer $SECRET_TOKEN" https://example.com/users/U030GEHFM/inviter
{"status":200,"message":"success","inviter_id":"U030HHHBG"}
```

#### トークンが不正な場合

```
$ curl -H "Authorization: Bearer $INVALID_TOKEN" https://example.com/users/U030GEHFM/inviter
{"status":401,"message":"invalid_token"}
```

#### 存在しないユーザIDを指定した場合

```
$ curl -H "Authorization: Bearer $SECRET_TOKEN" https://example.com/users/INVALID_ID/inviter
{"status":404,"message":"user_not_found"}
```

slackチームを作成したユーザのIDを指定した場合にも、そもそもinviterがいないため、存在しないユーザIDを指定した場合と同様にAPIから404のレスポンスが返却されます。

