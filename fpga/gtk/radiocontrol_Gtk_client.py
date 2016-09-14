#import pygtk
#pygtk.require("2.0")
#import gtk
#import gtk.glade
from gi.repository import Gtk, Gdk, GLib, GObject, Pango
#import pango
import string
import time
import math
import socket
import sys
import threading
import serial
import numpy as np

# Settings start

comm_mode = "Serial"  # Serial or Socket
serial_port = "/dev/ttyUSB0"
socket_addr = "192.168.0.25"
socket_port = 8899

# Settings end

if_freq = 45000

freq = 1000.0
vol = 17
volscroll = 0
quit_flag = 0
comm_fail = 0

USB = 1
LSB = 2
CW = 3
AM = 4

I2C_ERR = 1
SOCK_ERR = 2

mode_set = USB

if comm_mode == "Socket":
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    except (socket.error, msg):
        print ("Failed to create socket. Error code: " + str(msg[0]) + " , Error message : " + msg[1])
        sys.exit()
   
    try:
        sock.connect((socket_addr , socket_port))
    except socket.error:
        print ("Connection failed.")
        sys.exit()
    
    print ("Socket connected.")

elif comm_mode == "Serial":
    try:
        ser = serial.Serial(serial_port)
    except:
        print ("Connection failed.")
        sys.exit()


def setMode(mode):
    global mode_set
    if (mode == AM):
        message = "mode AM "
        cmd = b'\x40'
    elif (mode == LSB):
        message = "mode LSB "
        cmd = b'\x70' # LSB
    elif (mode == USB):
        message = "mode USB "
        cmd = b'\x78' # USB
    elif (mode == CW):
        message = "mode CWN "
        cmd = b'\x60' # LSB narrow
    if comm_mode == "Socket":
        try:
            sock.sendall(message.encode())
            mode_set = mode
        except socket.error:
            print ("Send failed")
            comm_fail = SOCK_ERR
    elif comm_mode == "Serial":
        try:
            ser.write(cmd + b'\x00\x00\x00\x00')
            mode_set = mode
        except:
            print ("Send failed")
            comm_fail = SOCK_ERR

def updateFreq():
    global freq
    if (freq<0):
        freq = 0
    elif (freq>30000):
        freq=30000
    message = "freq " + str(freq) + " "
    entryone.set_text("{:^16}".format("{:,.3f} kHz".format(freq))) 
    
    if comm_mode == "Socket":
        try:
            sock.sendall(message.encode())
            Gtk.Entry.set_icon_from_icon_name(entryone,Gtk.EntryIconPosition.SECONDARY,"gtk-ok")
        except socket.error:
            comm_fail = SOCK_ERR
    elif comm_mode == "Serial":
        ftw = (if_freq-freq)*279.620266666666 #pow(2,25)/(6*20000)
        ftw_toptop = math.floor(ftw/16777216); 
        ftw_topbot = math.floor((ftw-ftw_toptop*16777216)/65536) #math.floor(ftw/pow(2,16))
        ftw_bottop = math.floor((ftw-ftw_toptop*16777216-ftw_topbot*65536)/256) #math.floor((ftw-ftw_top*pow(2,16))/pow(2,8))
        ftw_botbot = round(ftw%256) #round(ftw%pow(2,8))
        try:
            ser.write(bytes([0xc0,np.uint8(ftw_toptop), np.uint8(ftw_topbot), np.uint8(ftw_bottop), np.uint8(ftw_botbot)]))
            Gtk.Entry.set_icon_from_icon_name(entryone,Gtk.EntryIconPosition.SECONDARY,"gtk-ok")
        except:
            comm_fail = 1


def updateVol():
    global vol
    global comm_fail
    if comm_mode == "Socket":
        message = "vol " + str(int(vol)) + " "
        try:
            sock.sendall(message.encode())
        except:
            comm_fail = 1
    elif comm_mode == "Serial":
        try:
            ser.write(bytes([0x07,0,0,0,31-int(vol)]))
        except:
            comm_fail = 1

def updateRssi():  # To be run as thread
    global quit_flag
    global comm_fail
    while (quit_flag == 0):
        #print("rssi")
        time.sleep(0.2)
        if comm_mode == "Serial":
            #try:
            ser.write(b'\x00\x00\x00\x00\x00')
            time.sleep(0.1)
            rssi_val = (ser.read()[0] & b'\x1f'[0]) - 4
            #print(rssi_val)
            GLib.idle_add(updateRssiGtk, rssi_val)
            ser.flushInput()
            comm_fail = 0
            #except:
             #   comm_fail = 1

def commMonitor(): # To be run as thread
    global quit_flag
    global comm_fail
    while (quit_flag == 0):
        time.sleep(1)
        GLib.idle_add(commMonitorGtk, comm_fail)

