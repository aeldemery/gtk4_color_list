public class Gtk4Demo.Color : Gtk.Widget {
    public string color_name { get; set; }
    public Gdk.RGBA color { get; set; }
    public float red {
        get {
            return color.red;
        }
        set {
            color.red = value;
        }
    }
    public float green {
        get {
            return color.green;
        }
        set {
            color.green = value;
        }
    }
    public float blue {
        get {
            return color.blue;
        }
        set {
            color.blue = value;
        }
    }
    public int hue { get; set; }
    public int saturation { get; set; }
    public int value { get; set; }
    public bool selected { get; set; }

    public Color () {
    }

    construct {
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        snapshot.append_color (this.color, { { 0, 0 }, { this.get_width (), this.get_height () } });
    }

    public override void measure (Gtk.Orientation orientation,
                                  int for_size, out int width,
                                  out int height, out int nat_width,
                                  out int nat_height) {
        width = height = nat_width = nat_height = 32;
    }

    public void rgb_to_hsv (Gdk.RGBA rgba, out double h_out, out double s_out, out double v_out) {
        var red = rgba.red;
        var green = rgba.green;
        var blue = rgba.blue;

        double min, max, delta;
        double h = 0.0, s = 0.0, v = 0.0;

        if (red > green) {
            if (red > blue) {
                max = red;
            } else {
                max = blue;
            }

            if (green < blue) {
                min = green;
            } else {
                min = blue;
            }
        } else {
            if (green > blue) {
                max = green;
            } else {
                max = blue;
            }

            if (red < blue) {
                min = red;
            } else {
                min = blue;
            }
        }

        v = max;

        if (max != 0.0) {
            s = (max - min) / max;
        } else {
            s = 0.0;
        }

        if (s == 0.0) {
            h = 0.0;
        } else {
            delta = max - min;

            if (red == max) {
                h = (green - blue) / delta;
            } else if (green == max) {
                h = 2 + (blue - red) / delta;
            } else if (blue == max) {
                h = 4 + (red - green) / delta;
            }

            h /= 6.0;

            if (h < 0.0) {
                h += 1.0;
            } else if (h > 1.0) {
                h -= 1.0;
            }
        }

        h_out = h; s_out = s; v_out = v;
    }
}