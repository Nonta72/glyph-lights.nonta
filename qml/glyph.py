import subprocess
import os

GLYPH_CTRL = '/usr/bin/glyph_ctrl'
STATE_FILE = '/tmp/glyph_state'

def set_glyph(value):
    """
    Set glyph brightness.
    value: 'on', 'off', or an integer 0-4095.
    Returns True on success.
    """
    try:
        arg = str(value)
        result = subprocess.run([GLYPH_CTRL, arg], timeout=3)
        # Persist numeric brightness so we can restore the slider position
        if arg == 'off':
            saved = '0'
        elif arg == 'on':
            saved = '4095'
        else:
            saved = arg
        with open(STATE_FILE, 'w') as f:
            f.write(saved)
        return result.returncode == 0
    except Exception as e:
        print('glyph error: ' + str(e))
        return False

def get_glyph_brightness():
    """
    Read last known brightness from state file.
    Returns an integer 0-4095.
    """
    try:
        with open(STATE_FILE, 'r') as f:
            val = int(f.read().strip())
            return max(0, min(4095, val))
    except:
        return 0
