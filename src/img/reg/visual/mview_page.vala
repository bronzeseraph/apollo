using Gtk;
using Gdk;
using apollo.img.reg;

namespace apollo.img.reg.visual
{
    public class MviewPage : Gtk.EventBox
    {
        /* MEMBERS */
        public apollo.img.reg.Volume vol;
        private float[,,] smoothed_vol;
        public Image img;
        public int z 
        {
            get
            {
                return this._z;
            }
            set
            {
                this._z = value;

                if(this._z < 0) this._z = 0;
                if(this._z >= this.vol.dim[2])
                {
                    this._z = (this.vol.dim[2] - 1);
                }
            }
        }

        /* PRIVATE VARIABLES */
        private int _z;

        public MviewPage(apollo.img.reg.Volume vol)
        {
            Object();
            this.vol = vol;
            this._z = 0;
            this.smoothed_vol = new float[this.vol.dim[0], this.vol.dim[1], this.vol.dim[2]];

            this.img = new Image.from_pixbuf(new Pixbuf(Colorspace.RGB, false, 8, this.vol.dim[0], this.vol.dim[1]));

            this.add(this.img);
            this.add_events((int)EventMask.SCROLL_MASK);
            this.scroll_event.connect(scroll);

            //this.refresh();

            this.redraw();
        }

        private bool scroll(EventScroll e)
        {
#if DEBUG
            stdout.printf("ScrollEvent caught: %s\n", scroll_dir_string(e.direction));
#endif

            if(
                    ((e.direction & ScrollDirection.DOWN) == ScrollDirection.DOWN) ||
                    ((e.direction & ScrollDirection.LEFT) == ScrollDirection.LEFT)
              )
            {
#if DEBUG
                stdout.printf("Decrementing...\n");
#endif
                this._z--;
                if(this._z < 0) this._z = 0;
            }
            else if(
                    ((e.direction & ScrollDirection.UP) == ScrollDirection.UP) ||
                    ((e.direction & ScrollDirection.RIGHT) == ScrollDirection.RIGHT)
                   )
            {
#if DEBUG
                stdout.printf("Incrementing...\n");
#endif
                this._z++;
                if(this._z >= this.vol.dim[2]) this._z = (this.vol.dim[2] - 1);
            }

            this.redraw();

#if DEBUG
            stdout.printf("ScrollEvent status: z = %d\n", this.z);
#endif

            return false;
        }

        public static string scroll_dir_string(ScrollDirection d)
        {
            switch(d)
            {
                case ScrollDirection.UP:
                    return "UP";
                case ScrollDirection.DOWN:
                    return "DOWN";
                case ScrollDirection.LEFT:
                    return "LEFT";
                case ScrollDirection.RIGHT:
                    return "RIGHT";
                case ScrollDirection.SMOOTH:
                    return "SMOOTH";
                default:
                    return "<UNKNOWN>";
            }
        }

#if 0
        public void refresh()
        {
            int dims[3] = {0, 0, 0};
            for(int i = 0; i < 3; i++) dims[i] = this.vol.dim[i];

            for(int x = 0; x < dims[0]; x++)
            {
                for(int y = 0; y < dims[1]; y++)
                {
                    for(int z = 0; z < dims[2]; z++)
                    {
                        for(int dx = -1; dx < 2; dx++)
                        {
                            for(int dy = -1; dy < 2; dy++)
                            {
                                for(int dz = -1; dz < 2; dz++)
                                {
                                    this.smoothed_vol[
                                        (x + dx + dims[0]) % dims[0], 
                                        (y + dy + dims[1]) % dims[1], 
                                        (z + dz + dims[2]) % dims[2]] += this.vol.data[x,y,z];
                                }
                            }
                        }
                    }
                }
            }
        }
#endif

        public void redraw()
        {
#if DEBUG
            stdout.printf("MViewPage.redraw() slice %d\n", this._z);
#endif

            var pixbuf = this.img.pixbuf;

            var data = (uint8*)pixbuf.pixels;

            long idx = 0;

            for(int x= 0; x < this.vol.dim[0]; x++)
            {
                for(int y = 0; y < this.vol.dim[1]; y++)
                {
                    idx = ((this.vol.dim[0] * y) + x) * 3;
                    uint8 pval = (uint8)(((this.vol.data[x,y,this._z] - 1f) * -1) * 255);

                    data[idx + 0] = pval;
                    data[idx + 1] = pval;
                    data[idx + 2] = pval;
                }
            }

            this.remove(this.img);

            this.img = new Image.from_pixbuf(pixbuf);

            this.add(this.img);

            this.img.show_all();
        }
    }
}
