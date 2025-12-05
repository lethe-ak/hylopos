pragma foreign_keys = 1;

CREATE TABLE IF NOT EXISTS tasks (
	id          INTEGER   PRIMARY KEY AUTOINCREMENT,
	title       TEXT      NOT NULL,
	description TEXT,
	priority    INTEGER   NOT NULL,
	created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deadline    TIMESTAMP
);

-- FOREIGN KEY ... DELETE CASCADEで対応するtasks idの削除に追従して削除
CREATE TABLE IF NOT EXISTS dependencies (
	parent_id INTEGER NOT NULL,
	child_id  INTEGER NOT NULL,
	PRIMARY KEY (parent_id, child_id),
	FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE,
	FOREIGN KEY (child_id)  REFERENCES tasks(id) ON DELETE CASCADE
);

-- タスクグループ group_nameがキーとして機能し、タスクとは多対多の関係
-- パフォーマンスによりgroup_nameではなくgroup_idを置いてgroup_nameとの対応テーブルを作る方が良い可能性がある
CREATE TABLE IF NOT EXISTS task_groups (
	group_name TEXT    NOT NULL,
	task_id    INTEGER NOT NULL,
	PRIMARY    KEY (group_name, task_id),
	FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- グループ名の検索が文字列なのでインデックスを作り高速化しておく
CREATE INDEX IF NOT EXISTS idx_task_groups_name ON task_groups(group_name);
