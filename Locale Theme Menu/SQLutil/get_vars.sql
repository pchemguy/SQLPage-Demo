SELECT 
    'redirect' AS component,
    '?lang=en&theme=fancy&hide_language_names=1&authenticated=0' AS link
WHERE length(sqlpage.variables('GET')) <= 2;

SET $_get_vars = (
    SELECT
        json_group_object(
            "key",
            iif(CAST(CAST(value AS NUMERIC) AS TEXT) = value,
                     CAST(value AS NUMERIC), value)
        ) AS get_var
    FROM
        json_each(sqlpage.variables('GET'))
    WHERE "key" NOT LIKE '\_%' ESCAPE '\'
);

SET $_get_vars_patched = json_patch($_get_vars, '{"lang": "xx"}');


SET $_get_suffix = (
    SELECT
        '?' || group_concat("key" || '=' || value, '&' ORDER BY "key") AS "GET Suffix"
    FROM json_each(json_patch($_get_vars, '{"lang": "xx"}'))
);

SELECT $_get_suffix;