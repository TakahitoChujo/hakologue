# Supabase 設計ドキュメント

> v2.0 プレミアムプラン向け（デバイス間同期・家族共有）

---

## 概要

| 項目 | 内容 |
|------|------|
| BaaS | Supabase |
| DB | PostgreSQL（Supabase マネージド） |
| 認証 | Supabase Auth（JWT + TOTP 2FA） |
| ストレージ | Supabase Storage（写真） |
| 対象規模 | 〜10万人（Supabase Pro $25/月で対応可） |

---

## テーブル設計

### ER 図

```
auth.users
  └─ move_projects
       ├─ project_members
       ├─ project_invitations
       └─ moving_boxes
            ├─ box_photos
            └─ items
```

### move_projects（引越しプロジェクト）

```sql
CREATE TABLE move_projects (
  id           UUID PRIMARY KEY,
  user_id      UUID REFERENCES auth.users(id) NOT NULL,
  name         TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);
```

### project_members（家族共有メンバー）

```sql
CREATE TABLE project_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES move_projects(id) ON DELETE CASCADE NOT NULL,
  user_id    UUID REFERENCES auth.users(id) NOT NULL,
  role       TEXT NOT NULL DEFAULT 'editor', -- 'owner' | 'editor' | 'viewer'
  joined_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (project_id, user_id)
);
```

| role | 操作 |
|------|------|
| owner | 全操作 + メンバー管理 |
| editor | 箱・中身の追加・編集 |
| viewer | 閲覧のみ |

### project_invitations（招待トークン）

```sql
CREATE TABLE project_invitations (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES move_projects(id) ON DELETE CASCADE NOT NULL,
  role       TEXT NOT NULL DEFAULT 'editor',
  token      TEXT UNIQUE NOT NULL,  -- QR コードに埋め込む
  expires_at TIMESTAMPTZ NOT NULL,
  used_at    TIMESTAMPTZ             -- NULL = 未使用
);
```

- トークン有効期限: 24〜72時間を想定
- 使い捨て（`used_at` が入ったら無効）

### moving_boxes（段ボール）

```sql
CREATE TABLE moving_boxes (
  id         UUID PRIMARY KEY,
  project_id UUID REFERENCES move_projects(id) ON DELETE CASCADE NOT NULL,
  name       TEXT NOT NULL,
  room       TEXT NOT NULL,
  is_opened  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  opened_at  TIMESTAMPTZ
);
```

### box_photos（写真）

```sql
CREATE TABLE box_photos (
  id           UUID PRIMARY KEY,
  box_id       UUID REFERENCES moving_boxes(id) ON DELETE CASCADE NOT NULL,
  storage_path TEXT NOT NULL,  -- Supabase Storage のパス
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

> 現在の `MovingBox.photoIds: List<String>` → `box_photos` テーブルに移行

### items（中身リスト）

```sql
CREATE TABLE items (
  id       UUID PRIMARY KEY,
  box_id   UUID REFERENCES moving_boxes(id) ON DELETE CASCADE NOT NULL,
  name     TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  note     TEXT
);
```

---

## 認証設計

### ログイン方法

| 方法 | 用途 |
|------|------|
| Apple Sign In | iOS メイン |
| Google Sign In | Android メイン |
| メール/パスワード | 補助的に対応 |

### 2FA（プレミアム向け）

- TOTP（Google Authenticator / Authenticator アプリ）
- Supabase Auth の MFA 機能で対応

### JWT

- Supabase Auth はデフォルトで JWT 発行
- アクセストークン有効期限: 1時間
- リフレッシュトークンで自動更新

---

## ストレージ設計

### バケット構成

```
hakologue-photos/
  └─ {user_id}/
       └─ {box_id}/
            └─ {photo_id}.jpg
```

### セキュリティ

- バケットは **非公開**
- 署名付き URL（Signed URL）で表示（有効期限付き）
- RLS でアクセス制御

---

## RLS（Row Level Security）設計

### move_projects

```sql
-- 自分が owner または member のプロジェクトのみ取得
CREATE POLICY "projects_select" ON move_projects
  FOR SELECT USING (
    user_id = auth.uid()
    OR id IN (SELECT project_id FROM project_members WHERE user_id = auth.uid())
  );

-- 作成は自分のみ
CREATE POLICY "projects_insert" ON move_projects
  FOR INSERT WITH CHECK (user_id = auth.uid());
```

### moving_boxes / items / box_photos

- `project_id` → `project_members` を経由してアクセス権を確認
- role に応じて INSERT/UPDATE/DELETE を制限

---

## ローカル → クラウド 移行フロー（実装時の考慮事項）

1. ユーザーがプレミアム登録 & ログイン
2. 既存のローカル Hive データを Supabase にアップロード
3. 以降は Supabase をソースオブトゥルースとし、ローカルはキャッシュとして使用
4. オフライン対応: 書き込みはキューに積んで、オンライン時に同期

---

## 未決定事項

- [ ] オフライン同期ライブラリの選定（Drift + 手動同期 or supabase_flutter の realtime）
- [ ] 写真の最大サイズ・枚数制限（ストレージコスト管理）
- [ ] 招待トークンの有効期限（24h / 72h / 1週間）
- [ ] 無料プランとプレミアムプランの機能境界
