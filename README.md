# テックヒルズ×iBeaconハッカソン
2014年06月28日開催の「テックヒルズ×iBeaconハッカソン」に参加した時の成果物です。スライドは[slideshare](http://www.slideshare.net/KatsuyaShimada/techhils20140628)に上げておきました。

# client
クライアント側は2種類のアプリがあります。ibeaconの電波を受信する側とwebsocketのイベント通知を受ける側です。前者はenemy、後者はfriendディレクトリに格納してあります。

## enemy
beacon電波を監視します。ソースにはUUIDとmajor番号、マイナー番号がハードコーディングしてあります。指定されたbeaconの領域内に入るとサーバにbeaconとの相対距離とユーザIDを通知します（ユーザIDは適当です）。

## friend
beaconとは通信しません。serverからwebsocketのイベント通知を持って画面に表示します。画面にはサーバから受け取ったユーザIDを表示し、サーバから受け取った距離情報ニ応じてUIViewの背景の色を変更します。距離が近いほど赤い色になります。

# server
サーバ側はNode.jsです。ポート番号3000番でクライアント側のfriendと通信します。enemyから受けた情報をfirendに渡すシンプルな実装です。


