const {Gdk, GdkPixbuf, Gio, GLib, GObject, Gtk} = imports.gi;

const Renderer = imports.ui.renderer;

var Klass = GObject.registerClass({
    Implements: [Renderer.Renderer],
    Properties: {
        fullscreen: GObject.ParamSpec.boolean('fullscreen', '', '',
                                              GObject.ParamFlags.READABLE,
                                              false),
        ready: GObject.ParamSpec.boolean('ready', '', '',
                                         GObject.ParamFlags.READABLE,
                                         false)
    },
}, class GlbRenderer extends Gtk.DrawingArea {
    get ready() {
        return !!this._ready;
    }

    get fullscreen() {
        return !!this._fullscreen;
    }

    _init(file) {
        super._init();

        this._pix = null;
        this._scaledSurface = null;
        this._tmpPath = GLib.build_filenamev([
            GLib.get_tmp_dir(),
            `sushi-glb-${GLib.get_monotonic_time()}.png`
        ]);

        this._renderGlb(file);
        this.connect('destroy', this._onDestroy.bind(this));
    }

    _renderGlb(file) {
        let path = file.get_path();

        let proc;
        try {
            proc = new Gio.Subprocess({
                argv: [
                    'f3d',
                    '--config=thumbnail',
                    '--load-plugins=native',
                    '--verbose=quiet',
                    `--output=${this._tmpPath}`,
                    '--resolution=1024,1024',
                    path
                ],
                flags: Gio.SubprocessFlags.STDOUT_SILENCE |
                       Gio.SubprocessFlags.STDERR_SILENCE,
            });
            proc.init(null);
        } catch(e) {
            this.emit('error', e);
            return;
        }

        proc.wait_async(null, (obj, res) => {
            try {
                obj.wait_finish(res);
                this._pix = GdkPixbuf.Pixbuf.new_from_file(this._tmpPath);
                this._scaledSurface = null;
                this.queue_resize();
                this.isReady();
            } catch(e) {
                this.emit('error', e);
            }
        });
    }

    vfunc_get_preferred_width() {
        return [1, this._pix ? this._pix.get_width() : 1];
    }

    vfunc_get_preferred_height() {
        return [1, this._pix ? this._pix.get_height() : 1];
    }

    vfunc_size_allocate(allocation) {
        super.vfunc_size_allocate(allocation);
        this._ensureScaledPix();
    }

    vfunc_draw(context) {
        if (!this._scaledSurface)
            return false;

        let width = this.get_allocated_width();
        let height = this.get_allocated_height();
        let scaleFactor = this.get_scale_factor();

        let offsetX = (width - this._scaledSurface.getWidth() / scaleFactor) / 2;
        let offsetY = (height - this._scaledSurface.getHeight() / scaleFactor) / 2;

        context.setSourceSurface(this._scaledSurface, offsetX, offsetY);
        context.paint();
        return false;
    }

    _ensureScaledPix() {
        if (!this._pix)
            return;

        let scaleFactor = this.get_scale_factor();
        let width = this.get_allocated_width() * scaleFactor;
        let height = this.get_allocated_height() * scaleFactor;

        let origWidth = this._pix.get_width();
        let origHeight = this._pix.get_height();

        let scale = Math.min(width / origWidth, height / origHeight);
        if (!this.fullscreen)
            scale = Math.min(scale, 1.0 * scaleFactor);

        let newWidth = Math.floor(origWidth * scale);
        let newHeight = Math.floor(origHeight * scale);

        let scaledWidth = this._scaledSurface ? this._scaledSurface.getWidth() : 0;
        let scaledHeight = this._scaledSurface ? this._scaledSurface.getHeight() : 0;

        if (newWidth == scaledWidth && newHeight == scaledHeight)
            return;

        let scaledPixbuf = this._pix.scale_simple(newWidth, newHeight,
                                                  GdkPixbuf.InterpType.BILINEAR);
        this._scaledSurface = Gdk.cairo_surface_create_from_pixbuf(
            scaledPixbuf, scaleFactor, this.get_window());
    }

    get resizePolicy() {
        return Renderer.ResizePolicy.SCALED;
    }

    _onDestroy() {
        try {
            Gio.File.new_for_path(this._tmpPath).delete(null);
        } catch(e) {}
    }
});

var mimeTypes = ['model/gltf-binary', 'model/gltf+json'];
