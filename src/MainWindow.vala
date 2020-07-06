public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {

    public ColorListModel color_list_model;

    public MainWindow (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        this.title = "Colors";
        this.set_default_size (600, 400);

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/github/aeldemery/gtk4_color_list/listview_colors.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, 800);

        var header = new Gtk.HeaderBar ();
        header.show_title_buttons = true;
        this.set_titlebar (header);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.set_child (box);

        var selection_info_revealer = new Gtk.Revealer ();
        box.append (selection_info_revealer);

        var grid = new Gtk.Grid ();
        selection_info_revealer.set_child (grid);
        with (grid) {
            margin_start = margin_end = margin_top = margin_bottom = 10;
            row_spacing = 10;
            column_spacing = 10;
        }

        var label = new Gtk.Label ("Selection");
        label.hexpand = true;
        label.add_css_class ("title-3");
        grid.attach (label, 0, 0, 5, 1);
        grid.attach (new Gtk.Label ("Size:"), 0, 2, 1, 1);

        var selection_size_label = new Gtk.Label ("0");
        grid.attach (selection_size_label, 1, 2, 1, 1);
        grid.attach (new Gtk.Label ("Average:"), 2, 2, 1, 1);

        var selection_average_picture = new Gtk.Picture ();
        selection_average_picture.set_size_request (32, 32);
        grid.attach (selection_average_picture, 3, 2, 1, 1);

        label = new Gtk.Label ("");
        label.hexpand = true;

        grid.attach (label, 4, 2, 1, 1);

        var scrolled_win = new Gtk.ScrolledWindow ();
        scrolled_win.hexpand = true;
        scrolled_win.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        grid.attach (scrolled_win, 0, 1, 5, 1);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (setup_selection_listitem_cb);

        var selection_view = new Gtk.GridView.with_factory (factory);
        selection_view.add_css_class ("compact");
        selection_view.max_columns = 200;
        scrolled_win.set_child (selection_view);

        scrolled_win = new Gtk.ScrolledWindow ();
        box.append (scrolled_win);

        var gridview = create_color_grid ();
        scrolled_win.set_child (gridview);
        scrolled_win.hexpand = true;
        scrolled_win.vexpand = true;

        var model = gridview.model;
        var selection_filter = new Gtk.SelctionFilterModel();
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
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (Callback) ColorWidget.get_rgb_markup, null, null);

        var rgb_label = new Gtk.Label (null);
        rgb_label.set_use_markup (true);
        expression.bind (rgb_label, "label", null);

        box.append (rgb_label);

        params[0] = color_expression.ref ();
        expression = new Gtk.CClosureExpression (typeof (string), null, params, (Callback) ColorWidget.get_hsv_markup, null, null);

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

    static void set_title (Object item, string title) {
        item.set_data ("title", title);
    }

    static string get_title (Object item) {
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

    void limit_changed_cb (Gtk.DropDown dropdown, GLib.ParamSpec pspec) {
        uint old_limit = color_list_model.get_data<uint>("limit");
        uint new_limit = 1 << (3 * (dropdown.selected + 1));

        color_list_model.set_data ("limit", new_limit);

        if (old_limit == color_list_model.size)
            color_list_model.size = new_limit;
    }

    void limit_changed_cb2 (Gtk.DropDown dropdown, GLib.ParamSpec pspec, Gtk.Label label) {
        uint limit = 1 << (3 * (dropdown.selected + 1));
        label.width_chars = limit.to_string ().length + 2;
    }

    void items_changed_cb (ListModel model, uint position, uint removed, uint added, Gtk.Widget label) {
        uint n = model.get_n_items ();
        (label as Gtk.Label).label = n.to_string ();
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

    void update_selection_count (GLib.ListModel model, uint position, uint removed, uint added, Object data) {
        (data as Gtk.Label).label = model.get_n_items ().to_string ();
    }

    void update_selection_average (GLib.ListModel model, uint position, uint removed, uint added, Object data) {
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

        (data as Gtk.Picture).set_paintable (color);
    }
}