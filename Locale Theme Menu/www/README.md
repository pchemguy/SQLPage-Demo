## See the demo

[Locale-Theme-Menu Demo](demo.sql)

## Features

- Localization
- Themes
- Complex flexible menu
- Passing information via GET URL parameters
- Hosting files inside the database

### Dummy data source

The only content contained in this demo (as of this writing) is the top menu. This menu is populated from dummy data pulled from the [LibreOffice GitHub repositories](https://github.com/LibreOffice). The data used includes menu item labels, svg icon files, and localization JSON files.

### Project file structure

The sqlpage.json config file defines the web root as "www". The present definition uses a file-based database file (memory based file may not work at present due to [this issue](https://github.com/lovasoa/SQLpage/issues/461)) located in the "db" subdirectory. The "src" subdirectory contains locale and theme data

### Menu

#### Definition formats

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

In the latter case, the entire menu needs to be constructed as a single string. This string should contain the definition of the whole menu formatted as a JSON array of objects, with each object defining one menu item (a top-level line with its dropdown submenu). This form provides extra flexibility in case you do not know the number of menu items in advance (for example, the menu might evolve with project or project might heavily use dynamic menus). For the object form, each menu item needs a separate "menu_item" field, which must be defined at the development stage. A JSON packaged menu is constructed entirely at runtime. If properly coded, the code does not care about the number of menu items: whatever is defined in the current JSON file or a dedicated database table is transformed into the target JSON format.

#### Dynamic menus

The demo menu includes six menu items. Five of them are defined in the "menus" database table. The last menu, which provides the ability to change the language is constructed dynamically based on the available locations.

The fifth menu, which immediately precedes the language menu, contains Login/Logout and SingUp/UserProfile items (associated functionality is either faked or not implemented at all). The usual logic is to show one button from each of these two sets based on whether the user is authenticated or not (in this case, no actual authentication is implemented, but the associated behavior is demonstrated via the Login/Logout pair). For demonstration purposes, the fourth menu (Help) is also hidden when the Login item is clicked.

Each menu line may include a text label, and either a tabler icon or an image-file-based icon. As you can see from the demo, line may show only the label, only the icon, or both. The icon, shown at the top of the Language menu is also set dynamically to reflect the currently used location.
### Localization

This demo incorporates a proof-of-concept implementation of localization. As noted above, the dummy data is pulled from the Libre office project. While the primary (English) version was defined by somewhat laborious copy-pasting of individual items, I did not want to repeat the same process multiple times. So I did some full-text search of the source code for JSON files defining the mapping between the English labels and their translated versions. Because I am not familiar with the LibreOffice repository, I pulled the best suited localization files, even though none of them covered all English-defined menu labels. Therefore the logic is to use translated labels whenever available according to the selected language and fallback to English labels, where translated versions are not available.

### Themes

### Hosting files inside the database

### Passing information via GET URL parameters
