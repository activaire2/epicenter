#! /bin/bash
mainplaylist="/home/main.m3u"
duration=12 #hours
playlist1="/home/1 bed.m3u"
playlist2="/home/2.m3u"
playlist3="/home/3.m3u"
playlist4="/home/4.m3u"
C1="/home/5.m3u"

tempfile=temp.m3u
let "time=$duration * 60 * 60"
pasteinput=""

#Shuffling the playlists
for i in {1..4}
do
playlist="playlist$i"
playlistname=${!playlist}
pasteinput=$pasteinput" playlisttemp"$i
shuf $playlistname >"playlisttemp"$i
done
#Concatenates all shuffled playlists into a temp file, column wise
`paste $pasteinput > $tempfile`

awk -v C="$C1" -v time="$time" -v pl1="${playlist1%".m3u"}" -v pl2="${playlist2%".m3u"}" -v pl3="${playlist3%".m3u"}" -v pl4="${playlist4%".m3u"}" -v pl5="${C1%".m3u"}" -F $'\t'  'BEGIN {
dur=0;
n = split(pl1, array, "/");
plist[1]=array[n];
n = split(pl2, array, "/");
plist[2]=array[n];
n = split(pl3, array, "/");
plist[3]=array[n];
n = split(pl4, array, "/");
plist[4]=array[n];
n = split(pl5, array, "/");
plist[5]=array[n];
}
{
for(i = 1; i <= NF; i++) {
if(!($i in play))
play[$i];
else
continue;

#Calling the script to get track duration
cmd="/usr/bin/mp3info -p  %S \x22"$i"\x22"
cmd2="/usr/bin/mp3info -p  %f \x22"$i"\x22"
cmd3="/usr/bin/mp3info -p  %t-%a \x22"$i"\x22"

if(cmd | getline result) {
dur+=result
}
close(cmd)

if(dur>time) exit 0;
printf "\"" > "log.txt"
if(cmd2 | getline result) {
printf "%s", result > "log.txt"
}
close(cmd2)
printf "\" | \"" > "log.txt"
if(cmd3 | getline result) {

printf "%s",result > "log.txt"
}
close(cmd3)
printf "\" **** " > "log.txt"
printf "\"%s\"\n", plist[i] > "log.txt"
print $i;
}
#Adding commercials
if (!getline line  < C)
close (C)

cmd="/usr/bin/mp3info -p  %S \x22"line"\x22"
cmd2="/usr/bin/mp3info -p  %f \x22"line"\x22"
cmd3="/usr/bin/mp3info -p  %t-%a \x22"line"\x22"
if(cmd | getline result) {
dur+=result
}
close(cmd)
if(dur>time) exit 0;
printf "\"" > "log.txt"
if(cmd2 | getline result) {
printf "%s", result > "log.txt"
}
close(cmd2)
printf "\" | \"" > "log.txt"
if(cmd3 | getline result) {

printf "%s",result > "log.txt"
}
close(cmd3)
printf "\" **** " > "log.txt"
printf "\"%s\"\n", plist[5] > "log.txt"
print line

}
END{
if(dur<time)
print "Playlists finished early!!!"
}
' $tempfile  >$mainplaylist

for i in {1..4}
do
rm "playlisttemp"$i
done
rm $tempfile
