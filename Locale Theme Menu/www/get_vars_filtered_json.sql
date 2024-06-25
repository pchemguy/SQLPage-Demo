-- Retrieve GET URL parameters and return a filtered JSON object
--
-- The FROM clause uses the json_each() function to convert the GET parameters
-- into a table, the WHERE clause filters out local (SET) variables based on
-- the adopted naming convention (name starts with underscore), and the SELECT
-- clause uses json_group_object() to repack GET parameters into an array.
--
-- SET $_get_vars = (
--     SELECT json_group_object("key", "value")
--     FROM  json_each(sqlpage.variables('GET'))
--     WHERE "key" NOT LIKE '~_%' ESCAPE '~'
-- );
--
-- The extended implementation also tries to convert numeric values stored as text.
--
SELECT
    json_group_object("key",
        iif(CAST(CAST(value AS NUMERIC) AS TEXT) = value,
            CAST(value AS NUMERIC), value)
    )
FROM
    json_each(sqlpage.variables('GET'))
WHERE NOT "key" like '~_%' ESCAPE '~';
