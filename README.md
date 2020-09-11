# /montaziera

Montaziera (a play on the equivalent of “montagiere” in Greek) is a video-editing tool, that creates a preview or a rough cut using [ffmpeg](https://ffmpeg.org/), PowerShell, and a CSV spreadsheet with timecodes.

This tool is supposed to quickly generate feedback for peers that can indicate preffered segments from a video, without having to use Premiere or other complex editors.

Resulting MP4 files are 640x360 (unless you change the script) and will not be frame-perfect.

## Requirements

- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7); a scripting language available by default on Windows 10 installations. It’s also possible to install it on [macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7).
- [ffmpeg](https://ffmpeg.zeranoe.com/builds/); an open-source command-line tool for editing video. You will have to [install a Windows build](http://blog.gregzaal.com/how-to-install-ffmpeg-on-windows/) manually. It’s important for `ffmpeg` executable to be added to the Path.
- Any spreadsheet editor (such as Excel, Google Sheets etc.) that can export [CSV files](https://www.lifewire.com/csv-file-2622708).
- Download all the files from this repository in the same directory (folder).


## How to run

- Make sure you have saved your CSV file in the same directory as `timecodes.csv`. See [Spreadsheet structure](#spreadsheet-structure) for more.
- Double-click `montaziera_run.bat`, to execute a simple [BAT script](https://www.lifewire.com/bat-file-2619796) that  will open a console window and run the respective `montaziera.ps1` PowerShell script. 
- After some time, unless an error occurs, an MP4 file with your desired cut will be available in the same directory.
- If an error occurs, it will appear in red text on the console window.

Your working directory will eventually look similar to this:

```
├── /clips/			(generated automatically)
│   ├── 000.mp4
│   ├── …
│   timecodes.csv		(created by user)
│   concat.txt			(generated automatically)
│   montaziera_run.bat		(double click to run)
│   montaziera.ps1		(the actual script)
│   preview_2020-09-10-11.mp4	(the output video)
```

👉 You will have to manually delete the `/clips/` directory if you wish to re-generate them, therefore always delete the previous clip if you change your CSV file.

## How it works

👉 Always be cautious of scripts you find available online: open them in a text editor and inspect what they do.

- The script reads the CSV file line by line, and cuts segments in a directory named `/clips/` as directed by the *start* and *duration* columns. The directory will be created if it doesn’t exist.
- A short white clip is inserted first to ensure the resulting video has audio, counter a shortcoming of ffmpeg.
- Once the segmenst have been created, the clips are “glued” together according to the order they appear in `concat.txt`, a simple text file created during the previous steps.
- If a *super* or *desc* (description) is provided for a line, its text contents will be overlaid on the video at bottom left. The name of each clip file (a three-digit number) is displayed in the upper right corner. This is designed to help identify which segment is which.


## Spreadsheet structure

Your sheet should have the following structure. [Export it as a CSV](https://www.solveyourtech.com/save-csv-google-sheets/) (comma separated) and save it on the same directory with the script as `timecodes.csv`. A sample file is provided here, named `timecodes_sample.csv`.

👉 This script is *alpha quality*, hence it will not tolerate mistakes in your CSV and might not always work without issues. Use formulas to make sure the durations are correct.

| material    | file                       | start    | end      | duration | super            | descr                  |
| :---------- | :------------------------- | :------- | :------- | :------- | :--------------- | :--------------------- |
| some video  | C:/…/documents/video01.mp4 | 00:05:00 | 00:08:20 | 00:03:20 | Moderator’s Name | Description of segment |
| an image    | C:/…/documents/card.png    | 00:00:00 | 00:00:10 | 00:00:10 | Introduction     | A static card          |
| other video | C:/…/documents/video02.mp4 | 00:10:40 | 00:12:00 | 00:01:20 | Speaker’s name   | First segment          |
| other video | C:/…/documents/video02.mp4 | 00:20:00 | 00:22:10 | 00:02:10 |                  | Second segment         |

The *material* column text optional, but the column itself is required.

Timecodes and durations are in *hours:minutes:seconds.milliseconds* format. However milliseconds are optional. The *end* timecode is currently ignored.

The files (accepts MP4, MOV, JPG and PNG) to be edited can be anywhere on your computer, but you will have to provide the exact path and filename. The CSV file should not contain any headers, ie. the line that describes what the columns are.


## Known issues / Future Improvements

- [ ] If several video sources are mixed, audio-video may become out of sync.
- [ ] Non-latin characters in the *super* and *description* column, may sometimes cause the overlay to be hidden.
- [ ] Clips created from static images may have the wrong duration.
- [ ] Missing option to select the output definition.
- [ ] Missing option to hide text overlays.
- [ ] Missing a prompt to delete (or keep) previously generated clips.
- [ ] Missing option to select duration (currently) or end timecode for clipping videos.
- [ ] Code could be cleaner / modular. Pull Requests are welcome.
- [ ] Additional ffmpeg [filters](https://ffmpeg.org/ffmpeg-filters.html) could be passed per line.


* * *

© 2020 [Heracles Papatheodorou](https://heracl.es) a.k.a [@Arty2](https://www.twitter.com/Arty2), MIT Licence