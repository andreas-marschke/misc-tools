#You can easily extract audio from video files such as avi, mpg, even flv! into mp3 uses either mplayer or ffmpeg. You can even record online stream into mp3, such as stream from radio cast.

#Lets begin with mplayer. To extract audio from video files, use -dumpaudio option and specified the output filename with -dumpfile

mplayer -dumpaudio nodame_theme.flv -dumpfile nodame_theme.mp3

#Okay check out the output:

file nodame_theme.mp3

#Output:

#MPEG ADTS, layer III, v2,   8 kBits, 22.05 kHz, Monaural

#Okay, The audio extracted from flv, so quality is quite low, haha. But you can change the audio rate by using ffmpeg. Let see how to use ffmpeg.

ffmpeg -i nodame_theme.flv -ab 128 -ar 44100 nodame_theme.mp3

#-i is to specified input file, -ab audio bitrate, -ar audio sampling frequency

#Let say what file tells you.

#MPEG ADTS, layer II, v1, 128 kBits, 44.1 kHz, Monaural

#How about record online stream?
#First, find an online radio cast to try, you can have plenty of it from shoutcast.

#mplayer -dumpstream http://64.236.34.97:80/stream/1005 -dumpfile smoothjazz.mp3

#ffmpeg -i http://64.236.34.97:80/stream/1005 -ab 128 -ar 44100 smoothjazz.mp3