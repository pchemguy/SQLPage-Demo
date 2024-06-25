SELECT
    'INSERT OR IGNORE INTO "sqlpage_files"("prefix", "name", "tag", "src_url", "contents") VALUES' || x'0A' ||
    group_concat('    (' || concat_ws(', ',
		quote("prefix"), quote("name"), quote("tag"), quote("src_url"), quote("contents")
    ) || ')', ',' || x'0A') || ';' || x'0A'
    AS value
FROM sqlpage_files;
