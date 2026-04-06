import subprocess
import os

def set_glyph(state):
    """Call glyph_ctrl with 'on' or 'off'. Returns True on success."""
    try:
        result = subprocess.run(
            ['/usr/bin/glyph_ctrl', state],
            timeout=3
        )
        # Since the app is unconfined, QML should read from a well know and easily accessible location.
        with open('/tmp/glyph_state', 'w') as f:
            f.write('1' if state == 'on' else '0')
        return result.returncode == 0
    except Exception as e:
        print('glyph error: ' + str(e))
        return False

def get_glyph_state():
    """Read last known state from flag file. Returns True if on."""
    try:
        with open('/tmp/glyph_state', 'r') as f:
            return f.read().strip() == '1'
    except:
        return False