def commMonitorGtk(comm_fail):
    if (comm_fail == SOCK_ERR):
        Gtk.Label.set_text(statustext, "Error. No socket connection.")
    elif (comm_fail == I2C_ERR):
        Gtk.Label.set_text(statustext, "Error. No I2C connection.")
    else:
        Gtk.Label.set_text(statustext, "Connection established.")

def updateRssiGtk(rssi_val):
    Gtk.LevelBar.set_value (rssibar, rssi_val)

class Handler:
    def OnDeleteWindow(self, *args):
        Gtk.main_quit(*args)

    def OnBandUpPressed(self, *args):
        global freq
        freq = freq + 1000
        updateFreq()

    def OnBandDownPressed(self, *args):
        global freq
        freq = freq - 1000
        updateFreq()

    def FreqScroll(self, scroller, event):
        global freq
        global mode_set
        if event.direction == Gdk.ScrollDirection.UP:
            if (mode_set==AM):
                freq = freq + 2
            elif (mode_set==USB or mode_set==LSB):
                freq = freq + 0.1
            elif (mode_set==CW):
                freq = freq + 0.05
        elif event.direction == Gdk.ScrollDirection.DOWN:
            if (mode_set==AM):
                freq = freq - 2
            elif (mode_set==USB or mode_set==LSB):
                freq = freq - 0.1
            elif (mode_set==CW):
                freq = freq - 0.05
        updateFreq()   

    def VolScroll(self, scroller, event):
        global volscroll
        #Gtk.Label.set_text(labelone, "Scroll!")
        if event.direction == Gdk.ScrollDirection.UP:
            volscroll = 1
        elif event.direction == Gdk.ScrollDirection.DOWN:
            volscroll = 2

    def VolChange(self, r):
        global vol
        global volscroll
        vol = r.get_value()
        if (volscroll == 1): # scrolled up
            r.set_value(3)
            vol = r.get_value()
        elif (volscroll == 2): # scrolled down
            r.set_value(3)
            vol = r.get_value()
        volscroll = 0
        updateVol()

    def NewFreqEntry(self,e,*args):
        global freq
        freqstring = e.get_text()
        freqstring = freqstring.rstrip(string.ascii_letters+" ,") # remove letters at beg and end
        #freqstring = string.join(freqstring.split()) # Remove spaces
        #freqstring = string.join(freqstring.split('.')) # Remove dots
        #freqstring = string.join(freqstring.split(',')) # Remove commas
        freq = float(freqstring)
        updateFreq()

    def FreqEdited(self,e,*args):
        Gtk.Entry.set_icon_from_icon_name(e,Gtk.EntryIconPosition.SECONDARY,"gtk-execute")

    def ModeToggle(self,b):
        
        if (b == USB_button and Gtk.ToggleButton.get_active(USB_button)):
            setMode(USB)
        elif (b == LSB_button and Gtk.ToggleButton.get_active(LSB_button)):
            setMode(LSB)
        elif (b == CW_button and Gtk.ToggleButton.get_active(CW_button)):
            setMode(CW)
        elif (b == AM_button and Gtk.ToggleButton.get_active(AM_button)):
            setMode(AM)

builder = Gtk.Builder()
builder.add_from_file("radiocontrol.glade")
builder.connect_signals(Handler())

volscale = builder.get_object("scale1")

labelone = builder.get_object("label2")
#Gtk.Label.set_text(labelone, "Ugh")
statustext = builder.get_object("statuslabel")

entryone = builder.get_object("entry1")
#nyfont = pango.FontDescription("Sans 18")
#Gtk.Widget.modify_font(entryone, nyfont)

rssibar = builder.get_object("rssibar")
Gtk.LevelBar.set_value (rssibar, 0)

USB_button = builder.get_object("USB_button")
LSB_button = builder.get_object("LSB_button")
CW_button = builder.get_object("CW_button")
AM_button = builder.get_object("AM_button")

css_provider = Gtk.CssProvider()
css_provider.load_from_data ("#entry1 {font: Sans 18; color: rgb(255,0,0);}".encode())
entryone_context = entryone.get_style_context ()
entryone_context.add_provider(css_provider,1)
entryone.add_events(Gdk.EventMask.SCROLL_MASK) 
window = builder.get_object("window1")
window.show_all()  

updateFreq()
updateVol()


#rxdata = sock.recv(1024)

#print (rxdata.decode())

GObject.threads_init()

threadRssi = threading.Thread(target=updateRssi)
threadCommMon = threading.Thread(target=commMonitor)

threadRssi.daemon = True
threadRssi.start()
threadCommMon.daemon = True
threadCommMon.start()

Gtk.main()

quit_flag = 1
sock.close()
