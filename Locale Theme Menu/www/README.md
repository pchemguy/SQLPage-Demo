## See the demo

[Locale-Theme-Menu Demo](demo.sql) (this link only works when the "index.sql" file is loaded by SQLPage).

## Dummy data source

The only content contained in this demo (as of this writing) is the top menu. This menu is populated from dummy data pulled from the [LibreOffice GitHub repositories](https://github.com/LibreOffice). The data used includes menu item labels, svg icon files, and localization JSON files.

## Features

- Localization
  The rightmost "Language" menu (only a globe or language symbol is shown) is functional. Select different languages to observe translated menus. Because translation files are real and incomplete, missing items are displayed in English.
- Themes
  The "Theme" menu is functional and permits switching between the included themes (one icon-library-based and one image-based).
- Simulated Login/Logout
  The "Options" menu (only a cog is shown to the left of the "Theme" menu) is mostly not functional. However, pressing the top button imitates the Login/Logout process and adjusts the "Options" and "Help" menu.
- UI Customization
  The button shown on the page toggles language labels in the Language menu.
- Complex flexible menu
- Passing information via the GET URL parameters

## Project file structure

The sqlpage.json config file defines "www" as the web root. The present definition uses a file-based database file located in the "db" directory (a memory-based database may not work due to [this issue](https://github.com/lovasoa/SQLpage/issues/461)). The database includes two user-populated tables ("menus" and "sqlpage_files"). The "menus" table contains menu configuration data. The "sqlpage_files" table "belongs" to SQLPage and hosts files served from the database. This demo serves locale/theme files (JSON configs and images) from the database. The original locale/theme files in the repository's "src" directory are not used by the demo directly. All required data is inserted into the database via included migrations, also containing SQL-encoded blobs of necessary files.

The original development workflow involved collecting the metadata for these tables on Excel spreadsheets (the file src/Menu.xls is included in the repo as is without further explanations). Excel formulas were used for generating the (VALUES) clause, and the resulting SQL was included as part of respective INSERT statements inside the migration files. Files in the "sqlpage_files" table were handled separately using additional scripts from the "SQLutil" directory. One script, prepared from Excel-generated VALUES data, was used to update the "sqlpage_files" table containing previously loaded metadata (note, this SQLite script requires a custom-compiled SQLite library that includes its optional fileIO extension). Another script helped dump the entire "sqlpage_files" table (including the file blobs) as an INSERT statement, which was copied into the associated migration file.

## Localization

This demo incorporates a proof-of-concept implementation of localization. As noted above, the dummy data is pulled from the LibreOffice project. While the primary (English) version was defined by somewhat laborious copy-pasting of individual items, I did not want to repeat the same process multiple times. So, I did some full-text search of the source code for JSON files containing the mapping between the English labels and their translated versions. Because I am not familiar with the LibreOffice repository, I pulled the best-suited localization files, even though none of them covered all English-defined menu labels. Therefore, the logic is to use translated labels whenever available according to the selected language and fallback to English labels, where translated versions are not available.

## Themes

The demo contains two themes (a theme presently includes a set of icons used on the top menu). The default set uses Tabler icons, natively supported by SQLPage. The demo also includes one custom theme containing a set of icons from the LibreOffice project.

## Menu

### Definition formats

SQLPage environment is well-suited for serving the menu from a database table or a dedicated JSON file. Either way, any sufficiently elaborate menu probably should not be hardcoded even as a part of a header.sql script to be loaded via sqlpage.run_sql() by all pages.

SQLPage generally provides two approaches to defining the top menu as a part of the "shell" component: either via the "object" form:

```sql
SELECT
    'shell' AS component,
    ...
    <menu_item_1 definition> AS menu_item,
    <menu_item_2 definition> AS menu_item,
    ...
```

or via the "dynamic" component.

In the latter case, the entire menu needs to be constructed as a single string. This string should contain the definition of the whole menu formatted as a JSON array of objects, with each object defining one menu item (a top-level line with its dropdown submenu). This form provides extra flexibility when you do not know the number of menu items in advance (for example, the menu might evolve with the project or the project might heavily use dynamic menus). When the object form is used, each menu item needs a separate "menu_item" field, which must be defined at the development stage. A JSON-packaged menu is constructed entirely at runtime. If properly coded, the code does not care about the number of menu items: whatever is defined in the current JSON file or a dedicated database table is transformed into the target JSON format.

### Dynamic and conditional generation

The demo menu includes seven menus, with five defined in the "menus" database table. The "Theme" and "Language" menus are constructed dynamically based on the available locales/themes as defined in the "locales.json" / "themes.json" files. (When files are served from the database, and robust naming conventions are adopted, locale/theme data availability may be determined by querying the "sqlpage_files" table and doing pattern matching against the path field (and, perhaps, defining/using extra metadata fields). In fact, the demo script already uses this approach to access the JSON files defining individual locale/theme configurations.

The sixth menu, which immediately precedes the language menu, contains Login/Logout and SingUp/UserProfile items (the associated functionality is either faked or not implemented at all). The usual logic is to show one button from each of these two sets based on whether the user is authenticated or not (in this case, no actual authentication is implemented, but the associated behavior is demonstrated via the Login/Logout pair). For demonstration purposes, the fourth menu (Help) is hidden when the Login item is clicked.

### Customization and fine tuning

Each menu line may include a text label and either a Tabler icon or an image-file-based icon. As you can see from the demo, menu lines may show only the label, only the icon, or both. All of these options are demonstrated in the demo. The icon shown at the top of the Language menu is also set dynamically to reflect the currently used location.

Observe the extra white spacing on the right side of the Edit/Insert/Help menus. This "issue" is due to the "min-width" attribute set by Tabler. The most straightforward approach is to reset this attribute on menu elements. However, this approach is also unreliable. When just labels (see the "Theme" menu) or just icons (see the Options menu) are used on a submenu, the "inherit" setting appears to work ok. But with both icons and labels shown, it becomes unreliable. In this demo, I use a custom "shell" component, which takes the class attribute defined at the top level of menu_items and applies it to submenu items. The SQL code of the demo automatically assigns two classes to each submenu (menu\_{label} and menu\_{label}\_slim), which can be adjusted from a custom css file. Moreover, an even further level of customization is used, where these classes are assigned conditionally to the Language menu: one of them is only assigned to the Language submenu for English and German locales, and another one is only assigned if the option to hide language labels is set.

## Passing information via URL GET parameters

Because theme/locale/login status is controlled via the URL GET parameters, care is taken to ensure that changing one option does not reset the others. As explained in an earlier post, I have the following code at the top of the module:

```sql
SET $_get_vars = (
    SELECT json_group_object("key", value)
    FROM json_each(sqlpage.variables('GET'))
    WHERE NOT "key" like '~_%' ESCAPE '~'
);
```

which saves existing GET parameters. Then, when I need to change on of the GET parameters, I generate an updated URL suffix with the following code:

```sql
    SELECT '?' || group_concat("key" || '=' || value, '&' ORDER BY "key")
    FROM json_each(json_patch($_get_vars, json_object('{PARAM-NAME}', {PARAM-VALUE})))
```


![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Locale%20Theme%20Menu/Screenshot/1.png)
![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Locale%20Theme%20Menu/Screenshot/2.png)
![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Locale%20Theme%20Menu/Screenshot/3.png)
![](https://raw.github.com/pchemguy/SQLPage-Demo/main/Locale%20Theme%20Menu/Screenshot/4.png)
