## 
## montaziera (montagiere) creates a montage preview based on CSV timecodes
## version 0.1
## https://github.com/Arty2/montaziera
## 

## Set extention of output clips and cut
$outputext = ".mp4";

## Create required files and folders
New-Item -Force "./concat.txt";
New-Item -ItemType Directory -Force -Path "./clips"

## Create blank video with minimum sound
ffmpeg -f lavfi -i "color=c=white:s=640x360:d=1" `
	-f lavfi -i anullsrc=cl=stereo:r=32000 -shortest `
	-codec:v libx264 -codec:a aac -preset ultrafast `
		-avoid_negative_ts make_zero -fflags +genpts `
	-v quiet -stats -loglevel fatal `
	-n "./clips/000$outputext";
Add-Content "./concat.txt" "file `'./clips/000$outputext`'";

## Count CSV lines
$inputcsv = "./timecodes.csv";
[int]$csvlines = 0
$reader = New-Object IO.StreamReader $inputcsv
while($reader.ReadLine() -ne $null){ $csvlines++ }
## Loop through CSV
[int]$i = 1;
Import-Csv $inputcsv -Header ('material','file','start','end','duration','super','descr') -Delimiter "," | Foreach-Object { 
	$num = ([string]$i).PadLeft(3,'0')
	$filename = $_.PSObject.Properties['filename'].value;
	$ext = [System.IO.Path]::GetExtension($filename);
	$start = $_.PSObject.Properties['start'].value;
	$duration = $_.PSObject.Properties['duration'].value;
	$super = $_.PSObject.Properties['super'].value;
	$descr = $_.PSObject.Properties['descr'].value;

	$filters = "`"scale=640:360, setsar=1, `
		drawtext=fontfile='/Windows/Fonts/arial.ttf': text='$num': fontcolor=white: fontsize=12: box=1: boxcolor=black@0.5: boxborderw=5: x=(w-text_w-30): y=30, `
		drawtext=fontfile='/Windows/Fonts/arial.ttf': text='${descr}': fontcolor=white: fontsize=12: box=1: boxcolor=black@0.2: boxborderw=5: x=30: y=(h-40), `
		drawtext=fontfile='/Windows/Fonts/arial.ttf': text='${super}': fontcolor=white: fontsize=12: box=1: boxcolor=black@0.5: boxborderw=5: x=30: y=(h-70), `
		fps=25`"";

	$output = "./clips/$num$outputext";

	## Clip video and store to /clips/
	# -video_track_timescale 12800
	# -avoid_negative_ts make_zero -fflags +shortest `
	echo "Clip $num / $csvlines"
	If ($ext -eq ".mp4" -Or $ext -eq ".mov") {
		ffmpeg -ss $start -i $filename -t $duration `
		-codec:v libx264 -codec:a aac -ar 32000 -fflags +shortest -max_interleave_delta 0 -preset ultrafast `
		-filter_complex $filters `
		-avoid_negative_ts make_zero -fflags +genpts `
		-v quiet -stats -loglevel fatal `
		-n $output;
	}
	ElseIf ($ext -eq ".jpg" -Or $ext -eq ".png") {
		ffmpeg -loop 1 -framerate 25 -i $filename -ss $start -t $duration `
		-codec:v libx264 -codec:a aac -ar 32000 -preset ultrafast `
		-filter_complex $filters `
		-avoid_negative_ts make_zero -fflags +genpts `
		-v quiet -stats -loglevel fatal `
		-n $output;
	}
	Else {
		# do nothing
	}

	## Add to contact file
	Add-Content "./concat.txt" "file `'$output`'";

	## Increment temporary name
	$global:i++
}

## Concat clips
$versioning = $(Get-Date).ToString('yyyy-MM-dd_hh-mm');

## Concatenate all clips
ffmpeg -safe 0 -f concat -segment_time_metadata 1 -i "./concat.txt" `
	-codec:v libx264 -codec:a aac -preset ultrafast `
	-vf select=concatdec_select -af aselect=concatdec_select,aresample=async=1 `
	-v quiet -stats -loglevel fatal `
	"./preview_$versioning.mp4";


# resources
#
# https://stackoverflow.com/questions/35416110/ffmpeg-concat-video-and-audio-out-of-sync
# https://stackoverflow.com/questions/53021266/non-monotonous-dts-in-output-stream-previous-current-changing-to-this-may-result