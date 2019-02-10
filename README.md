※TECH::EXPERT最終課題用に作成したアプリケーションです。

# README

## アプリケーション概要

**Dm/F : discover music on feelings**

**未知の音楽を、直感的に検索できるサービス**

[Dm/F](http://www.discovermusiconfeelings.com/)

[遊び方のページ](http://www.discovermusiconfeelings.com/how_to)

ユーザに、これまで聴いたことのあるアルバムに対し、それについての直感的な印象(例.Happy、anger、sad など)のタグをつけてもらう。

各アルバムにつけられたタグを集計し、可視化する。

→そのアルバムがどんな印象を持たれがちな作品であるのかがわかる。


こうして見出されたアルバムの印象を、各ユーザはそれぞれの検索活動へと活用できる。


- 活用案1
気になるアーティストがいるが、作品数が多いためどこから聴きはじめればいいかわからない。

→まずは自分の好きないくつかの作品にタグをつけ、自分が好きな作品に対してどんな印象を抱きがちなのか、見つめ直す。

気になるアーティストの作品一覧から、自分の抱きがちな印象のタグが多くついている作品を探し、そこから聴き始める。


- 活用案2

自分が好む傾向の印象はすでに把握できているため、未知のアーティストのそういった作品を探したい。

→タグ検索から、自分の好きな印象のタグが多くつけられた作品を片っ端から試してみる。


## ページ構成
[Top page 1](https://i.imgur.com/KRyC1ax.png)

[Top page 2](https://i.imgur.com/VcNOsIg.png)

[Artist page](https://i.imgur.com/pkxLuht.png)

[Album page](https://i.imgur.com/wpEoA89.png)

[Tag page](https://i.imgur.com/20l4hi4.png)

[User page](https://i.imgur.com/p2qBnKL.png)

## アプリケーション要件

- artistテーブル

各albumにはその作成者となるartistがいる。

※コンピレーションアルバムなど、共作となる作品のために多対多とする。


- albumテーブル

各albumは、各userのつけるtagによって評価される。


- usersテーブル(deviseにより生成)

各userは、deviseによるサインイン情報(email、password等)の他に、ユーザ名やアイコンを設定できる。


- tagsテーブル(acts-as-taggable-onにより生成)

各userは、あらかじめ定義されたtagからひとつを選び、albumの評価をする。


## DB設計

[ER図](https://i.imgur.com/9mgY10q.png)

### artistsテーブル

|Column|Type|Options|
|------|----|-------|
|name|text|null: false, foreign_key: true, add_index|

#### Association

---

### albumsテーブル

|Column|Type|Options|
|------|----|-------|
|spotify_id|text|null: false, foreign_key: true, add_index|

#### Associasion
- acts_as_taggable

---

### usersテーブル
※deviseにより生成。
※icon〜から始まるカラムはpaperclipにより作成。

|Column|Type|Options|
|------|----|-------|
|email|string|null: false, unique: true, add_index|
|name|text|null: false, unique: true, add_index|
|icon_file_name|string| |
|icon_content_type|string| |
|icon_file_size|integer| |
|icon_updated_at|datetime| |

#### Association
- acts_as_tagger

---

### tagsテーブル
※acts-as-taggable-onにより生成。

|Column|Type|Options|
|------|----|-------|
|name|string|foreign_key: true, unique: true, add_index|
|taggings_count|integer| |
|color|text| |

#### Association
- belongs_to :tagging

---

### taggingsテーブル
※tagsテーブルとusersテーブル、albumsテーブルによるポリモーフィック関連。
acts-as-taggable-onにより生成。

|Column|Type|Options|
|------|----|-------|
|tag_id|integer|foreign_key: true|
|taggable_type|string|add_index|
|taggable_id|integer|add_index|
|tagger_type|string|add_index|
|tagger_id|integer|add_index|
|context|string|add_index|

#### Assosiation
- has_many :tags
