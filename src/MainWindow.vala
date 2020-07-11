using Gtk;
public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {

    /* Some Widgets */
    HeaderBar header;  ScrolledWindow sw; Box box; DropDown dropdown;
    Grid grid; GridView selection_view; GridView gridview;
    Revealer selection_info_revealer; Picture selection_average_picture;
    ToggleButton selection_info_toggle; Label selection_size_label;
    Button button; Label label;

    ListItemFactory factory;
    GLib.ListStore factories; GLib.ListStore sorters;
    GLib.ListModel model; GLib.ListModel selection_filter; GLib.ListModel no_selection;
    Sorter sorter; Sorter multi_sorter;

    Expression expression;

    Pango.AttrList attrs;
    CssProvider provider;

    ColorListModel color_list_model;


    public MainWindow (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        this.title = "Colors";
        this.set_default_size (600, 400);

        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/github/aeldemery/gtk4_color_list/listview_colors.css");
        StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, 800);

        header = new Gtk.HeaderBar ();
        header.show_title_buttons = true;
        this.set_titlebar (header);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.set_child (box);

        selection_info_revealer = new Gtk.Revealer ();
        box.append (selection_info_revealer);

        grid = new Gtk.Grid ();
        selection_info_revealer.set_child (grid);
        with (grid) {
            margin_start = margin_end = margin_top = margin_bottom = 10;
            row_spacing = 10;
            column_spacing = 10;
        }

        label = new Gtk.Label ("Selection");
        label.hexpand = true;
        label.add_css_class ("title-3");
        grid.attach (label, 0, 0, 5, 1);

        grid.attach (new Gtk.Label ("Size:"), 0, 2, 1, 1);

        selection_size_label = new Gtk.Label ("0");
        grid.attach (selection_size_label, 1, 2, 1, 1);

        grid.attach (new Gtk.Label ("Average:"), 2, 2, 1, 1);

        selection_average_picture = new Gtk.Picture ();
        selection_average_picture.set_size_request (32, 32);
        grid.attach (selection_average_picture, 3, 2, 1, 1);

        label = new Gtk.Label ("");
        label.hexpand = true;

        grid.attach (label, 4, 2, 1, 1);

        sw = new Gtk.ScrolledWindow ();
        sw.hexpand = true;
        sw.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        grid.attach (sw, 0, 1, 5, 1);

        factory = new SignalListItemFactory ();
        (factory as SignalListItemFactory).setup.connect (setup_selection_listitem_cb);

        selection_view = new Gtk.GridView.with_factory (factory);
        selection_view.add_css_class ("compact");
        selection_view.max_columns = 200;
        sw.set_child (selection_view);

        sw = new Gtk.ScrolledWindow ();
        box.append (sw);

        gridview = create_color_grid ();
        sw.set_child (gridview);
        sw.hexpand = true;
        sw.vexpand = true;

        model = gridview.model;
        selection_filter = new Gtk.SelectionFilterModel (model as SelectionModel);
        selection_filter.items_changed.connect (update_selection_count);
        selection_filter.items_changed.connect (update_selection_average);

        no_selection = new Gtk.NoSelection (selection_filter);
        selection_view.model = no_selection;

        model.get ("model", model); /* I don't understand getting the model property form inside model!! */

        selection_info_toggle = new Gtk.ToggleButton ();
        selection_info_toggle.icon_name = "emblem-important-symbolic";
        selection_info_toggle.tooltip_text = "Show selection info";

        header.pack_start (selection_info_toggle);

        selection_info_toggle.bind_property ("active", selection_info_revealer, "reveal-child");

        button = new Gtk.Button.with_mnemonic ("_Refill");
        // color_list_model = (model as Gtk.SortListModel).get_model();
        button.clicked.connect (refill);

        header.pack_start (button);

        label = new Label ("0 /");
        attrs = new Pango.AttrList ();
        attrs.insert (new Pango.AttrFontFeatures ("tnum"));
        label.attributes = attrs;
        label.width_chars = "4096".length + 2;
        label.xalign = 1;

        gridview.model.items_changed.connect (items_changed_cb);

        header.pack_start (label);

        dropdown = new DropDown ();
        dropdown.set_from_strings ({ "8", "64", "512", "4096", "32768", "262144", "2097152", "16777216" });
        dropdown.notify["selected"].connect (limit_changed_cb);
        dropdown.notify["selected"].connect (limit_changed_cb2);

        factory = new SignalListItemFactory ();
        (factory as SignalListItemFactory).setup.connect (setup_number_item);
        (factory as SignalListItemFactory).bind.connect (bind_number_item);

        dropdown.factory = factory;
        dropdown.selected = 3; /* 4096 */

        header.pack_start (dropdown);

        sorters = new GLib.ListStore (typeof (Sorter));

        /* An empty multisorter doesn't do any sorting and the sortmodel is
         * smart enough to know that.
         */
        sorter = new MultiSorter ();
        set_the_title (sorter, "Unsorted");
        sorters.append (sorter);

        sorter = new StringSorter (new PropertyExpression (typeof (ColorWidget), null, "name"));
        set_the_title (sorter, "Name");
        sorters.append (sorter);

        multi_sorter = new MultiSorter ();

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "red"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Red");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "green"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Green");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "blue"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Blue");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        set_the_title (multi_sorter, "RGB");
        sorters.append (multi_sorter);

        multi_sorter = new MultiSorter ();

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "hue"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Hue");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "saturation"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Saturation");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        sorter = new NumericSorter (new PropertyExpression (typeof (ColorWidget), null, "value"));
        (sorter as NumericSorter).set_sort_order (SortType.DESCENDING);
        set_the_title (sorter, "Value");
        sorters.append (sorter);
        (multi_sorter as MultiSorter).append (sorter);

        set_the_title (multi_sorter, "HSV");
        sorters.append (multi_sorter);

        dropdown = new DropDown ();
        box = new Box (Orientation.HORIZONTAL, 10);

        box.append (new Label ("Sort by:"));
        box.append (dropdown);

        header.pack_end (box);

        expression = new CClosureExpression (typeof (string), null, null, (GLib.Callback)get_the_title, null, null);
        dropdown.expression = expression;
        dropdown.model = sorters;
        dropdown.bind_property ("selected-item", model, "sorter", BindingFlags.SYNC_CREATE);

        factories = new GLib.ListStore (typeof (ListItemFactory));

        factory = new SignalListItemFactory ();
        (factory as SignalListItemFactory).setup.connect (setup_simple_listitem_cb);
        set_the_title (factory, "Colors");

        factories.append (factory);

        factory = new SignalListItemFactory ();
        (factory as SignalListItemFactory).setup.connect (setup_listitem_cb);
        set_the_title (factory, "Everything");

        factories.append (factory);

        dropdown = new DropDown ();
        box = new Box (Orientation.HORIZONTAL, 10);

        box.append (new Label ("Show:"));
        box.append (dropdown);

        header.pack_end (box);

        expression = new CClosureExpression (typeof (string), null, null, (GLib.Callback)get_the_title, null, null);
        dropdown.expression = expression;
        dropdown.model = factories;
        dropdown.bind_property ("selected-item", gridview, "factory", BindingFlags.SYNC_CREATE);
    }

    void setup_simple_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var expression = new Gtk.ConstantExpression.for_value (list_item);
        var color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        var picture = new Gtk.Picture ();
        picture.set_size_request (32, 32);
        color_expression.bind (picture, "paintable", null);
        list_item.set_child (picture);
    }

    void setup_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        list_item.set_child (box);

        Gtk.Expression expression, color_expression;
        var params = new Gtk.Expression[1];

        expression = new Gtk.ConstantExpression.for_value (list_item);
        color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        expression = new Gtk.PropertyExpression (typeof (ColorWidget), color_expression.ref (), "color-name");

        var name_label = new Gtk.Label (null);
        expression.bind (name_label, "label", null);

        box.append (name_label);

        expression = color_expression.ref ();
        var picture = new Gtk.Picture ();
        expression.bind (picture, "paintable", null);

        box.append (picture);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (GLib.Callback)ColorWidget.get_rgb_markup, null, null);

        var rgb_label = new Gtk.Label (null);
        rgb_label.set_use_markup (true);
        expression.bind (rgb_label, "label", null);

        box.append (rgb_label);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (GLib.Callback)ColorWidget.get_hsv_markup, null, null);

        var hsv_label = new Gtk.Label (null);
        hsv_label.set_use_markup (true);
        expression.bind (hsv_label, "label", null);

        box.append (hsv_label);
    }

    void setup_selection_listitem_cb (Gtk.ListItemFactory factory, Gtk.ListItem list_item) {
        Gtk.Expression expression, color_expression;
        expression = new Gtk.ConstantExpression.for_value (list_item);
        color_expression = new Gtk.PropertyExpression (typeof (Gtk.ListItem), expression, "item");

        var picture = new Gtk.Picture ();
        picture.set_size_request (8, 8);
        color_expression.bind (picture, "paintable", null);
        list_item.set_child (picture);
    }

    static void set_the_title (Object item, string title) {
        item.set_data ("title", title);
    }

    static string get_the_title (Object item) {
        return item.get_data<string>("title");
    }

    Gtk.GridView create_color_grid () {
        var gridview = new Gtk.GridView ();
        with (gridview) {
            hscroll_policy = vscroll_policy = Gtk.ScrollablePolicy.NATURAL;
        }

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_simple_listitem_cb);

        with (gridview) {
            factory = factory;
            max_columns = 24;
            enable_rubberband = true;
        }

        var model = new Gtk.SortListModel (new ColorListModel (0), null);
        var selection = new Gtk.MultiSelection (model);

        gridview.model = selection;

        return gridview;
    }

    bool add_colors (Gtk.Widget widget, Gdk.FrameClock clock) {
        uint limit;
        limit = color_list_model.get_data<uint>("limit");
        color_list_model.size = uint.min (limit, color_list_model.size + uint.max (1, limit / 4096));

        if (color_list_model.size >= limit)
            return GLib.Source.REMOVE;
        else
            return GLib.Source.CONTINUE;
    }

    void refill (Gtk.Button button) {
        color_list_model.size = 0;
        button.add_tick_callback (add_colors);
    }

    void limit_changed_cb (Object object, GLib.ParamSpec pspec) {
        var dropdown = (DropDown) object;
        uint old_limit = color_list_model.get_data<uint>("limit");
        uint new_limit = 1 << (3 * (dropdown.selected + 1));

        color_list_model.set_data ("limit", new_limit);

        if (old_limit == color_list_model.size)
            color_list_model.size = new_limit;
    }

    void limit_changed_cb2 (Object object, GLib.ParamSpec pspec) {
        var dropdown = (DropDown) object;
        uint limit = 1 << (3 * (dropdown.selected + 1));
        label.width_chars = limit.to_string ().length + 2;
    }

    void items_changed_cb (ListModel model, uint position, uint removed, uint added) {
        uint n = model.get_n_items ();
        label.label = n.to_string ();
    }

    void setup_number_item (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var label = new Gtk.Label ("");
        label.xalign = 1;

        var attr = new Pango.AttrList ();
        attr.insert (new Pango.AttrFontFeatures ("tnum"));

        label.set_attributes (attr);
        list_item.set_child (label);
    }

    void bind_number_item (Gtk.SignalListItemFactory factory, Gtk.ListItem list_item) {
        var label = list_item.get_child () as Gtk.Label;

        uint limit = 1 << (3 * (list_item.position + 1));
        label.label = limit.to_string ();
    }

    void update_selection_count (GLib.ListModel model, uint position, uint removed, uint added) {
        selection_size_label.label = model.get_n_items ().to_string ();
    }

    void update_selection_average (GLib.ListModel model, uint position, uint removed, uint added) {
        uint n = model.get_n_items ();
        Gdk.RGBA c = { 0, 0, 0, 1 };
        ColorWidget color;

        for (uint i = 0; i < n; i++) {
            color = model.get_item (i) as ColorWidget;
            c.red = color.color.red;
            c.green = color.color.green;
            c.blue = color.color.blue;
        }

        color = new ColorWidget ("", c.red / n, c.green / n, c.blue / n);

        selection_average_picture.set_paintable (color);
    }
}