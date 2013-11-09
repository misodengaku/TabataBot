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
以前までの内容はすべて<a href="http://totori.dip.jp/tabata/">公式サイト</a>に移動しました。

<a name="environment"></a>
#動作環境

以下は開発環境です。

* Gentoo Linux
* Ruby 1.9.3
* SQLite3
* あとはrequireしてるライブラリをgemで適当に

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

動作環境が整い、すべての設定が済んだら以下のコマンドでbotを起動させます。

	ruby tabata.rb start

起動後はtabata.logにログを吐き続けます。
再起動や停止はそれぞれrestart, stopで行えます。
<a name="history"></a>
#ライセンス

GPL以外ならなんでも


<a name="history"></a>
#改版履歴

## 2013/11/09
* ドキュメント作りに飽きて放置していたので内容が古いです
* 更新する気もないです
* あとは<a href="http://totori.dip.jp/tabata/">こっち</a>にまかせます

##Ver 1.1.0.0  2013/07/27

* NGユーザー機能実装

* 規制をおおざっぱに回避するように

* 諸々

##Ver 1.0.0.0

* とりあえず作って運用したら垢が凍結されて終了

---
Copyright&copy; 2013 @misodengaku, All rights Reserved. 
