# slack-inviter-api

slackユーザのinvite履歴(あるユーザを誰がinviteしたか)をAPI経由で取得可能にする

## 仕組み

現状、slackユーザのinvite履歴をAPIで取得する方法はありません。

invite履歴を確認するには、管理者アカウントでslackのwebサイトにログインして、[承認済みinvite一覧ページ](https://my.slack.com/admin/invites#accepted)を見る必要があります。

このプログラムはslackの承認済みinvite一覧ページをスクレイプすることで、invite履歴をAPIとして取得可能にします。

## 注意

利用には管理者権限を持ったslackアカウントが必要になります。

ユーザ情報が外部に漏えいしないようAPIサーバへの接続はHTTPS化することを強く推奨します。

## デプロイ手順

### リポジトリのクローン

```
$ git clone https://github.com/knjcode/slack-inviter-api
```

### セットアップ

Ruby 2.2.2 以上が必要です。

```
$ cd slack-inviter-api
$ gem install bundler
$ bundle install --path vendor/bundle
```

### 環境変数を設定

管理者権限で閲覧可能となる情報であるため、API時にtoken認証を行います。
任意のtokenを環境変数 `SECRET_TOKEN` に設定します。

さらに、slackチームのチーム名(サブドメイン)を `TEAM_SUBDOMAIN` に、
管理者権限のあるslackアカウント情報を `EMAIL` と `PASSWORD` に設定します。

また、現状はslackの2要素認証を有効化したアカウントの場合には利用できません。


```
$ export SECRET_TOKEN="xxxxxxxxxx"
$ export TEAM_SUBDOMAIN="xxxxxx"
$ export EMAIL="xxxx@xxx.xxx"
$ export PASSWORD="xxxxxxxxxx"
## Productionで動かす場合には SECRET_KEY_BASE も設定します
$ export SECRET_KEY_BASE="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

適当なtokenを生成したい場合は以下のように作成できます。

```
$ bin/rake secret
```

コマンド実行後に出力された値を環境変数に設定します。

### 起動

```
$ bin/rails server
```

## 使い方

アクセス用トークンをAuthorizationヘッダに付加し、inviteした人を確認したいユーザのユーザIDをエンドポイントに含めてGETでアクセスします。

対象のユーザIDが `U030GEHFM` の場合

/users/U030GEHFM/inviter がエンドポイントになり、以下のように利用します。

```
$ curl -H "Authorization: Bearer <SECRET_TOKEN>" https://example.com/users/U030GEHFM/inviter
{"status":200,"message":"success","inviter_id":"U030HHHBG"}
```

レスポンス本文の `inviter_id` から、ユーザID `U030GEHFM` をinviteしたユーザのID `U030HHHBG` が取得できます。


## 詳細

### エンドポイント

**GET /users/:user_id/inviter**

slackのユーザIDが `U030GEHFM` の場合は

**/users/U030GEHFM/inviter** をGETします

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

slackチームを作成したユーザのIDを指定した場合にも、そもそもinviteしたユーザがいないため、存在しないユーザIDを指定した場合と同様にAPIから404のレスポンスが返却されます。

