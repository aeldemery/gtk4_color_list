public class Gtk4Demo.ColorWidget : GLib.Object, Gdk.Paintable {

    public ColorWidget (string name, float r, float g, float b) {
        _color = { r, g, b, 1.0f };
        this.color_name = name;
    }

    construct {
    }
    // Properties
    public string color_name { get; set; }

    private Gdk.RGBA _color;
    public Gdk.RGBA color {
        get {
            return _color;
        }
        set {
            _color = value;
            double h_local, s_local, v_local;
            rgb_to_hsv (_color, out h_local, out s_local, out v_local);
            _h = (int) GLib.Math.round (360 * h_local);
            _s = (int) GLib.Math.round (100 * s_local);
            _v = (int) GLib.Math.round (100 * v_local);
        }
    }

    public float red {
        get {
            return _color.red;
        }
        set {
            _color.red = value;
        }
    }

    public float green {
        get {
            return _color.green;
        }
        set {
            _color.green = value;
        }
    }

    public float blue {
        get {
            return _color.blue;
        }
        set {
            _color.blue = value;
        }
    }

    int _h;
    public int hue {
        get {
            return _h;
        }
        set {
            _h = value;
        }
    }

    int _s;
    public int saturation {
        get {
            return _s;
        }
        set {
            _s = value;
        }
    }

    int _v;
    public int value {
        get {
            return _v;
        }
        set {
            _v = value;
        }
    }

    public void snapshot (Gdk.Snapshot snapshot, double width, double height) {
        (snapshot as Gtk.Snapshot).append_color (this.color, { { 0, 0 }, { (float) width, (float) height } });
    }

    public Gdk.Paintable get_current_image () {
        return (this.snapshot as Gtk.Snapshot).to_paintable (null);
    }

    public double get_intrinsic_aspect_ratio () {
        return 0.5;
    }

    public Gdk.PaintableFlags get_flags () {
        return Gdk.PaintableFlags.STATIC_SIZE;
    }

    public int get_intrinsic_height () {
        return 32;
    }

    public int get_intrinsic_width () {
        return 32;
    }

    // public override void measure (Gtk.Orientation orientation,
    // int for_size,
    // out int size, out int nat,
    // out int baseline, out int nat_baseline) {
    // size = nat = 32;
    // baseline = nat_baseline = -1;
    // }

    public void rgb_to_hsv (Gdk.RGBA rgba, out double h_out, out double s_out, out double v_out) {
        var red = rgba.red;
        var green = rgba.green;
        var blue = rgba.blue;

        double min, max, delta;
        double h = 0.0, s = 0.0, v = 0.0;

        if (red > green) {
            if (red > blue)
                max = red;
            else
                max = blue;

            if (green < blue)
                min = green;
            else
                min = blue;
        } else {
            if (green > blue)
                max = green;
            else
                max = blue;

            if (red < blue)
                min = red;
            else
                min = blue;
        }

        v = max;

        if (max != 0.0)
            s = (max - min) / max;
        else
            s = 0.0;

        if (s == 0.0)
            h = 0.0;
        else {
            delta = max - min;

            if (red == max)
                h = (green - blue) / delta;
            else if (green == max)
                h = 2 + (blue - red) / delta;
            else if (blue == max)
                h = 4 + (red - green) / delta;

            h /= 6.0;

            if (h < 0.0)
                h += 1.0;
            else if (h > 1.0)
                h -= 1.0;
        }

        h_out = h; s_out = s; v_out = v;
    }

    public string ? get_rgb_markup (ColorWidget ? color) {
        if (color == null) return null;
        return "<b>R:</b> %d <b>G:</b> %d <b>B:</b> %d".printf (
            (int) (color.red * 255),
            (int) (color.green * 255),
            (int) (color.blue * 255)
        );
    }

    public string ? get_hsv_markup (ColorWidget ? color) {
        if (color == null) return null;
        return "<b>H:</b> %d <b>S:</b> %d <b>V:</b> %d".printf (
            color.hue,
            color.saturation,
            color.value
        );
    }
}