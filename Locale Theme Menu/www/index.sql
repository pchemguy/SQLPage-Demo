SELECT
   'dynamic' AS component,
    json_array(
        json_object(
            'component',      'shell',
            'title',          'Locale-Theme-Menu Demo',
            'icon',           'apps',
            'description',    'Description',

            'css',
                json_array(
                    '/css/prism-tabler-theme.css',
                    '/css/style.css'
                ),

            'javascript',
                json_array(
                    'https://cdn.jsdelivr.net/npm/prismjs@1/components/prism-core.min.js',
                    'https://cdn.jsdelivr.net/npm/prismjs@1/plugins/autoloader/prism-autoloader.min.js'
                )

        )
    ) AS properties;

-- =============================================================================


-- README.md --
--
SELECT
    'text'  AS component,
    TRUE    AS center,
    2       AS level,
    'Locale-Theme-Menu Demo' AS title,
    sqlpage.read_file_as_text('./Readme.md') AS contents_md;
