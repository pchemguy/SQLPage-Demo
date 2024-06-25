-- Loads file data into the "sqlpage_files" database table

-- Assumes that the database file is located in the "db" directory next to SQLPage 
-- executable. The website root is in "www" next to SQLPage. The source files to
-- be served from the database are placed in the "src" directory next to SQLPage
-- and their relative paths inside "www" must match the target paths inside "wwww"
-- (same as their "virtual" paths stored in the "sqlpage_files".
--
-- This script requires the fileIO SQLite extension (readfile()). For text files,
-- such as .svg, the script may be adapted to use sqlpage.read_file_as_text().

WITH
    -- Queries the list of databases, selects the path of the main
    -- database, splits the path via JSON, and extracts prefix.
    
    path_terms AS (
        SELECT
            json_remove(
                json('["' || replace(replace(file, '\', '/'), '/', '", "') || '"]'),
                '$[#-1]'
            ) AS terms
        FROM pragma_database_list()
        WHERE name = 'main'
    ),
    
    -- The next CTE replaces the trailing "db" in the database prefix with "src" to
    -- produce an absolute prefix for source files in "src".
    
    db_path AS (
        SELECT
            replace(replace(replace(
                json_set(terms, '$[#-1]', 'src'),
                '["', ''), '"]', ''), '","', '/') AS prefix
        FROM path_terms
    ),
    targets AS (
        SELECT
            sqlpage_files.path,
            db_path.prefix || '/' || sqlpage_files.path AS abs_path
        FROM sqlpage_files, db_path
        WHERE contents IS NULL OR length(contents) = 0
    ),
    data AS (
        SELECT path, readfile(abs_path) AS file_data
        FROM targets
    )
UPDATE sqlpage_files SET contents = iif(
    sha3(file_data) = sha3(CAST(file_data AS TEXT)), CAST(file_data AS TEXT), file_data
)
FROM data
WHERE sqlpage_files.path = data.path;
