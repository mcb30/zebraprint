"""Zebra printer device"""

import binascii
import logging
import pathlib
import re
import selectors
from passlib.utils import pbkdf2
from .config import ZebraConfigRoot

logger = logging.getLogger(__name__)


class UnknownVariableError(LookupError):
    """Unknown configuration variable"""
    pass


class ZebraDevice(object):
    """A Zebra printer device"""

    DEFAULT_PATH = '/dev/usb/lp0'
    """Default path to Zebra device"""

    MAX_RESPONSE_LEN = 16384
    """Maximum expected response length for any command"""

    DEFAULT_TIMEOUT = 2.0
    """Timeout used when reading from device"""

    config = ZebraConfigRoot()

    def __init__(self, path=None, timeout=None):
        self.path = pathlib.Path(path if path is not None
                                 else self.DEFAULT_PATH)
        self.timeout = timeout if timeout is not None else self.DEFAULT_TIMEOUT
        self.sel = selectors.DefaultSelector()
        self.fh = None

    def __repr__(self):
        return '%s(%r)' % (self.__class__.__name__, str(self.path))

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    def __getitem__(self, key):
        return self.getvar(key)

    def __setitem__(self, key, value):
        self.setvar(key, value)

    def open(self):
        """Open device"""
        self.fh = self.path.open('r+b', buffering=0)
        self.sel.register(self.fh, selectors.EVENT_READ)

    def close(self):
        """Close device"""
        self.sel.unregister(self.fh)
        self.fh.close()

    def write(self, data, printable=True):
        """Write data to device"""
        logger.debug('tx: %s',
                     data.decode().strip() if printable else data.hex())
        self.fh.write(data)

    def read(self, expect=None, printable=True):
        """Read data from device

        There is no consistent structure or delimiter for data read
        from the device.  The only viable approach is to read until an
        expected pattern match is seen, or a timeout occurs.
        """
        data = b''
        while self.sel.select(self.timeout):
            data += self.fh.read(self.MAX_RESPONSE_LEN)
            if expect is not None and re.fullmatch(expect, data):
                break
        if not data:
            raise TimeoutError
        logger.debug('rx: %s', data.decode() if printable else data.hex())
        return data

    def do(self, action, param=''):
        """Execute command"""
        self.write(b'! U1 do "%s" "%s"\r\n' %
                   (action.encode(), param.encode()))

    def setvar(self, name, value):
        """Set variable value"""
        self.write(b'! U1 setvar "%s" "%s"\r\n' %
                   (name.encode(), value.encode()))

    def setint(self, name, value):
        """Set integer variable value"""
        self.setvar(name, str(value))

    def setbool(self, name, value):
        """Set boolean variable value"""
        self.setvar(name, 'on' if value else 'off')

    def getvar(self, name):
        """Get variable value"""
        self.write(b'! U1 getvar "%s"\r\n' % name.encode())
        value = self.read(rb'".+?"').decode()
        if value == '"?"':
            raise UnknownVariableError(name)
        return value.strip('"')

    def getint(self, name):
        """Get integer variable value"""
        return int(self.getvar(name))

    def getbool(self, name):
        """Get boolean variable value"""
        value = self.getvar(name)
        if value == 'on':
            return True
        elif value == 'off':
            return False
        raise ValueError("%s: invalid value '%s'" % (name, value))

    def reset(self):
        """Reset device"""
        self.do('device.reset')

    def restore_defaults(self, category):
        """Restore configuration defaults"""
        self.do('device.restore_defaults', category)

    def list(self):
        """List files"""
        self.do('file.dir')
        return self.read().decode().strip('"')

    def delete(self, filename):
        """Remove file"""
        self.do('file.delete', filename)

    def rename(self, oldname, newname):
        """Rename file"""
        self.do('file.rename', '%s %s' % (oldname, newname))

    def download(self, filename):
        """Download file"""
        self.do('file.type', filename)
        return self.read(printable=False)

    def upload(self, filename, content):
        """Upload file"""
        self.write(b'! CISDFCRC16\r\n0000\r\n%s\r\n%08x\r\n0000\r\n%s' %
                   (filename.encode(), len(content), content), printable=False)

    def upgrade(self, firmware):
        """Upgrade firmware"""
        self.write(bytes(firmware))

    def wifi(self, essid, password, auth='wpa_psk'):
        """Configure WiFi ESSID and password"""
        self.restore_defaults('wlan')
        self.setvar('wlan.essid', essid)
        getattr(self, 'wifi_%s' % auth)(essid, password)

    def wifi_wpa_psk(self, essid, password):
        """Configure WiFi ESSID and WPA-PSK password"""
        raw = pbkdf2.pbkdf2(password.encode(), essid.encode(), 4096, 32)
        psk = binascii.b2a_hex(raw).decode().upper()
        self.setbool('wlan.wpa.enable', True)
        self.setvar('wlan.wpa.authentication', 'psk')
        self.setvar('wlan.wpa.psk', psk)
