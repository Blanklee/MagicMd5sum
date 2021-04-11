# MagicMd5sum

- Overview : Windows Graphic UI Program of md5sum, Easy to use.

- Develop Tools : Delphi 10.4.2 using Indy component.

- Usage : Just drop files and click RUN button.

<br/>

# Release Notes :

- ver 1.0 / 2020.10.16 \
  . Start up Windows GUI version of MD5SUM \
  . Just drop files and click RUN button \
  . Implement essential core functions, very basically

- ver 1.1 / 2020.10.19 / Drop \
  . Try to show progress bar (failed)

- ver 1.2 / 2020.10.21 \
  . Add 'Copy Text' button : copy Memo1.Text to ClipBoard \
  . Implement Ctrl-A, Ctrl-C on Memo1 : same action as 'Copy Text' button \
  . User can conveniently copy Memo1.Text to Clipboard \
  . Add 'Clear' button : clear all text on Memo1

- ver 1.3 / 2020.11.04 \
  . Support continuous drop \
  . If files are dropped several times, it is managed accumulatively in FileList \
  . Before, only the last dropped list was processed

- ver 1.4 / 2020.11.18
  - Implement much faster speed \
    . with 3.5GB it takes 02:05 at v1.3, 00:11 at v1.4 (8~10 times faster) \
    . internally use MyHash5, it fetches 512KB at once on calculation
  - Show ProgressBar during run \
    . Derive TProgressBar to implement Int64 for large files bigger than 2GB \
    . To show rate it gets total bytes from File_Size function (BlankUtils.pas)
  - Support Pause & Stop button

- ver 1.4a / 2021.02.14 \
  . Delete 'RUN (v1.3)' button, rename 'RUN (v1.4)' to 'RUN!'
  . Add icon to project (icon3.ico)

- ver 1.4b / 2021.03.05 \
  . btRun, btPause, btStop is replaced from TButton to TBitBtn, add Glyph
  . Show elapsed time after finishing md5sum calculation

- ver 1.5 / 2021.03.29 \
  . Show total size when file added

- ver 1.5a / 2021.04.11 \
  . Apply 'Sky' style, design changed


<br/>

# ScreenShots :

![1_Initial](https://user-images.githubusercontent.com/26485313/114305135-d843bf80-9b11-11eb-9ec5-fc84a03ac26e.png)

![2_Run](https://user-images.githubusercontent.com/26485313/114305136-d974ec80-9b11-11eb-9d5b-d09eccfa6f1e.png)

![3_Run](https://user-images.githubusercontent.com/26485313/114305137-d974ec80-9b11-11eb-97b5-6ad1c439601e.png)

![4_Finish](https://user-images.githubusercontent.com/26485313/114305138-da0d8300-9b11-11eb-918f-98b64f832e41.png)

<br/><br/>
