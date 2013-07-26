概要
=====

田端でバタバタbot(<a href="https://twitter.com/Batabata_Tabata">@Batabata_Tabata</a>)のソースコードです。

## 目次
* [あそびかた](#howtoplay)
* [動作環境](#environment)
* [設定ファイル](#configure)
* [ライセンス](#license)
* [改版履歴](#history)

<a name="howtoplay">
#あそびかた

* 「田端でバタバタ」とつぶやくと@Batabata_Tabataがふぁぼってきます。
* 単体でつぶやくかスペースで区切らないと認識されません(UserStreamの仕様、あとで何とかする)。

* OK例：「田端でバタバタ」　「田端でバタバタ #tabata」
* NG例：「田端でバタバタなう」　「田端でバタバタした」

* 運がいいと@Batabata_Tabataが「○○さんがxx:xx:xxに田端でバタバタしました。通算x回目です。」のようにつぶやいてくれます。

* つぶやかれなかった場合でも回数は内部で記録されます。
* 具体的には85秒に1回つぶやきます（規制回避のため）。

<a name="environment"></a>
#動作環境

以下は開発環境です。

* Gentoo Linux (何でもいいと思います)
* Ruby 1.9.3 (2.0系でも動きそう)
* SQLite3 3.7.15.2
* sqlite3 (gem)
* tweetstream (gem)
* daemon-spawn (gem)

抜けている物があったら適宜インストールしてください。

<a name="configure"></a>
#設定ファイル

以下の形式に従ってtabata.confファイルに書き込んでください。


	screen_name: スクリーンネーム(@以降)
	consumer_key: コンシューマーキー
	consumer_secret: コンシューマーシークレット
	oauth_token: アクセストークン
	oauth_token_secret: アクセスシークレット

アクセストークンに関しては<a href="http://getaccesstoken.herokuapp.com/">get OAuth access_token</a>などを使用すると簡単です。

また、tabata.dbに以下のようなテーブルを作成してください。


	CREATE TABLE users (screen_name text, count int, recent text);


動作環境が整い、すべての設定が済んだら以下のコマンドでbotを起動させます。

	ruby tabata.rb start

起動後はtabata.logにログを吐き続けます。
再起動や停止はそれぞれrestart, stopで行えます。
<a name="history"></a>
#ライセンス

GPL以外ならなんでも


<a name="history"></a>
#改版履歴

##Ver 1.1.0.0  2013/07/27

* NGユーザー機能実装

* 規制をおおざっぱに回避するように

* 諸々

##Ver 1.0.0.0

* とりあえず作って運用したら垢が凍結されて終了

---
Copyright&copy; 2013 @misodengaku, All rights Reserved. 