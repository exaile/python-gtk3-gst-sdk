
# Check
if [ -z "$(which 7z)" ]; then
    echo "7z not found, needed to extract packages... exiting!"
    exit 1
fi

# extract the gi binaries
PYGI="$BUILD_ENV"/pygi
echo "extract pygi-aio..."
7z x -o"$PYGI" -y "$BUILD_ENV/bin/${PYGI_EXE}" > /dev/null
echo "done"
echo "extract packages..."
(cd "$PYGI"/rtvc9-32/ && find . -name "*.7z" -execdir 7z x -y {} > /dev/null \;)
(cd "$PYGI"/noarch/ && find . -name "*.7z" -execdir 7z x -y {} > /dev/null \;)
(cd "$PYGI"/binding/py2.7-32 && 7z x -y py2.7-32.7z > /dev/null)
echo "done"

# prepare our binary deps
mkdir "$DEPS"

for name in rtvc9-32 noarch; do
    for package in ATK Aerial Base Curl GCrypt GDK GDKPixbuf GSTPlugins \
        GSTPluginsExtra GSTPluginsMore GTK GnuTLS Graphene Gstreamer \
        HarfBuzz IDN JPEG Jack LibAV OpenEXR OpenJPEG OpenSSL Orc Pango \
        SQLite Soup StdCPP TIFF WebP; do
    cp -R "$PYGI"/"$name"/"$package"/gnome/* "$DEPS"
    done
done

# remove ladspa, frei0r
rm -Rf "$DEPS"/lib/frei0r-1
rm -Rf "$DEPS"/lib/ladspa

# remove opencv
rm -Rf "$DEPS"/share/opencv

# other stuff
rm -Rf "$DEPS"/lib/gst-validate-launcher
rm -Rf "$DEPS"/lib/gdbus-2.0
rm -Rf "$DEPS"/lib/p11-kit

# remove some large gstreamer plugins..
GST_LIBS="$DEPS"/lib/gstreamer-1.0
rm -f "$GST_LIBS"/libgstflite.dll # Flite speech synthesizer plugin
rm -f "$GST_LIBS"/libgstopencv.dll # OpenCV Plugins
rm -f "$GST_LIBS"/libgstx264.dll # H264 plugins
rm -f "$GST_LIBS"/libgstcacasink.dll # Colored ASCII Art video sink
rm -f "$GST_LIBS"/libgstschro.dll # Schroedinger plugin
rm -f "$GST_LIBS"/libgstjack.dll # Jack sink/source
rm -f "$GST_LIBS"/libgstpulse.dll # Pulse sink
rm -f "$GST_LIBS"/libgstvpx.dll # VP8
rm -f "$GST_LIBS"/libgstomx.dll # errors on loading
rm -f "$GST_LIBS"/libgstdaala.dll # Daala codec
rm -f "$GST_LIBS"/libgstmpeg2enc.dll # mpeg video encoder
rm -f "$GST_LIBS"/libgstdeinterlace.dll # video deinterlacer
rm -f "$GST_LIBS"/libgstopenexr.dll # OpenEXR image plugin
rm -f "$GST_LIBS"/libgstmxf.dll # MXF Demuxer

rm -f "$GST_LIBS"/libgstpythonplugin*.dll
