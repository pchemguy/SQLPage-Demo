DROP TABLE IF EXISTS menus;

CREATE TABLE IF NOT EXISTS menus (
    label        TEXT PRIMARY KEY COLLATE NOCASE NOT NULL,
    link         TEXT COLLATE NOCASE,
    tabler_icon  TEXT COLLATE NOCASE,
    icon_only    INTEGER NOT NULL DEFAULT 0,
    parent_label TEXT COLLATE NOCASE REFERENCES menus(label),
    position     INTEGER NOT NULL,
    attributes   TEXT COLLATE NOCASE NOT NULL DEFAULT (json_object()),
    state_filter TEXT COLLATE NOCASE NOT NULL DEFAULT (json_object())
);

INSERT INTO menus(label, tabler_icon, icon_only, parent_label, link, position, state_filter) VALUES
    ('File', 'file', 0, NULL, NULL, 1, json('{}')),
    ('New', 'file-neutral', 0, 'File', 'new.sql', 1, json('{}')),
    ('Open', 'folder-open', 0, 'File', 'open.sql', 2, json('{}')),
    ('Close', 'file-off', 0, 'File', 'close.sql', 3, json('{}')),
    ('Save', 'device-floppy', 0, 'File', 'save.sql', 4, json('{}')),
    ('Save As', '', 0, 'File', 'save_as.sql', 5, json('{}')),
    ('Save a Copy', '', 0, 'File', 'save_a_copy.sql', 6, json('{}')),
    ('Save All', '', 0, 'File', 'save_all.sql', 7, json('{}')),
    ('Export', 'file-export', 0, 'File', 'export.sql', 8, json('{}')),
    ('Print Preview', '', 0, 'File', 'print_preview.sql', 9, json('{}')),
    ('Print', 'printer', 0, 'File', 'print.sql', 10, json('{}')),
    ('Printer Settings', '', 0, 'File', 'printer_settings.sql', 11, json('{}')),
    ('Properties', 'file-settings', 0, 'File', 'properties.sql', 12, json('{}')),
    ('Digital Signatures', 'certificate', 0, 'File', 'digital_signatures.sql', 13, json('{}')),
    ('Exit', 'square-rounded-x', 0, 'File', 'exit.sql', 14, json('{}')),

    ('Edit', 'edit', 0, NULL, NULL, 2, json('{}')),
    ('Undo', 'arrow-back', 0, 'Edit', 'undo.sql', 1, json('{}')),
    ('Redo', 'arrow-forward', 0, 'Edit', 'redo.sql', 2, json('{}')),
    ('Repeat', 'repeat', 0, 'Edit', 'repeat.sql', 3, json('{}')),
    ('Cut', 'cut', 0, 'Edit', 'cut.sql', 4, json('{}')),
    ('Copy', 'copy', 0, 'Edit', 'copy.sql', 5, json('{}')),
    ('Paste', 'clipboard-text', 0, 'Edit', 'paste.sql', 6, json('{}')),
    ('Select All', 'select-all', 0, 'Edit', 'select_all.sql', 7, json('{}')),
    ('Find', 'file-search', 0, 'Edit', 'find.sql', 8, json('{}')),
    ('Find & Replace', 'replace', 0, 'Edit', 'find___replace.sql', 9, json('{}')),

    ('Insert', 'components', 0, NULL, NULL, 3, json('{}')),
    ('Image', 'photo', 0, 'Insert', 'image.sql', 1, json('{}')),
    ('Chart', 'chart-bar', 0, 'Insert', 'chart.sql', 2, json('{}')),
    ('OLE Object', '', 0, 'Insert', 'ole_object.sql', 3, json('{}')),
    ('Shape', 'prism', 0, 'Insert', 'shape.sql', 4, json('{}')),
    ('Section', 'text-plus', 0, 'Insert', 'section.sql', 5, json('{}')),
    ('Text Box', 'text-resize', 0, 'Insert', 'text_box.sql', 6, json('{}')),
    ('Comment', 'message-2', 0, 'Insert', 'comment.sql', 7, json('{}')),
    ('Hyperlink', 'circles-relation', 0, 'Insert', 'hyperlink.sql', 8, json('{}')),
    ('Bookmark', 'bookmark', 0, 'Insert', 'bookmark.sql', 9, json('{}')),

    ('Help', 'question-mark', 0, NULL, NULL, 4, json_object('authenticated', FALSE)),
    ('Help Contents', 'help', 0, 'Help', 'help_contents.sql', 1, json('{}')),
    ('What''s This', 'pointer-question', 0, 'Help', 'whats_this.sql', 2, json('{}')),
    ('Tip of the Day', 'bulb', 0, 'Help', 'tip_of_the_day.sql', 3, json('{}')),

    ('Theme', 'icons', 0, NULL, NULL, 5, json('{}')),

    ('Options', 'settings', 1, NULL, NULL, 6, json('{}')),
    ('Login', 'login', 1, 'Options', '?authenticated=1', 1, json_object('authenticated', FALSE)),
    ('Logout', 'logout', 1, 'Options', '?authenticated=0', 2, json_object('authenticated', TRUE)),
    ('Sign Up', 'user-scan', 1, 'Options', 'sign_up.sql', 3, json_object('authenticated', FALSE)),
    ('Profile', 'user', 1, 'Options', 'profile.sql', 4, json_object('authenticated', TRUE)),

    ('Language', 'world-longitude', 1, NULL, NULL, 7, json('{}'));
